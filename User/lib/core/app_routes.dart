import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/product/product_list_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/main_navigation_screen.dart';

/// App Routes - Konfigurasi named routes untuk navigasi
/// Menggunakan pattern sederhana yang mudah di-extend untuk Navigator 2.0
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String productList = '/products';
  static const String productDetail = '/product';
  static const String cart = '/cart';
  static const String profile = '/profile';

  /// Route generator - Membuat route berdasarkan nama
  /// Untuk future: bisa di-extend ke Navigator 2.0 dengan RouteInformationParser
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );

      case productList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductListScreen(
            categoryId: args?['categoryId'] as int?,
            categoryName: args?['categoryName'] as String?,
            isFeatured: args?['isFeatured'] as bool? ?? false,
          ),
          settings: settings,
        );

      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: args['product'] as dynamic,
          ),
          settings: settings,
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }

  /// Helper methods untuk navigasi
  static void goToProductList(
    BuildContext context, {
    int? categoryId,
    String? categoryName,
    bool isFeatured = false,
  }) {
    Navigator.pushNamed(
      context,
      productList,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isFeatured': isFeatured,
      },
    );
  }

  static void goToProductDetail(BuildContext context, dynamic product) {
    Navigator.pushNamed(
      context,
      productDetail,
      arguments: {'product': product},
    );
  }

  static void goToCart(BuildContext context) {
    Navigator.pushNamed(context, cart);
  }

  static void goToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }
}