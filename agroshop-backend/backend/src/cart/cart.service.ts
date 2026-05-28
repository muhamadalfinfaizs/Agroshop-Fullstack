import {
  Injectable,
  HttpStatus,
  BadRequestException,
  NotFoundException,
  HttpException,
} from '@nestjs/common';
import { CreateCartDto } from './dto/create-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';
import { PrismaService } from '../prisma/prisma.service';
import { notExistUser } from '../common/utils/not-exist-user.util';
import { notExistProduct } from '../common/utils/not-exist-product.util';

@Injectable()
export class CartService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createCartDto: CreateCartDto) {
    // 1. Validasi: Pastikan User dan Product-nya benar-benar ada di database
    await notExistUser(createCartDto.userId, this.prisma);
    await notExistProduct(createCartDto.productId, this.prisma);

    // 2. Cek apakah produk ini sudah ada di keranjang user tersebut
    const existingCartItem = await this.prisma.cartItem.findFirst({
      where: {
        userId: createCartDto.userId,
        productId: createCartDto.productId,
      },
    });

    if (existingCartItem) {
      await this.prisma.cartItem.update({
        where: { id: existingCartItem.id },
        data: {
          quantity: existingCartItem.quantity + createCartDto.quantity,
        },
      });

      return {
        success: true,
        message: 'Jumlah produk di keranjang berhasil ditambahkan',
        metadata: { status: HttpStatus.OK },
      };
    } else {
      await this.prisma.cartItem.create({
        data: {
          userId: createCartDto.userId,
          productId: createCartDto.productId,
          quantity: createCartDto.quantity,
        },
      });

      return {
        success: true,
        message: 'Produk berhasil dimasukkan ke keranjang',
        metadata: { status: HttpStatus.CREATED },
      };
    }
  }

  async findAll(userId: number) {
    // Ambil data keranjang milik user yang sedang login
    const carts = await this.prisma.cartItem.findMany({
      where: { userId },
      include: {
        product: {
          select: { name: true, price: true, discountPrice: true, imageUrl: true },
        },
        user: {
          select: { name: true, email: true },
        },
      },
    });

    return {
      success: true,
      message: 'Berhasil mengambil data keranjang',
      metadata: { status: HttpStatus.OK, total_data: carts.length },
      data: carts,
    };
  }

  async findOne(userId: number, id: number) {
    try {
      const cart = await this.prisma.cartItem.findFirst({
        where: { id, userId },
        include: {
          product: { select: { name: true, price: true, discountPrice: true, imageUrl: true } },
          user: { select: { name: true, email: true } },
        },
      });

      if (!cart) {
        throw new NotFoundException({
          success: false,
          message: 'Data keranjang tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      return {
        success: true,
        message: 'Berhasil mengambil detail data keranjang',
        metadata: { status: HttpStatus.OK },
        data: cart,
      };
    } catch (error) {
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'ID harus berupa angka',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async update(userId: number, id: number, updateCartDto: UpdateCartDto) {
    try {
      const cart = await this.prisma.cartItem.findFirst({
        where: { id, userId },
      });

      if (!cart) {
        throw new NotFoundException({
          success: false,
          message: 'Data keranjang tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      await this.prisma.cartItem.update({
        where: { id: id },
        data: {
          quantity: updateCartDto.quantity,
        },
      });

      return {
        success: true,
        message: 'Jumlah keranjang berhasil diubah',
        metadata: { status: HttpStatus.OK },
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'ID tidak valid',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async clear(userId: number) {
    try {
      const result = await this.prisma.cartItem.deleteMany({
        where: { userId },
      });

      return {
        success: true,
        message: 'Keranjang berhasil dikosongkan',
        metadata: { status: HttpStatus.OK, total_data: result.count },
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal mengosongkan keranjang',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async remove(userId: number, id: number) {
    try {
      const cart = await this.prisma.cartItem.findFirst({
        where: { id, userId },
      });

      if (!cart) {
        throw new NotFoundException({
          success: false,
          message: 'Data keranjang tidak ditemukan',
          metadata: { status: HttpStatus.NOT_FOUND },
        });
      }

      await this.prisma.cartItem.delete({
        where: { id: id },
      });

      return {
        success: true,
        message: 'Produk berhasil dihapus dari keranjang',
        metadata: { status: HttpStatus.OK },
      };
    } catch (error) {
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'ID tidak valid',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }
}
