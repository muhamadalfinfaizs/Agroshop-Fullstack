import { ConflictException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function conflictProduct(
  name: string,
  errorMessage: string,
  prisma: PrismaService,
) {
  const existingProduct = await prisma.product.findFirst({
    where: { name: name },
  });

  if (existingProduct) {
    throw new ConflictException({
      success: false,
      message: errorMessage,
      metadata: {
        status: HttpStatus.CONFLICT,
      },
    });
  }

  return name;
}
