import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // 1. Ambil label role apa yang dibutuhkan dari Controller (misal: 'ADMIN')
    const requiredRoles = this.reflector.get<string[]>(
      'roles',
      context.getHandler(),
    );

    // Jika rute tidak dilabeli role apa-apa, biarkan masuk
    if (!requiredRoles) {
      return true;
    }

    // 2. Ambil data user yang sedang login dari request
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // 3. Cek apakah role user ada di dalam daftar role yang diizinkan
    if (!requiredRoles.includes(user.role)) {
      throw new ForbiddenException(
        'Akses ditolak: Hanya Admin yang dapat melakukan aksi ini',
      );
    }

    return true;
  }
}
