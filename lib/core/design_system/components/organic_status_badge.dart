import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

/// Organic status badge with blob-shaped background and status-specific gradients
///
/// Features:
/// - Blob-shaped background
/// - Status-specific gradient colors
/// - Pulsing animation for active statuses
/// - Icon + text layout
/// - Responsive sizing
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrganicStatusBadge extends StatefulWidget {
  const OrganicStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.showIcon = true,
    this.animate = true,
    this.size = BadgeSize.medium,
  });

  final OrderStatus status;
  final String? label;
  final bool showIcon;
  final bool animate;
  final BadgeSize size;

  @override
  State<OrganicStatusBadge> createState() => _OrganicStatusBadgeState();
}

class _OrganicStatusBadgeState extends State<OrganicStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate && _shouldPulse(widget.status)) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OrganicStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status || oldWidget.animate != widget.animate) {
      if (widget.animate && _shouldPulse(widget.status)) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _shouldPulse(OrderStatus status) {
    return status == OrderStatus.processing ||
           status == OrderStatus.shipped ||
           status == OrderStatus.confirmed;
  }

  List<Color> _getGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.pendingGradient;
      case OrderStatus.confirmed:
        return AppColors.confirmedGradient;
      case OrderStatus.processing:
        return AppColors.processingGradient;
      case OrderStatus.shipped:
        return AppColors.shippedGradient;
      case OrderStatus.delivered:
        return AppColors.deliveredGradient;
      case OrderStatus.cancelled:
        return AppColors.cancelledGradient;
    }
  }

  IconData _getIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getLabel(OrderStatus status) {
    if (widget.label != null) return widget.label!;

    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmé';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.shipped:
        return 'Expédié';
      case OrderStatus.delivered:
        return 'Livré';
      case OrderStatus.cancelled:
        return 'Annulé';
    }
  }

  double _getPadding() {
    switch (widget.size) {
      case BadgeSize.small:
        return 8.0;
      case BadgeSize.medium:
        return 12.0;
      case BadgeSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case BadgeSize.small:
        return 14.0;
      case BadgeSize.medium:
        return 16.0;
      case BadgeSize.large:
        return 20.0;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case BadgeSize.small:
        return 11.0;
      case BadgeSize.medium:
        return 13.0;
      case BadgeSize.large:
        return 15.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient(widget.status);
    final icon = _getIcon(widget.status);
    final label = _getLabel(widget.status);

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getPadding() * 1.5,
        vertical: _getPadding(),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.createColoredShadow(
          color: gradient.first,
          opacity: 0.3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: Colors.white,
            ),
            SizedBox(width: _getPadding() * 0.5),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (widget.animate && _shouldPulse(widget.status)) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }
}

enum BadgeSize {
  small,
  medium,
  large,
}

/// Compact status indicator (dot only)
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.status,
    this.size = 8.0,
    this.withPulse = false,
  });

  final OrderStatus status;
  final double size;
  final bool withPulse;

  List<Color> _getGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.pendingGradient;
      case OrderStatus.confirmed:
        return AppColors.confirmedGradient;
      case OrderStatus.processing:
        return AppColors.processingGradient;
      case OrderStatus.shipped:
        return AppColors.shippedGradient;
      case OrderStatus.delivered:
        return AppColors.deliveredGradient;
      case OrderStatus.cancelled:
        return AppColors.cancelledGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
