import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async checkout(userId: number, createOrderDto: CreateOrderDto) {
    try {
      const order = await this.prisma.$transaction(async (tx) => {
        const cartItems = await tx.cartItem.findMany({
          where: { 
            userId,
            ...(createOrderDto.cartItemIds && createOrderDto.cartItemIds.length > 0 
                ? { id: { in: createOrderDto.cartItemIds } } 
                : {})
          },
          include: { product: true },
        });

        if (cartItems.length === 0) {
          throw new BadRequestException({
            success: false,
            message: 'Keranjang masih kosong',
            metadata: { status: HttpStatus.BAD_REQUEST },
          });
        }

        // 1. VALIDASI STOK
        for (const item of cartItems) {
          if (item.product.stock < item.quantity) {
            throw new BadRequestException({
              success: false,
              message: `Stok produk ${item.product.name} tidak mencukupi (Tersisa: ${item.product.stock})`,
              metadata: { status: HttpStatus.BAD_REQUEST },
            });
          }
        }

        const total = cartItems.reduce((sum, item) => {
          const price = item.product.discountPrice ?? item.product.price;
          return sum + price * item.quantity;
        }, 0);

        const shippingAddress = await this.resolveShippingAddress(
          tx,
          userId,
          createOrderDto,
        );

        const newOrder = await tx.order.create({
          data: {
            orderCode: this.generateOrderCode(),
            total,
            shippingAddress,
            userId,
            items: {
              create: cartItems.map((item) => ({
                productId: item.productId,
                productName: item.product.name,
                price: item.product.discountPrice ?? item.product.price,
                quantity: item.quantity,
              })),
            },
            shipment: {
              create: {
                status: 'WAITING',
                events: {
                  create: {
                    title: 'Pesanan dibuat',
                    description: 'Pesanan berhasil dibuat dan menunggu diproses',
                  },
                },
              },
            },
          },
          include: {
            items: true,
            shipment: { include: { events: { orderBy: { createdAt: 'asc' } } } },
          },
        });

        await tx.cartItem.deleteMany({ 
          where: { 
            id: { in: cartItems.map((item) => item.id) } 
          } 
        });

        // 2. PENGURANGAN STOK
        await Promise.all(
          cartItems.map((item) =>
            tx.product.update({
              where: { id: item.productId },
              data: { stock: { decrement: item.quantity } },
            })
          )
        );

        return newOrder;
      });

      return {
        success: true,
        message: 'Checkout berhasil, pesanan berhasil dibuat',
        metadata: { status: HttpStatus.CREATED },
        data: this.formatOrder(order),
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal membuat pesanan',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async findAll(userId: number) {
    const orders = await this.prisma.order.findMany({
      where: { userId },
      include: {
        items: true,
        shipment: { include: { events: { orderBy: { createdAt: 'asc' } } } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      success: true,
      message: 'Berhasil mengambil riwayat pesanan',
      metadata: { status: HttpStatus.OK, total_data: orders.length },
      data: orders.map((order) => this.formatOrder(order)),
    };
  }

  async findAllAdmin() {
    const orders = await this.prisma.order.findMany({
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
          },
        },
        items: true,
        shipment: { include: { events: { orderBy: { createdAt: 'asc' } } } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      success: true,
      message: 'Berhasil mengambil semua pesanan',
      metadata: { status: HttpStatus.OK, total_data: orders.length },
      data: orders.map((order) => ({
        ...this.formatOrder(order),
        user: order.user,
      })),
    };
  }

  async findOne(userId: number, orderCode: string) {
    const order = await this.prisma.order.findFirst({
      where: { userId, orderCode },
      include: {
        items: true,
        shipment: { include: { events: { orderBy: { createdAt: 'asc' } } } },
      },
    });

    if (!order) {
      throw new NotFoundException({
        success: false,
        message: 'Pesanan tidak ditemukan',
        metadata: { status: HttpStatus.NOT_FOUND },
      });
    }

    return {
      success: true,
      message: 'Berhasil mengambil detail pesanan',
      metadata: { status: HttpStatus.OK },
      data: this.formatOrder(order),
    };
  }

  private generateOrderCode() {
    const now = new Date();
    const datePart = now.toISOString().slice(0, 10).replace(/-/g, '');
    const suffix = `${now.getTime()}`.slice(-6);
    return `AGR-${datePart}-${suffix}`;
  }

  private formatStatus(status: string) {
    const labels: Record<string, string> = {
      PROCESSING: 'Diproses',
      SHIPPED: 'Sedang Dikirim',
      COMPLETED: 'Selesai',
      CANCELLED: 'Dibatalkan',
    };

    return labels[status] ?? status;
  }

  private async resolveShippingAddress(
    tx: any,
    userId: number,
    createOrderDto: CreateOrderDto,
  ) {
    if (createOrderDto.addressId) {
      const address = await tx.address.findFirst({
        where: { id: +createOrderDto.addressId, userId },
      });

      if (!address) {
        throw new NotFoundException({
          success: false,
          message: 'Alamat pengiriman tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      return address.detail;
    }

    if (createOrderDto.address) {
      return createOrderDto.address;
    }

    const defaultAddress = await tx.address.findFirst({
      where: { userId, isDefault: true },
    });

    if (defaultAddress) {
      return defaultAddress.detail;
    }

    const user = await tx.user.findUnique({
      where: { id: userId },
      select: { address: true },
    });

    return user?.address;
  }

  private formatOrder(order: any) {
    return {
      id: order.orderCode,
      orderId: order.id,
      date: order.createdAt,
      status: this.formatStatus(order.status),
      total: order.total,
      shippingAddress: order.shippingAddress,
      shipment: this.formatShipment(order.shipment),
      items: order.items.map((item: any) => ({
        name: item.productName,
        qty: item.quantity,
        price: item.price,
        productId: item.productId,
      })),
    };
  }

  private formatShipment(shipment: any) {
    if (!shipment) return null;

    return {
      id: shipment.id,
      courier: shipment.courier,
      trackingNumber: shipment.trackingNumber,
      status: shipment.status,
      events: shipment.events.map((event: any) => ({
        title: event.title,
        description: event.description,
        location: event.location,
        createdAt: event.createdAt,
      })),
    };
  }
}

