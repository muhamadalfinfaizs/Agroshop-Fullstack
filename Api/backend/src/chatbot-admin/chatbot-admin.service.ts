import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChatbotAdminService {
  constructor(private prisma: PrismaService) {}

  async findAllIntents() {
    return this.prisma.intent.findMany({
      include: {
        Keyword: true,
        Response: true,
      },
      orderBy: { id: 'desc' },
    });
  }

  async createIntent(data: { name: string; description?: string; keywords: string[]; responseText: string; solution?: string; recommendProduct?: string }) {
    const now = new Date();
    return this.prisma.intent.create({
      data: {
        name: data.name,
        description: data.description,
        updatedAt: now,
        Keyword: {
          create: data.keywords.map((kw) => ({ keyword: kw, updatedAt: now })),
        },
        Response: {
          create: [
            {
              text: data.responseText,
              solution: data.solution,
              recommendProduct: data.recommendProduct,
              updatedAt: now,
            },
          ],
        },
      },
      include: {
        Keyword: true,
        Response: true,
      },
    });
  }

  async updateIntent(
    id: number,
    data: { name: string; description?: string; keywords: string[]; responseText: string; solution?: string; recommendProduct?: string },
  ) {
    const intent = await this.prisma.intent.findUnique({ where: { id } });
    if (!intent) throw new NotFoundException('Intent not found');

    // Delete existing keywords and responses
    await this.prisma.keyword.deleteMany({ where: { intentId: id } });
    await this.prisma.response.deleteMany({ where: { intentId: id } });

    // Update and recreate
    const now = new Date();
    return this.prisma.intent.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        updatedAt: now,
        Keyword: {
          create: data.keywords.map((kw) => ({ keyword: kw, updatedAt: now })),
        },
        Response: {
          create: [
            {
              text: data.responseText,
              solution: data.solution,
              recommendProduct: data.recommendProduct,
              updatedAt: now,
            },
          ],
        },
      },
      include: {
        Keyword: true,
        Response: true,
      },
    });
  }

  async deleteIntent(id: number) {
    // Delete cascading is configured in Prisma schema (onDelete: Cascade)
    return this.prisma.intent.delete({
      where: { id },
    });
  }
}
