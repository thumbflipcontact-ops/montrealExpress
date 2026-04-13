import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/widgets/product_image.dart';

/// Product image gallery with thumbnails and zoom
/// 
/// Features:
/// - Multiple image support with swipe
/// - Thumbnail navigation
/// - Page indicators
/// - Pinch-to-zoom support
/// - Hero animation support
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String? heroTag;
  final VoidCallback? onTap;
  final int initialIndex;

  const ProductImageGallery({
    super.key,
    required this.images,
    this.heroTag,
    this.onTap,
    this.initialIndex = 0,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  void _onThumbnailTap(int index) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Column(
      children: [
        // Main image carousel
        Expanded(
          child: GestureDetector(
            onTap: widget.onTap,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return _buildImagePage(image, index);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnails
        if (widget.images.length > 1)
          _buildThumbnails(),
        const SizedBox(height: 8),
        // Page indicator
        if (widget.images.length > 1)
          _buildPageIndicator(),
      ],
    );
  }

  Widget _buildImagePage(String imageUrl, int index) {
    Widget imageWidget = InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      onInteractionStart: (_) => setState(() => _isZoomed = true),
      onInteractionEnd: (_) => setState(() => _isZoomed = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.medium,
        ),
        clipBehavior: Clip.antiAlias,
        child: widget.heroTag != null && index == 0
            ? Hero(
                tag: widget.heroTag!,
                child: ProductImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              )
            : ProductImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
      ),
    );

    return imageWidget
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildThumbnails() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () => _onThumbnailTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryMain
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected ? AppShadows.small : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSecondary,
                  child: ProductImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                delay: Duration(milliseconds: index * 50),
              );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.images.asMap().entries.map((entry) {
        final isSelected = entry.key == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected
                ? AppColors.primaryMain
                : AppColors.textDisabled,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 64,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Full screen image viewer with zoom
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: widget.heroTag != null && index == 0
                      ? Hero(
                          tag: widget.heroTag!,
                          child: ProductImage(
                            imageUrl: widget.images[index],
                            fit: BoxFit.contain,
                          ),
                        )
                      : ProductImage(
                          imageUrl: widget.images[index],
                          fit: BoxFit.contain,
                        ),
                ),
              );
            },
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Page indicator
          if (widget.images.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  final isSelected = entry.key == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  );
                }).toList(),
              ),
            ),
          // Image counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
