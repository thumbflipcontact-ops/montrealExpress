import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/widgets/product_image.dart';
import 'package:abdoul_express/model/product.dart';

/// Organic product card with irregular rounded corners, slight rotation,
/// colored shadow, and asymmetric layout for staggered grid
class OrganicProductCard extends StatefulWidget {
  const OrganicProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.isFavorite = false,
    this.height,
    this.rotation,
    this.irregularity = 0.1,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final double? height;
  final double? rotation; // In degrees
  final double irregularity;

  @override
  State<OrganicProductCard> createState() => _OrganicProductCardState();
}

class _OrganicProductCardState extends State<OrganicProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get category gradient for colored shadow
    final categoryGradient = AppColors.getCategoryGradient(widget.product.category);
    final shadowColor = categoryGradient.first;

    // Slight random rotation for organic feel (-2 to +2 degrees)
    final rotation = widget.rotation ??
        ((widget.product.id.hashCode % 400) - 200) / 100.0;

    // Generate unique seed for this product
    final seed = widget.product.id.hashCode;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: rotation * math.pi / 180,
              child: Transform.translate(
                offset: Offset(0, -_elevationAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.createColoredShadow(
                        color: shadowColor,
                        opacity: 0.15 + (_isHovered ? 0.05 : 0.0),
                        blurRadius: 14 + _elevationAnimation.value,
                        offset: Offset(0, 5 + _elevationAnimation.value / 2),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                16 + (seed % 4) * widget.irregularity,
              ),
              topRight: Radius.circular(
                16 + ((seed ~/ 4) % 4) * widget.irregularity,
              ),
              bottomLeft: Radius.circular(
                16 + ((seed ~/ 8) % 4) * widget.irregularity,
              ),
              bottomRight: Radius.circular(
                16 + ((seed ~/ 12) % 4) * widget.irregularity,
              ),
            ),
            child: Container(
              color: AppColors.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  Expanded(child: _buildContentSection()),
                  _buildPriceSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Product image - extends slightly beyond bounds
        AspectRatio(
          aspectRatio: 1,
          child: Hero(
            tag: 'product-${widget.product.id}',
            child: ProductImage(
              imageUrl: widget.product.imageUrl,
              assetPath: widget.product.imageAsset,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay for better text contrast
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // Favorite button
        Positioned(
          top: 8,
          right: 8,
          child: _buildFavoriteButton(),
        ),

        // Rating badge
        if (widget.product.rating > 0)
          Positioned(
            top: 8,
            left: 8,
            child: _buildRatingBadge(),
          ),

        // Add to cart button (appears on hover)
        if (_isHovered)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: _buildAddToCartButton(),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return _HeartBurstButton(
      isFavorite: widget.isFavorite,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onFavoriteToggle?.call();
      },
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            widget.product.rating.toStringAsFixed(1),
            style: AppTypography.badgeStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onAddToCart?.call();
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryMain, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.button,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'AJOUTER',
                  style: AppTypography.badgeStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category chip
          _buildCategoryChip(),
          const SizedBox(height: 6),

          // Product title
          Text(
            widget.product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.buildTextTheme(Brightness.light)
                .titleMedium!
                .copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.product.category.toUpperCase(),
        style: AppTypography.categoryChipStyle(
          color: AppColors.textSecondary,
        ).copyWith(fontSize: 9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${widget.product.price.toStringAsFixed(0)} F CFA',
              style: AppTypography.priceStyle(
                color: AppColors.primaryMain,
              ).copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Heart burst button with animation on favorite toggle
class _HeartBurstButton extends StatefulWidget {
  const _HeartBurstButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  State<_HeartBurstButton> createState() => _HeartBurstButtonState();
}

class _HeartBurstButtonState extends State<_HeartBurstButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _previousFavorite = false;

  @override
  void initState() {
    super.initState();
    _previousFavorite = widget.isFavorite;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_HeartBurstButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only trigger animation when becoming favorite (not when unfavoriting)
    if (widget.isFavorite && !_previousFavorite) {
      _controller.forward(from: 0);
    }
    _previousFavorite = widget.isFavorite;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: AppShadows.small,
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isFavorite),
              color: widget.isFavorite ? AppColors.errorMain : AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
