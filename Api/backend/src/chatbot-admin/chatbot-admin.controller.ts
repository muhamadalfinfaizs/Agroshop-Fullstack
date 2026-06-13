import { Controller, Get, Post, Put, Delete, Body, Param } from '@nestjs/common';
import { ChatbotAdminService } from './chatbot-admin.service';

@Controller('admin/chatbot/intents')
export class ChatbotAdminController {
  constructor(private readonly chatbotAdminService: ChatbotAdminService) {}

  @Get()
  async findAll() {
    const data = await this.chatbotAdminService.findAllIntents();
    return { success: true, data };
  }

  @Post()
  async create(
    @Body() body: { name: string; description?: string; keywords: string[]; responseText: string; solution?: string; recommendProduct?: string },
  ) {
    const data = await this.chatbotAdminService.createIntent(body);
    return { success: true, message: 'Berhasil membuat intent', data };
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() body: { name: string; description?: string; keywords: string[]; responseText: string; solution?: string; recommendProduct?: string },
  ) {
    const data = await this.chatbotAdminService.updateIntent(Number(id), body);
    return { success: true, message: 'Berhasil update intent', data };
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.chatbotAdminService.deleteIntent(Number(id));
    return { success: true, message: 'Berhasil hapus intent' };
  }
}
