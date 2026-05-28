import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy'; // <--- 1. Import JwtStrategy di sini

@Module({
  imports: [
    PrismaModule,
    JwtModule.register({
      secret: 'Akudevalfin',
      signOptions: { expiresIn: '1d' }, // Token berlaku 1 hari
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy, // <--- 2. Daftarkan di sini agar satpamnya aktif
  ],
})
export class AuthModule {}
