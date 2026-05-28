import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: any, user: any) {
    // Jika ada error atau user tidak ditemukan (token salah/expired)
    if (err || !user) {
      throw err || new UnauthorizedException('Sesi habis atau token tidak valid, silakan login kembali');
    }
    return user;
  }
}
