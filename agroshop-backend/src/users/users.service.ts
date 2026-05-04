import {
  Injectable,
  HttpStatus,
  BadRequestException,
  NotFoundException,
  HttpException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { conflictUser } from '../common/utils/conflict-user.util';
import { notExistUser } from '../common/utils/not-exist-user.util';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    // 1. Cek duplikasi email
    await conflictUser(createUserDto.email, this.prisma);

    // 2. Hash password
    const salt = await bcrypt.genSalt();
    const hashedPassword = await bcrypt.hash(createUserDto.password, salt);

    // 3. Simpan ke database
    await this.prisma.user.create({
      data: {
        ...createUserDto,
        password: hashedPassword,
        imageUrl: createUserDto.imageUrl || '', // Default string kosong
        phone: createUserDto.phone || '', // Default string kosong
        address: createUserDto.address || '', // Default string kosong
      },
    });
    return {
      success: true,
      message: process.env.SUCCESS_SAVE || 'Data user berhasil disimpan',
      metadata: { status: HttpStatus.CREATED },
    };
  }

  async findAll() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        address: true,
        imageUrl: true,
        // Hapus role, createdAt, dan updatedAt jika memang tidak ada di database Anda
      },
    });

    if (users.length === 0) {
      throw new NotFoundException({
        success: false,
        message: process.env.NOT_DATA || 'Data user kosong',
        metadata: { status: HttpStatus.NOT_FOUND, total_data: 0 },
      });
    }

    return {
      success: true,
      message: process.env.ALL_DATA || 'Berhasil mengambil semua data user',
      metadata: { status: HttpStatus.OK, total_data: users.length },
      data: users,
    };
  }

  async findOne(id: number) {
    try {
      const user = await notExistUser(id, this.prisma);

      // Pisahkan password dari hasil agar tidak dikirim ke frontend
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { password, ...result } = user;

      return {
        success: true,
        message: process.env.ONE_DATA || 'Berhasil mengambil detail data user',
        metadata: { status: HttpStatus.OK },
        data: result,
      };
    } catch (error) {
      // ... lanjutan kode
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException({
        success: false,
        message: process.env.NUMBER_ONLY || 'ID harus berupa angka',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    try {
      // 1. Pastikan user ada
      const currentUser = await notExistUser(id, this.prisma);

      // 2. Jika email diubah, cek agar tidak bentrok dengan email orang lain
      if (updateUserDto.email && currentUser.email !== updateUserDto.email) {
        await conflictUser(updateUserDto.email, this.prisma);
      }

      const dataToUpdate = { ...updateUserDto };

      if (dataToUpdate.password) {
        const salt = await bcrypt.genSalt();
        dataToUpdate.password = await bcrypt.hash(dataToUpdate.password, salt);
      }

      // 5. Lakukan update
      await this.prisma.user.update({
        where: { id: id },
        data: dataToUpdate,
      });

      return {
        success: true,
        message: process.env.SUCCESS_UPDATE || 'Data user berhasil diubah',
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
      await notExistUser(id, this.prisma);

      await this.prisma.user.delete({
        where: { id: id },
      });

      return {
        success: true,
        message: process.env.SUCCESS_DELETE || 'Data user berhasil dihapus',
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
