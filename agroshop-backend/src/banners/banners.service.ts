import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CreateBannerDto } from './dto/create-banner.dto';
import { UpdateBannerDto } from './dto/update-banner.dto';
import { PrismaService } from '../prisma/prisma.service';
import { notExistBanner } from '../common/utils/not-exist-banner.util';
import { conflictBanner } from '../common/utils/conflict-banner.util'; // Import Pelindung

@Injectable()
export class BannersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createBannerDto: CreateBannerDto) {
    // CEK DUPLIKASI JUDUL BANNER
    const title = await conflictBanner(
      createBannerDto.title,
      process.env.FAILED_SAVE || 'Gagal menyimpan, judul banner sudah ada',
      this.prisma,
    );

    await this.prisma.banner.create({
      data: {
        title: title,
        subtitle: createBannerDto.subtitle,
        imageUrl: createBannerDto.imageUrl,
      },
    });

    return {
      success: true,
      message: process.env.SUCCESS_SAVE || 'Data banner berhasil disimpan',
      metadata: { status: HttpStatus.CREATED },
    };
  }

  async findAll() {
    const data = await this.prisma.banner.findMany();

    if (data.length === 0) {
      throw new NotFoundException({
        success: false,
        message: process.env.NOT_DATA || 'Data banner kosong',
        metadata: { status: HttpStatus.NOT_FOUND, total_data: 0 },
      });
    }

    return {
      success: true,
      message: process.env.ALL_DATA || 'Berhasil mengambil semua data banner',
      metadata: { status: HttpStatus.OK, total_data: data.length },
      data: data,
    };
  }

  async findOne(id: number) {
    try {
      const data = await notExistBanner(id, this.prisma);

      return {
        success: true,
        message:
          process.env.ONE_DATA || 'Berhasil mengambil detail data banner',
        metadata: { status: HttpStatus.OK },
        data: data,
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

  async update(id: number, updateBannerDto: UpdateBannerDto) {
    try {
      await notExistBanner(id, this.prisma);

      // CEK DUPLIKASI SAAT UPDATE
      if (updateBannerDto.title) {
        const currentBanner = await this.prisma.banner.findUnique({
          where: { id: id },
        });
        if (currentBanner && currentBanner.title !== updateBannerDto.title) {
          await conflictBanner(
            updateBannerDto.title,
            process.env.FAILED_UPDATE ||
              'Gagal update, judul banner sudah digunakan',
            this.prisma,
          );
        }
      }

      await this.prisma.banner.update({
        where: { id: id },
        data: {
          ...updateBannerDto,
        },
      });

      return {
        success: true,
        message: process.env.SUCCESS_UPDATE || 'Data banner berhasil diubah',
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
      await notExistBanner(id, this.prisma);

      await this.prisma.banner.delete({
        where: { id: id },
      });

      return {
        success: true,
        message: process.env.SUCCESS_DELETE || 'Data banner berhasil dihapus',
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
