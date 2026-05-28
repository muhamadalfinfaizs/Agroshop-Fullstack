import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

@Injectable()
export class AddressesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: number, createAddressDto: CreateAddressDto) {
    try {
      const address = await this.prisma.$transaction(async (tx) => {
        const totalAddress = await tx.address.count({ where: { userId } });
        const shouldBeDefault = createAddressDto.isDefault ?? totalAddress === 0;

        if (shouldBeDefault) {
          await tx.address.updateMany({
            where: { userId },
            data: { isDefault: false },
          });
        }

        const createdAddress = await tx.address.create({
          data: {
            label: createAddressDto.label,
            name: createAddressDto.name,
            phone: createAddressDto.phone,
            detail: createAddressDto.detail,
            isDefault: shouldBeDefault,
            userId,
          },
        });

        if (createdAddress.isDefault) {
          await tx.user.update({
            where: { id: userId },
            data: { address: createdAddress.detail, phone: createdAddress.phone },
          });
        }

        return createdAddress;
      });

      return {
        success: true,
        message: 'Alamat berhasil ditambahkan',
        metadata: { status: HttpStatus.CREATED },
        data: this.formatAddress(address),
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal menambahkan alamat',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async findAll(userId: number) {
    const addresses = await this.prisma.address.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });

    return {
      success: true,
      message: 'Berhasil mengambil alamat pengiriman',
      metadata: { status: HttpStatus.OK, total_data: addresses.length },
      data: addresses.map((address) => this.formatAddress(address)),
    };
  }

  async update(userId: number, id: number, updateAddressDto: UpdateAddressDto) {
    try {
      const address = await this.findOwnedAddress(userId, id);

      if (address.isDefault && updateAddressDto.isDefault === false) {
        throw new BadRequestException({
          success: false,
          message: 'Alamat utama tidak bisa langsung dinonaktifkan',
          metadata: { status: HttpStatus.BAD_REQUEST },
        });
      }

      const updatedAddress = await this.prisma.$transaction(async (tx) => {
        if (updateAddressDto.isDefault === true) {
          await tx.address.updateMany({
            where: { userId },
            data: { isDefault: false },
          });
        }

        const updated = await tx.address.update({
          where: { id },
          data: {
            label: updateAddressDto.label,
            name: updateAddressDto.name,
            phone: updateAddressDto.phone,
            detail: updateAddressDto.detail,
            isDefault: updateAddressDto.isDefault,
          },
        });

        if (updated.isDefault) {
          await tx.user.update({
            where: { id: userId },
            data: { address: updated.detail, phone: updated.phone },
          });
        }

        return updated;
      });

      return {
        success: true,
        message: 'Alamat berhasil diperbarui',
        metadata: { status: HttpStatus.OK },
        data: this.formatAddress(updatedAddress),
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new BadRequestException({
        success: false,
        message: 'Gagal memperbarui alamat',
        metadata: { status: HttpStatus.BAD_REQUEST },
      });
    }
  }

  async setDefault(userId: number, id: number) {
    const address = await this.findOwnedAddress(userId, id);

    const updatedAddress = await this.prisma.$transaction(async (tx) => {
      await tx.address.updateMany({
        where: { userId },
        data: { isDefault: false },
      });

      const updated = await tx.address.update({
        where: { id: address.id },
        data: { isDefault: true },
      });

      await tx.user.update({
        where: { id: userId },
        data: { address: updated.detail, phone: updated.phone },
      });

      return updated;
    });

    return {
      success: true,
      message: 'Alamat utama berhasil dipilih',
      metadata: { status: HttpStatus.OK },
      data: this.formatAddress(updatedAddress),
    };
  }

  async remove(userId: number, id: number) {
    const address = await this.findOwnedAddress(userId, id);

    await this.prisma.$transaction(async (tx) => {
      await tx.address.delete({ where: { id: address.id } });

      if (!address.isDefault) {
        return;
      }

      const nextDefault = await tx.address.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });

      if (!nextDefault) {
        await tx.user.update({
          where: { id: userId },
          data: { address: null },
        });
        return;
      }

      const updatedDefault = await tx.address.update({
        where: { id: nextDefault.id },
        data: { isDefault: true },
      });

      await tx.user.update({
        where: { id: userId },
        data: { address: updatedDefault.detail, phone: updatedDefault.phone },
      });
    });

    return {
      success: true,
      message: 'Alamat berhasil dihapus',
      metadata: { status: HttpStatus.OK },
    };
  }

  private async findOwnedAddress(userId: number, id: number) {
    const address = await this.prisma.address.findFirst({
      where: { id, userId },
    });

    if (!address) {
      throw new NotFoundException({
        success: false,
        message: 'Alamat tidak ditemukan',
        metadata: { status: HttpStatus.NOT_FOUND },
      });
    }

    return address;
  }

  private formatAddress(address: any) {
    return {
      id: address.id,
      label: address.label,
      name: address.name,
      phone: address.phone,
      detail: address.detail,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
    };
  }
}
