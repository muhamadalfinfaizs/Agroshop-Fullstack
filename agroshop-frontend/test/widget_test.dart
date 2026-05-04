// Basic widget test for AgroShop app
import 'package:flutter_test/flutter_test.dart';
import 'package:agroshop/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const AgroShopApp());
    
    // Verify that the app loads with bottom navigation
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}