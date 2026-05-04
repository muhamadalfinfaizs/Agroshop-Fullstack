/// App constants untuk nilai-nilai yang sering digunakan
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'AgroShop';
  static const String appTagline = 'Toko Pertanian Terpercaya';

  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 24.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Image sizes
  static const double thumbnailS = 60.0;
  static const double thumbnailM = 80.0;
  static const double thumbnailL = 120.0;

  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 12.0;
  static const double gridChildAspectRatio = 0.7;

  // Animation
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

// API Constants
  static const String baseUrl = 'http://10.0.2.2:3000'; // Khusus Emulator Android
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Endpoints (Sesuaikan jika path di NestJS kamu berbeda)
  static const String endpointCategories = '/categories'; 
  static const String endpointProducts = '/products';
  static const String endpointBanners = '/banners';
  static const String endpointLogin = '/auth/login'; // Sesuaikan jika path auth NestJS kamu berbeda
}