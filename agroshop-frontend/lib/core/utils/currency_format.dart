import 'package:intl/intl.dart';

/// Memformat angka (double) menjadi string harga rupiah ribuan
/// Contoh: 15000 -> 15.000
String formatPrice(double price) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  ).format(price).replaceAll('Rp', '').trim();
}
