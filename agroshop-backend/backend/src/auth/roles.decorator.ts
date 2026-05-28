import { SetMetadata } from '@nestjs/common';

// Ini akan kita pakai sebagai @Roles('ADMIN') di Controller
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);
