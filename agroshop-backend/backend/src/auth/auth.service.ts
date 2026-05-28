import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { User } from '@prisma/client';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  // ==============================
  // FITUR 1: LOGIN
  // ==============================
  async login(loginDto: LoginDto) {
    const user: User | null = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Email atau password salah');
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Email atau password salah');
    }

    const payload = { sub: user.id, email: user.email, role: user.role };
    const token = this.jwtService.sign(payload);

    return {
      message: 'Login berhasil',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        imageUrl: user.imageUrl,
        address: user.address,
      },
      token: token,
    };
  }

  // ==============================
  // FITUR 2: REGISTER
  // ==============================
  async register(registerDto: RegisterDto) {
    // 1. Cek apakah email sudah pernah dipakai
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException(
        'Email sudah terdaftar, silakan gunakan email lain',
      );
    }

    // 2. Acak/Enkripsi password sebelum disimpan (keamanan wajib)
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(registerDto.password, saltRounds);

    // 3. Simpan user baru ke database
    const newUser = await this.prisma.user.create({
      data: {
        name: registerDto.name,
        email: registerDto.email,
        password: hashedPassword,
        phone: registerDto.phone,
        imageUrl: registerDto.imageUrl,
        address: registerDto.address,
        addresses: registerDto.address
          ? {
              create: {
                label: 'Utama',
                name: registerDto.name,
                phone: registerDto.phone ?? '-',
                detail: registerDto.address,
                isDefault: true,
              },
            }
          : undefined,
      },
    });

    // 4. Kembalikan respons sukses (tanpa membocorkan password!)
    return {
      message: 'Registrasi berhasil',
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
      },
    };
  }

  async getProfile(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        imageUrl: true,
        address: true,
        addresses: {
          select: {
            id: true,
            label: true,
            name: true,
            phone: true,
            detail: true,
            isDefault: true,
          },
          orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User tidak ditemukan');
    }

    return {
      message: 'Profil berhasil diambil',
      user,
    };
  }

  async updateProfile(userId: number, updateProfileDto: UpdateProfileDto) {
    const currentUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!currentUser) {
      throw new NotFoundException('User tidak ditemukan');
    }

    if (
      updateProfileDto.email &&
      updateProfileDto.email !== currentUser.email
    ) {
      const existingUser = await this.prisma.user.findUnique({
        where: { email: updateProfileDto.email },
      });

      if (existingUser) {
        throw new ConflictException(
          'Email sudah terdaftar, silakan gunakan email lain',
        );
      }
    }

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        name: updateProfileDto.name,
        email: updateProfileDto.email,
        phone: updateProfileDto.phone,
        imageUrl: updateProfileDto.imageUrl,
        address: updateProfileDto.address,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        imageUrl: true,
        address: true,
        addresses: {
          select: {
            id: true,
            label: true,
            name: true,
            phone: true,
            detail: true,
            isDefault: true,
          },
          orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
        },
      },
    });

    return {
      message: 'Profil berhasil diperbarui',
      user,
    };
  }
}
