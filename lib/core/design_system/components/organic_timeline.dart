import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

/// Timeline item data model
class TimelineItem {
  final String title;
  final String? subtitle;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isActive;
  final IconData? icon;
  final Widget? customContent;

  const TimelineItem({
    required this.title,
    this.subtitle,
    this.timestamp,
    this.isCompleted = false,
    this.isActive = false,
    this.icon,
    this.customContent,
  });
}

/// Organic timeline with blob markers and gradient connecting lines
///
/// Features:
/// - Vertical blob markers for each step
/// - Gradient connecting lines
/// - Completed/active/pending states
/// - Expandable details
/// - Timestamps
/// - Custom content support
class OrganicTimeline extends StatelessWidget {
  const OrganicTimeline({
    super.key,
    required this.items,
    this.gradient,
    this.lineWidth = 3.0,
    this.markerSize = 24.0,
    this.spacing = 32.0,
  });

  final List<TimelineItem> items;
  final List<Color>? gradient;
  final double lineWidth;
  final double markerSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? [AppColors.primaryMain, AppColors.primaryDark];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return _TimelineItemWidget(
          item: item,
          gradient: effectiveGradient,
          lineWidth: lineWidth,
          markerSize: markerSize,
          spacing: spacing,
          showLine: !isLast,
        );
      },
    );
  }
}

class _TimelineItemWidget extends StatefulWidget {
  const _TimelineItemWidget({
    required this.item,
    required this.gradient,
    required this.lineWidth,
    required this.markerSize,
    required this.spacing,
    required this.showLine,
  });

  final TimelineItem item;
  final List<Color> gradient;
  final double lineWidth;
  final double markerSize;
  final double spacing;
  final bool showLine;

  @override
  State<_TimelineItemWidget> createState() => _TimelineItemWidgetState();
}

class _TimelineItemWidgetState extends State<_TimelineItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.item.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<Color> _getMarkerGradient(ColorScheme colorScheme) {
    if (widget.item.isCompleted) {
      return AppColors.deliveredGradient;
    } else if (widget.item.isActive) {
      return widget.gradient;
    } else {
      return [colorScheme.onSurfaceVariant.withValues(alpha: 0.7), colorScheme.onSurfaceVariant.withValues(alpha: 0.7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerGradient = _getMarkerGradient(colorScheme);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline marker and line
          SizedBox(
            width: widget.markerSize,
            child: Column(
              children: [
                // Marker (blob)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.item.isActive ? _pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Container(
                    width: widget.markerSize,
                    height: widget.markerSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: markerGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: widget.item.isActive || widget.item.isCompleted
                          ? AppShadows.createColoredShadow(
                              color: markerGradient.first,
                              opacity: 0.4,
                            )
                          : null,
                    ),
                    child: widget.item.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : widget.item.icon != null
                            ? Icon(
                                widget.item.icon,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                  ),
                ),
                // Connecting line
                if (widget.showLine)
                  Expanded(
                    child: Container(
                      width: widget.lineWidth,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.item.isCompleted
                              ? markerGradient
                              : [
                                  colorScheme.outlineVariant,
                                  colorScheme.outlineVariant,
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(widget.lineWidth / 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and timestamp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.item.isCompleted || widget.item.isActive
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (widget.item.timestamp != null)
                        Text(
                          _formatTimestamp(widget.item.timestamp!),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                  // Subtitle
                  if (widget.item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.item.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  // Custom expandable content
                  if (widget.item.customContent != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Row(
                        children: [
                          Text(
                            _isExpanded ? 'Voir moins' : 'Voir plus',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.gradient.first,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: widget.gradient.first,
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: widget.item.customContent!,
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return "À l'instant";
        }
        return '${difference.inMinutes}min';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

/// Horizontal timeline variant for compact displays
class HorizontalTimeline extends StatelessWidget {
  const HorizontalTimeline({
    super.key,
    required this.items,
    this.gradient,
    this.markerSize = 32.0,
  });

  final List<TimelineItem> items;
  final List<Color>? gradient;
  final double markerSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveGradient = gradient ?? [AppColors.primaryMain, AppColors.primaryDark];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          items.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              // Connecting line
              final itemIndex = index ~/ 2;
              final item = items[itemIndex];
              return Container(
                width: 40,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.isCompleted
                        ? effectiveGradient
                        : [colorScheme.outlineVariant, colorScheme.outlineVariant],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            } else {
              // Timeline item
              final itemIndex = index ~/ 2;
              final item = items[itemIndex];
              return _HorizontalTimelineItem(
                item: item,
                gradient: effectiveGradient,
                markerSize: markerSize,
              );
            }
          },
        ),
      ),
    );
  }
}

class _HorizontalTimelineItem extends StatelessWidget {
  const _HorizontalTimelineItem({
    required this.item,
    required this.gradient,
    required this.markerSize,
  });

  final TimelineItem item;
  final List<Color> gradient;
  final double markerSize;

  List<Color> _getMarkerGradient(ColorScheme colorScheme) {
    if (item.isCompleted) {
      return AppColors.deliveredGradient;
    } else if (item.isActive) {
      return gradient;
    } else {
      return [colorScheme.onSurfaceVariant.withValues(alpha: 0.7), colorScheme.onSurfaceVariant.withValues(alpha: 0.7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerGradient = _getMarkerGradient(colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markerSize,
          height: markerSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: markerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: item.isActive || item.isCompleted
                ? AppShadows.createColoredShadow(
                    color: markerGradient.first,
                    opacity: 0.4,
                  )
                : null,
          ),
          child: item.isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                )
              : item.icon != null
                  ? Icon(
                      item.icon,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: item.isCompleted || item.isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
