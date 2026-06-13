import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ProductsModule } from './products/products.module';
import { PrismaModule } from './prisma/prisma.module';
import { CategoriesModule } from './categories/categories.module';
import { BannersModule } from './banners/banners.module';
import { UsersModule } from './users/users.module';
import { CartModule } from './cart/cart.module';
import { AuthModule } from './auth/auth.module';
import { OrdersModule } from './orders/orders.module';
import { AddressesModule } from './addresses/addresses.module';
import { ShipmentsModule } from './shipments/shipments.module';
import { ChatbotModule } from './chatbot/chatbot.module';
import { ChatbotAdminModule } from './chatbot-admin/chatbot-admin.module';

@Module({
  imports: [
    ProductsModule,
    PrismaModule,
    CategoriesModule,
    BannersModule,
    UsersModule,
    CartModule,
    AuthModule,
    OrdersModule,
    AddressesModule,
    ShipmentsModule,
    ChatbotModule,
    ChatbotAdminModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
