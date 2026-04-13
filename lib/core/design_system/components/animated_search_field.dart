import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Animated search field with enhanced UX
/// 
/// Features:
/// - Expandable search field animation
/// - Clear button with animation
/// - Search suggestions support
/// - Haptic feedback
/// - Debounced search callback
class AnimatedSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Widget? prefixIcon;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionSelected;

  const AnimatedSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _showClear = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primaryMain
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryMain.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.searchField,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: AppTypography.inputStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.inputStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: widget.prefixIcon ??
                  Icon(
                    Icons.search,
                    color: _isFocused
                        ? AppColors.primaryMain
                        : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
              suffixIcon: _showClear
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                    )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 200))
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Suggestions dropdown
        if (_isFocused &&
            widget.suggestions != null &&
            widget.suggestions!.isNotEmpty)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.large,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.suggestions!.take(5).map((suggestion) {
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      suggestion,
                      style: AppTypography.inputStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onSuggestionSelected?.call(suggestion);
                      _controller.text = suggestion;
                      _focusNode.unfocus();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Search filter chips for refining search results
class SearchFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const SearchFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                onFilterSelected(filter);
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primaryMain,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryMain
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
              label: Text(filter),
              labelStyle: AppTypography.categoryChipStyle(
                color: isSelected
                    ? AppColors.primaryMain
                    : colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Recent searches widget
class RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String>? onSearchSelected;
  final ValueChanged<String>? onSearchDeleted;

  const RecentSearches({
    super.key,
    required this.searches,
    this.onSearchSelected,
    this.onSearchDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (searches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recherches récentes',
                style: AppTypography.buildTextTheme(Brightness.light).titleMedium!.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (onSearchDeleted != null)
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Clear all searches
                  },
                  child: Text(
                    'Effacer',
                    style: AppTypography.categoryChipStyle(
                      color: AppColors.primaryMain,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searches.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.history,
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
              title: Text(
                searches[index],
                style: AppTypography.inputStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: onSearchDeleted != null
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      onPressed: () => onSearchDeleted?.call(searches[index]),
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                onSearchSelected?.call(searches[index]);
              },
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: index * 50),
                  duration: const Duration(milliseconds: 300),
                )
                .slideX(
                  begin: -0.1,
                  end: 0,
                  delay: Duration(milliseconds: index * 50),
                );
          },
        ),
      ],
    );
  }
}

/// Popular searches widget
class PopularSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String>? onSearchSelected;

  const PopularSearches({
    super.key,
    required this.searches,
    this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (searches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recherches populaires',
            style: AppTypography.buildTextTheme(Brightness.light)
                .titleMedium!
                .copyWith(color: colorScheme.onSurface),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.asMap().entries.map((entry) {
              final index = entry.key;
              final search = entry.value;
              return ActionChip(
                avatar: Icon(
                  Icons.trending_up,
                  color: AppColors.primaryMain,
                  size: 16,
                ),
                label: Text(search),
                backgroundColor: AppColors.primaryContainer,
                side: BorderSide.none,
                labelStyle: AppTypography.categoryChipStyle(
                  color: AppColors.onPrimaryContainer,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onSearchSelected?.call(search);
                },
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
            }).toList(),
          ),
        ),
      ],
    );
  }
}
