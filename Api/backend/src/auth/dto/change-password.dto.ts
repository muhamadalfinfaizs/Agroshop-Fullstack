import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty({ message: 'Password lama tidak boleh kosong' })
  oldPassword: string;

  @IsString()
  @IsNotEmpty({ message: 'Password baru tidak boleh kosong' })
  @MinLength(6, { message: 'Password baru minimal 6 karakter' })
  newPassword: string;
}
