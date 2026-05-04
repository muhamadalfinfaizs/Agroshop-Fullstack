import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/category.dart';

/// Reusable Category Card widget
/// Menampilkan kategori dengan icon dan jumlah produk
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? AppColors.primary : AppColors.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingS),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : _getCategoryColor(category.name).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  size: AppConstants.iconL,
                  color: isSelected ? Colors.white : _getCategoryColor(category.name),
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              // Name
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Product count
              Text(
                '${category.productCount} produk',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'eco':
        return Icons.eco;
      case 'grass':
        return Icons.grass;
      case 'agriculture':
        return Icons.agriculture;
      case 'bug_report':
        return Icons.bug_report;
      case 'compost':
        return Icons.compost;
      case 'local_florist':
        return Icons.local_florist;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'pupuk':
        return AppColors.fertilizer;
      case 'bibit & benih':
        return AppColors.seeds;
      case 'alat pertanian':
        return AppColors.tools;
      case 'pestisida':
        return AppColors.pesticides;
      case 'pupuk organik':
        return AppColors.primary;
      case 'media tanam':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}