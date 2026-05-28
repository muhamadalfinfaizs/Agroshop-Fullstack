import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, ShipmentStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateShipmentEventDto } from './dto/create-shipment-event.dto';
import { UpdateShipmentDto } from './dto/update-shipment.dto';

@Injectable()
export class ShipmentsService {
  constructor(private readonly prisma: PrismaService) {}

  async findByOrder(userId: number, orderCode: string) {
    const order = await this.prisma.order.findFirst({
      where: { userId, orderCode },
      include: {
        shipment: {
          include: { events: { orderBy: { createdAt: 'asc' } } },
        },
      },
    });

    if (!order) {
      throw new NotFoundException({
        success: false,
        message: 'Pesanan tidak ditemukan',
        metadata: { status: HttpStatus.NOT_FOUND },
      });
    }

    const shipment = order.shipment ?? (await this.createDefaultShipment(order.id));

    return {
      success: true,
      message: 'Berhasil mengambil data pengiriman',
      metadata: { status: HttpStatus.OK },
      data: this.formatShipment(shipment, order.orderCode),
    };
  }

  async updateByOrder(orderCode: string, updateShipmentDto: UpdateShipmentDto) {
    try {
      const order = await this.prisma.order.findUnique({
        where: { orderCode },
        include: { shipment: true },
      });

      if (!order) {
        throw new NotFoundException({
          success: false,
          message: 'Pesanan tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      const shipmentStatus = this.toShipmentStatus(updateShipmentDto.status);
      const shipmentData: any = {
        courier: updateShipmentDto.courier,
        trackingNumber: updateShipmentDto.trackingNumber,
        status: shipmentStatus,
      };

      if (
        shipmentStatus === ShipmentStatus.SHIPPED ||
        shipmentStatus === ShipmentStatus.IN_TRANSIT
      ) {
        shipmentData.shippedAt = order.shipment?.shippedAt ?? new Date();
      }

      if (shipmentStatus === ShipmentStatus.DELIVERED) {
        shipmentData.deliveredAt = order.shipment?.deliveredAt ?? new Date();
      }

      const shipment = await this.prisma.shipment.upsert({
        where: { orderId: order.id },
        update: shipmentData,
        create: {
          orderId: order.id,
          status: shipmentStatus ?? ShipmentStatus.WAITING,
          courier: updateShipmentDto.courier,
          trackingNumber: updateShipmentDto.trackingNumber,
          shippedAt: shipmentData.shippedAt,
          deliveredAt: shipmentData.deliveredAt,
          events: {
            create: {
              title: 'Data pengiriman dibuat',
              description: 'Data pengiriman sudah tersedia untuk pesanan ini',
            },
          },
        },
        include: { events: { orderBy: { createdAt: 'asc' } } },
      });

      await this.syncOrderStatus(order.id, shipmentStatus);

      return {
        success: true,
        message: 'Data pengiriman berhasil diperbarui',
        metadata: { status: HttpStatus.OK },
        data: this.formatShipment(shipment, order.orderCode),
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal memperbarui data pengiriman',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async addEvent(orderCode: string, createShipmentEventDto: CreateShipmentEventDto) {
    try {
      const order = await this.prisma.order.findUnique({
        where: { orderCode },
        include: { shipment: true },
      });

      if (!order) {
        throw new NotFoundException({
          success: false,
          message: 'Pesanan tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      const shipment = order.shipment ?? (await this.createDefaultShipment(order.id));

      const shipmentStatus = this.toShipmentStatus(createShipmentEventDto.status);

      await this.prisma.shipmentEvent.create({
        data: {
          title: createShipmentEventDto.title,
          description: createShipmentEventDto.description,
          location: createShipmentEventDto.location,
          shipmentId: shipment.id,
        },
      });

      if (shipmentStatus) {
        await this.prisma.shipment.update({
          where: { id: shipment.id },
          data: { status: shipmentStatus },
        });
        await this.syncOrderStatus(order.id, shipmentStatus);
      }

      const updatedShipment = await this.prisma.shipment.findUnique({
        where: { id: shipment.id },
        include: { events: { orderBy: { createdAt: 'asc' } } },
      });

      return {
        success: true,
        message: 'Riwayat pengiriman berhasil ditambahkan',
        metadata: { status: HttpStatus.CREATED },
        data: this.formatShipment(updatedShipment, order.orderCode),
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal menambahkan riwayat pengiriman',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  private async createDefaultShipment(orderId: number) {
    return this.prisma.shipment.create({
      data: {
        orderId,
        status: ShipmentStatus.WAITING,
        events: {
          create: {
            title: 'Pesanan dibuat',
            description: 'Pesanan berhasil dibuat dan menunggu diproses',
          },
        },
      },
      include: { events: { orderBy: { createdAt: 'asc' } } },
    });
  }

  private async syncOrderStatus(orderId: number, shipmentStatus?: ShipmentStatus) {
    const statusMap: Partial<Record<ShipmentStatus, OrderStatus>> = {
      SHIPPED: OrderStatus.SHIPPED,
      IN_TRANSIT: OrderStatus.SHIPPED,
      DELIVERED: OrderStatus.COMPLETED,
      CANCELLED: OrderStatus.CANCELLED,
    };

    const orderStatus = shipmentStatus ? statusMap[shipmentStatus] : undefined;
    if (!orderStatus) return;

    await this.prisma.order.update({
      where: { id: orderId },
      data: { status: orderStatus },
    });
  }

  private toShipmentStatus(status?: string) {
    if (!status) return undefined;

    const allowedStatuses = Object.values(ShipmentStatus);
    if (!allowedStatuses.includes(status as ShipmentStatus)) {
      throw new BadRequestException({
        success: false,
        message: 'Status pengiriman tidak valid',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }

    return status as ShipmentStatus;
  }

  private formatShipment(shipment: any, orderCode: string) {
    return {
      id: shipment.id,
      orderCode,
      courier: shipment.courier,
      trackingNumber: shipment.trackingNumber,
      status: shipment.status,
      statusText: this.formatStatus(shipment.status),
      shippedAt: shipment.shippedAt,
      deliveredAt: shipment.deliveredAt,
      events: shipment.events.map((event: any) => ({
        id: event.id,
        title: event.title,
        description: event.description,
        location: event.location,
        createdAt: event.createdAt,
      })),
    };
  }

  private formatStatus(status: string) {
    const labels: Record<string, string> = {
      WAITING: 'Menunggu Diproses',
      PACKED: 'Dikemas',
      SHIPPED: 'Dikirim',
      IN_TRANSIT: 'Dalam Perjalanan',
      DELIVERED: 'Terkirim',
      CANCELLED: 'Dibatalkan',
    };

    return labels[status] ?? status;
  }
}
