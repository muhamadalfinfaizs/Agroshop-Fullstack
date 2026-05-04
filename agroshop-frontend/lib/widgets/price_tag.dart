import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

/// Reusable Price Tag widget
/// Menampilkan harga dengan opsi diskon
class PriceTag extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final TextStyle? priceStyle;
  final TextStyle? discountStyle;
  final bool showDiscountPercent;
  final bool compact;

  const PriceTag({
    super.key,
    required this.price,
    this.discountPrice,
    this.priceStyle,
    this.discountStyle,
    this.showDiscountPercent = true,
    this.compact = false,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  @override
  Widget build(BuildContext context) {
    if (hasDiscount) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Discount price
          Text(
            _formatPrice(discountPrice!),
            style: priceStyle ??
                TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          // Original price
          Text(
            _formatPrice(price),
            style: discountStyle ??
                TextStyle(
                  fontSize: compact ? 12 : 14,
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          if (showDiscountPercent) ...[
            const SizedBox(width: AppConstants.paddingS),
            // Discount badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                '-${_getDiscountPercent()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // No discount
    return Text(
      _formatPrice(price),
      style: priceStyle ??
          TextStyle(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  String _formatPrice(double price) {
    if (compact) {
      if (price >= 1000000) {
        return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
      } else if (price >= 1000) {
        return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
      }
    }
    return 'Rp ${_formatNumber(price)}';
  }

  String _formatNumber(double number) {
    String result = number.toStringAsFixed(0);
    StringBuffer sb = StringBuffer();
    int count = 0;
    for (int i = result.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        sb.write('.');
      }
      sb.write(result[i]);
      count++;
    }
    return sb.toString().split('').reversed.join();
  }

  int _getDiscountPercent() {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100).round();
  }
}