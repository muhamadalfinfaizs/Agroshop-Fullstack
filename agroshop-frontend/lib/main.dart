import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/app_constants.dart';
import 'core/app_routes.dart';
import 'features/auth/splash_screen.dart';

/// Main Application Entry Point
void main() {
  runApp(const AgroShopApp());
}

class AgroShopApp extends StatelessWidget {
  const AgroShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // NYALAKAN KEMBALI ROUTING INI
      onGenerateRoute: AppRoutes.generateRoute,
      
      // Jadikan Splash Screen sebagai pintu gerbang utama
      home: const SplashScreen(),
    );
  }
}