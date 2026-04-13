import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProductImage extends StatefulWidget {
  const ProductImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  final String? imageUrl;
  final String? assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  bool _useCache = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() => _initialized = true);
      return;
    }
    // Initialize the image state
    setState(() {
      _useCache = false;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return _placeholder(context);
    }
    final imageUrl = widget.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty && _useCache) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => _placeholder(context),
        errorWidget: (context, url, err) => _fallbackImage(),
      );
    }
    if (imageUrl != null && imageUrl.isNotEmpty && !_useCache) {
      // Fallback to Image.network with loadingBuilder
      return Image.network(
        imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder(context);
        },
        errorBuilder: (context, error, st) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    if (widget.assetPath != null && widget.assetPath!.isNotEmpty) {
      return Image.asset(
        widget.assetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _placeholder(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.grey[300],
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
