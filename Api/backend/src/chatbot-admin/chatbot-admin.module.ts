import { Module } from '@nestjs/common';
import { ChatbotAdminController } from './chatbot-admin.controller';
import { ChatbotAdminService } from './chatbot-admin.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ChatbotAdminController],
  providers: [ChatbotAdminService],
})
export class ChatbotAdminModule {}
