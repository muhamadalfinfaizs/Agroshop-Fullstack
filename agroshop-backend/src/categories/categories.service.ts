import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { PrismaService } from '../prisma/prisma.service';
import { notExistCategory } from '../common/utils/not-exist-category.util';
import { conflictCategory } from '../common/utils/conflict-category.util';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createCategoryDto: CreateCategoryDto) {
    const name = await conflictCategory(
      createCategoryDto.name,
      process.env.FAILED_SAVE || 'Gagal menyimpan, nama kategori sudah ada',
      this.prisma,
    );

    await this.prisma.category.create({
      data: {
        name: name,
        icon: createCategoryDto.icon,
        imageUrl: createCategoryDto.imageUrl,
      },
    });

    return {
      success: true,
      message: process.env.SUCCESS_SAVE || 'Data berhasil disimpan',
      metadata: {
        status: HttpStatus.CREATED,
      },
    };
  }

  async findAll() {
    const rawData = await this.prisma.category.findMany({
      include: {
        _count: {
          select: { products: true },
        },
      },
    });

    if (rawData.length === 0) {
      throw new NotFoundException({});
    }

    // Format datanya agar persis dengan yang diminta category.dart di Flutter
    const formattedData = rawData.map((category) => ({
      id: category.id,
      name: category.name,
      icon: category.icon,
      imageUrl: category.imageUrl,
      productCount: category._count.products,
    }));

    return {
      success: true,
      message: process.env.ALL_DATA || 'Berhasil mengambil semua data',
      metadata: {
        status: HttpStatus.OK,
        total_data: formattedData.length,
      },
      data: formattedData,
    };
  }

  async findOne(id: number) {
    try {
      const data = await notExistCategory(id, this.prisma);

      return {
        success: true,
        message: process.env.ONE_DATA || 'Berhasil mengambil detail data',
        metadata: {
          status: HttpStatus.OK,
        },
        data: data,
      };
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID harus berupa angka',
        metadata: {
          status: HttpStatus.BAD_REQUEST,
        },
      });
    }
  }

  async update(id: number, updateCategoryDto: UpdateCategoryDto) {
    try {
      await notExistCategory(id, this.prisma);

      const name = await conflictCategory(
        updateCategoryDto.name ?? '',
        process.env.FAILED_UPDATE ||
          'Gagal update, nama kategori sudah digunakan',
        this.prisma,
      );

      await this.prisma.category.update({
        where: { id: id },
        data: {
          name: name,
          icon: updateCategoryDto.icon,
          imageUrl: updateCategoryDto.imageUrl,
        },
      });

      return {
        success: true,
        message: process.env.SUCCESS_UPDATE || 'Data berhasil diubah',
        metadata: {
          status: HttpStatus.OK,
        },
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID tidak valid',
        metadata: {
          status: HttpStatus.BAD_REQUEST,
        },
      });
    }
  }

  async remove(id: number) {
    try {
      await notExistCategory(id, this.prisma);

      await this.prisma.category.delete({
        where: { id: id },
      });

      return {
        success: true,
        message: process.env.SUCCESS_DELETE || 'Data berhasil dihapus',
        metadata: {
          status: HttpStatus.OK,
        },
      };
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID tidak valid',
        metadata: {
          status: HttpStatus.BAD_REQUEST,
        },
      });
    }
  }
}
