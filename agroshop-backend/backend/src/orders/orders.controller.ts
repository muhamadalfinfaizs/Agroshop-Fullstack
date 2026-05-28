import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

@UseGuards(JwtAuthGuard)
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post('checkout')
  checkout(@Req() req: any, @Body() createOrderDto: CreateOrderDto) {
    return this.ordersService.checkout(req.user.userId, createOrderDto);
  }

  @Get()
  findAll(@Req() req: any) {
    return this.ordersService.findAll(req.user.userId);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Get('admin/all')
  findAllAdmin() {
    return this.ordersService.findAllAdmin();
  }

  @Get(':orderCode')
  findOne(@Req() req: any, @Param('orderCode') orderCode: string) {
    return this.ordersService.findOne(req.user.userId, orderCode);
  }
}
