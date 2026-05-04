import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { PrismaService } from '../prisma/prisma.service';
import { notExistProduct } from '../common/utils/not-exist-product.util';
import { conflictProduct } from '../common/utils/conflict-product.util';

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createProductDto: CreateProductDto) {
    // 1. Cek apakah kategori ada
    const categoryExists = await this.prisma.category.findUnique({
      where: { id: createProductDto.categoryId },
    });

    if (!categoryExists) {
      throw new BadRequestException({
        success: false,
        message: 'Kategori dengan ID tersebut tidak ditemukan',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }

    // 2. CEK DUPLIKASI NAMA PRODUK DI SINI
    const name = await conflictProduct(
      createProductDto.name,
      process.env.FAILED_SAVE || 'Gagal menyimpan, nama produk sudah ada',
      this.prisma,
    );

    // 3. Save data
    await this.prisma.product.create({
      data: {
        name: name,
        description: createProductDto.description,
        price: createProductDto.price,
        discountPrice: createProductDto.discountPrice,
        imageUrl: createProductDto.imageUrl,
        images: createProductDto.images,
        stock: createProductDto.stock,
        isFeatured: createProductDto.isFeatured ?? false,
        isAvailable: createProductDto.isAvailable ?? true,
        unit: createProductDto.unit,
        categoryId: createProductDto.categoryId,
      },
    });

    return {
      success: true,
      message: process.env.SUCCESS_SAVE || 'Data produk berhasil disimpan',
      metadata: { status: HttpStatus.CREATED },
    };
  }

  async findAll() {
    // Ambil semua produk beserta data kategorinya
    const rawData = await this.prisma.product.findMany({
      include: {
        category: true,
      },
    });

    if (rawData.length === 0) {
      throw new NotFoundException({
        success: false,
        message: process.env.NOT_DATA || 'Data produk kosong',
        metadata: { status: HttpStatus.NOT_FOUND, total_data: 0 },
      });
    }

    const formattedData = rawData.map((product) => ({
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      imageUrl: product.imageUrl,
      images: product.images,
      categoryId: product.categoryId,
      categoryName: product.category.name,
      stock: product.stock,
      rating: product.rating,
      reviewCount: product.reviewCount,
      isFeatured: product.isFeatured,
      isAvailable: product.isAvailable,
      unit: product.unit,
    }));

    return {
      success: true,
      message: process.env.ALL_DATA || 'Berhasil mengambil semua data produk',
      metadata: { status: HttpStatus.OK, total_data: formattedData.length },
      data: formattedData,
    };
  }

  async findOne(id: number) {
    try {
      const product = await notExistProduct(id, this.prisma);

      const { category, ...restProduct } = product;

      const formattedData = {
        ...restProduct,
        categoryName: category.name,
      };

      return {
        success: true,
        message:
          process.env.ONE_DATA || 'Berhasil mengambil detail data produk',
        metadata: { status: HttpStatus.OK },
        data: formattedData,
      };
    } catch (error) {
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID harus berupa angka',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async update(id: number, updateProductDto: UpdateProductDto) {
    try {
      await notExistProduct(id, this.prisma);

      if (updateProductDto.categoryId) {
        const categoryExists = await this.prisma.category.findUnique({
          where: { id: updateProductDto.categoryId },
        });
        if (!categoryExists) {
          throw new BadRequestException({
            success: false,
            message: 'Kategori dengan ID tersebut tidak ditemukan',
            metadata: { status: HttpStatus.BAD_REQUEST },
          });
        }
      }

      // CEK DUPLIKASI SAAT UPDATE JIKA ADA PENGIRIMAN NAMA BARU
      if (updateProductDto.name) {
        // Ambil data produk saat ini
        const currentProduct = await this.prisma.product.findUnique({
          where: { id: id },
        });
        if (currentProduct && currentProduct.name !== updateProductDto.name) {
          await conflictProduct(
            updateProductDto.name,
            process.env.FAILED_UPDATE ||
              'Gagal update, nama produk sudah digunakan',
            this.prisma,
          );
        }
      }

      await this.prisma.product.update({
        where: { id: id },
        data: {
          ...updateProductDto,
        },
      });

      return {
        success: true,
        message: process.env.SUCCESS_UPDATE || 'Data produk berhasil diubah',
        metadata: { status: HttpStatus.OK },
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID tidak valid',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async remove(id: number) {
    try {
      await notExistProduct(id, this.prisma);

      await this.prisma.product.delete({
        where: { id: id },
      });

      return {
        success: true,
        message: process.env.SUCCESS_DELETE || 'Data produk berhasil dihapus',
        metadata: { status: HttpStatus.OK },
      };
    } catch (error) {
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID tidak valid',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }
}
