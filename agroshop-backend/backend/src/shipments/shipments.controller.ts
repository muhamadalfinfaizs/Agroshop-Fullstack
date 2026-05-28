import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { CreateShipmentEventDto } from './dto/create-shipment-event.dto';
import { UpdateShipmentDto } from './dto/update-shipment.dto';
import { ShipmentsService } from './shipments.service';

@UseGuards(JwtAuthGuard)
@Controller('shipments')
export class ShipmentsController {
  constructor(private readonly shipmentsService: ShipmentsService) {}

  @Get('orders/:orderCode')
  findByOrder(@Req() req: any, @Param('orderCode') orderCode: string) {
    return this.shipmentsService.findByOrder(req.user.userId, orderCode);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Patch('orders/:orderCode')
  update(
    @Param('orderCode') orderCode: string,
    @Body() updateShipmentDto: UpdateShipmentDto,
  ) {
    return this.shipmentsService.updateByOrder(orderCode, updateShipmentDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Post('orders/:orderCode/events')
  addEvent(
    @Param('orderCode') orderCode: string,
    @Body() createShipmentEventDto: CreateShipmentEventDto,
  ) {
    return this.shipmentsService.addEvent(orderCode, createShipmentEventDto);
  }
}
