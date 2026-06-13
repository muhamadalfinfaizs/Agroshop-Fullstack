import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ChatbotService } from './chatbot.service';

@Controller('chatbot')
export class ChatbotController {
  constructor(private readonly chatbotService: ChatbotService) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async processMessage(@Body() body: { message: string; history?: string[] }) {
    if (!body.message || body.message.trim() === '') {
      return { reply: 'Silakan ketik pertanyaan Anda.', products: [] };
    }
    const response = await this.chatbotService.processMessage(body.message, body.history);
    return response; // akan return { reply: ..., products: ... }
  }
}
