import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { User } from '@prisma/client';

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
}
