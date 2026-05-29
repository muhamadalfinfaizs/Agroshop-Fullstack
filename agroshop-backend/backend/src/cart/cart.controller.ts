import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards, // <-- Tambahan
  Req, // <-- Tambahan
} from '@nestjs/common';
import { CartService } from './cart.service';
import { CreateCartDto } from './dto/create-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard'; // <-- Import Satpam JWT

// Pasang satpam di level Controller agar SEMUA rute Cart terkunci
@UseGuards(JwtAuthGuard)
@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Post()
  create(@Req() req: any, @Body() createCartDto: CreateCartDto) {
    createCartDto.userId = req.user.userId;

    return this.cartService.create(createCartDto);
  }

  @Get()
  findAll(@Req() req: any) {
    return this.cartService.findAll(req.user.userId);
  }

  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.cartService.findOne(req.user.userId, +id);
  }

  @Patch(':id')
  update(
    @Req() req: any,
    @Param('id') id: string,
    @Body() updateCartDto: UpdateCartDto,
  ) {
    return this.cartService.update(req.user.userId, +id, updateCartDto);
  }

  @Delete()
  clear(@Req() req: any) {
    return this.cartService.clear(req.user.userId);
  }

  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.cartService.remove(req.user.userId, +id);
  }
}

