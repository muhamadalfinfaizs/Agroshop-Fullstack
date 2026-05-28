export class CreateUserDto {
  email!: string;
  password!: string;
  name!: string;
  phone?: string;
  address?: string;
  imageUrl?: string;
}
