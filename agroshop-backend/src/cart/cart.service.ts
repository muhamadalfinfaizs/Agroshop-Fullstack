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
import { notExistCart } from '../common/utils/not-exist-cart.util';
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

  async findAll() {
    // Ambil data keranjang beserta detail nama produk dan nama usernya
    const carts = await this.prisma.cartItem.findMany({
      include: {
        product: {
          select: { name: true, price: true, imageUrl: true },
        },
        user: {
          select: { name: true, email: true },
        },
      },
    });

    if (carts.length === 0) {
      throw new NotFoundException({
        success: false,
        message: 'Data keranjang kosong',
        metadata: { status: HttpStatus.NOT_FOUND, total_data: 0 },
      });
    }

    return {
      success: true,
      message: 'Berhasil mengambil semua data keranjang',
      metadata: { status: HttpStatus.OK, total_data: carts.length },
      data: carts,
    };
  }

  async findOne(id: number) {
    try {
      await notExistCart(id, this.prisma);

      const cart = await this.prisma.cartItem.findUnique({
        where: { id: id },
        include: {
          product: { select: { name: true, price: true, imageUrl: true } },
          user: { select: { name: true, email: true } },
        },
      });

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

  async update(id: number, updateCartDto: UpdateCartDto) {
    try {
      await notExistCart(id, this.prisma);

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

  async remove(id: number) {
    try {
      await notExistCart(id, this.prisma);

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
