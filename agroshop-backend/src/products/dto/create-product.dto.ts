export class CreateProductDto {
  name!: string;
  description!: string;
  price!: number;
  discountPrice?: number;
  imageUrl!: string;
  images!: string[];
  stock!: number;
  isFeatured?: boolean;
  isAvailable?: boolean;
  unit!: string;
  categoryId!: number;
}
