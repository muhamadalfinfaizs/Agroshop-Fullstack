import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Mengaktifkan CORS agar frontend Web bisa terhubung (sesuai update terbaru)
  app.enableCors();
  
  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();

