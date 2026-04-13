import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/product.dart';
import 'theme/typography.dart';
import 'widgets/product_image.dart';
export 'widgets/niger_phone_field.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.expanded = true,
  });
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, color: colorScheme.onPrimary),
          ),
        Text(label, style: AppTypography.buttonStyle(color: colorScheme.onPrimary)),
      ],
    );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: child,
    );

    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: expanded
            ? SizedBox(
                width: double.infinity,
                child: Center(child: button),
              )
            : button,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    required this.isFavorite,
    required this.onFavToggle,
    this.onAddToCart,
  });
  final Product product;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback onFavToggle;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'pimg-${product.id}',
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        assetPath: product.imageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      onTap: onFavToggle,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                  if (onAddToCart != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+ AJOUTER',
                            style: AppTypography.buttonStyle(color: cs.onPrimary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${product.price.toStringAsFixed(0)} F CFA',
                        style: AppTypography.priceStyle(color: cs.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🔢 [QuantityStepper] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(
          Icons.remove,
          onTap: () {
            final newValue = value - 1;
            _logDebug('Minus clicked: $value -> $newValue');
            if (newValue >= min) {
              onChanged(newValue);
            }
          },
          color: color,
          enabled: value > min,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$value', style: Theme.of(context).textTheme.titleMedium),
        ),
        _iconBtn(
          Icons.add,
          onTap: () {
            final newValue = value + 1;
            _logDebug('Plus clicked: $value -> $newValue');
            onChanged(newValue);
          },
          color: color,
          enabled: true,
        ),
      ],
    );
  }

  Widget _iconBtn(
    IconData icon, {
    required VoidCallback onTap,
    required Color color,
    required bool enabled,
  }) {
    final effectiveColor = enabled ? color : color.withValues(alpha: 0.3);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: effectiveColor),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
