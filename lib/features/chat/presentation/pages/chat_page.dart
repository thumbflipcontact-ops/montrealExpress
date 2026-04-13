import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/design_system/components/blob_avatar.dart';
import '../../domain/entities/message.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

/// Organic Chat Page with distinctive desert marketplace aesthetic
/// Features:
/// - Glassmorphic header with blob avatar
/// - Staggered message animations
/// - Organic input field with gradient focus
/// - Warm, earthy color palette
/// - Distinctive bubble shapes
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _inputFocusNode = FocusNode();

  late AnimationController _headerAnimationController;
  late AnimationController _inputAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _inputScaleAnimation;

  bool _isInputFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadMessages();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _inputAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _inputScaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _inputAnimationController, curve: Curves.easeOut),
    );

    _headerAnimationController.forward();

    _inputFocusNode.addListener(_onInputFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  void _onInputFocusChanged() {
    setState(() => _isInputFocused = _inputFocusNode.hasFocus);
    if (_inputFocusNode.hasFocus) {
      _inputAnimationController.forward();
      HapticFeedback.selectionClick();
    } else {
      _inputAnimationController.reverse();
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _inputAnimationController.dispose();
    _inputFocusNode.removeListener(_onInputFocusChanged);
    _inputFocusNode.dispose();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        HapticFeedback.mediumImpact();
        context.read<ChatCubit>().sendMessage(imagePath: image.path);
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar('Impossible de sélectionner l\'image');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAttachmentOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AttachmentBottomSheet(
        onCameraTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onAudioTap: () {
          Navigator.pop(context);
          // TODO: Implement audio recording
        },
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      HapticFeedback.lightImpact();
      context.read<ChatCubit>().sendMessage(text: _controller.text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(painter: _ChatBackgroundPainter()),
          ),
          // Main content
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessageList()),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryMain,
              AppColors.primaryDark.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          boxShadow: AppShadows.createColoredShadow(
            color: AppColors.primaryMain,
            opacity: 0.3,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Back button with organic shape
              _OrganicIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              // Agent avatar with online indicator
              Stack(
                children: [
                  BlobAvatar(
                    size: 44,
                    seed: 42,
                    complexity: 6,
                    irregularity: 0.12,
                    gradient: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    icon: Icons.support_agent,
                    iconSize: 24,
                    iconColor: Colors.white,
                    borderWidth: 2,
                    borderColor: Colors.white.withValues(alpha: 0.5),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.successMain,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successMain.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Agent info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Service Client',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'En ligne ',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              _OrganicIconButton(
                icon: Icons.phone_outlined,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implement call
                },
              ),
              const SizedBox(width: 8),
              _OrganicIconButton(
                icon: Icons.more_vert,
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildLoadingState();
        } else if (state is ChatLoaded) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
          return _buildMessageListView(state.messages);
        } else if (state is ChatError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement des messages...',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.errorMain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oups !',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _RetryButton(
              onPressed: () => context.read<ChatCubit>().loadMessages(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlobAvatar(
              size: 80,
              seed: 123,
              complexity: 7,
              irregularity: 0.15,
              gradient: [AppColors.secondaryMain, AppColors.secondaryDark],
              icon: Icons.chat_bubble_outline,
              iconSize: 36,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Commencez la conversation !',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notre équipe est là pour vous aider',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageListView(List<Message> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final showDateSeparator =
            previousMessage == null ||
            !_isSameDay(message.sentAt, previousMessage.sentAt);

        return Column(
          children: [
            if (showDateSeparator) _DateSeparator(date: message.sentAt),
            _OrganicMessageBubble(
              message: message,
              isFirstInGroup:
                  previousMessage == null ||
                  previousMessage.isMe != message.isMe,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildInputArea() {
    return AnimatedBuilder(
      animation: _inputScaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _inputScaleAnimation.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
              offset: const Offset(0, -4),
              blurRadius: 16,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              _AnimatedActionButton(
                icon: Icons.add_circle_outline,
                color: AppColors.tertiaryMain,
                onPressed: _showAttachmentOptions,
              ),
              const SizedBox(width: 8),
              // Text input
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isInputFocused
                          ? AppColors.primaryMain.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                      width: _isInputFocused ? 1.5 : 1,
                    ),
                    boxShadow: _isInputFocused
                        ? AppShadows.createColoredShadow(
                            color: AppColors.primaryMain,
                            opacity: 0.1,
                            blurRadius: 8,
                          )
                        : null,
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _inputFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre message...',
                      hintStyle: GoogleFonts.dmSans(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: GoogleFonts.dmSans(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button with animation
              _SendButton(hasText: _hasText, onPressed: _sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}

/// Organic icon button with glassmorphic effect
class _OrganicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _OrganicIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Animated action button for input area
class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 24),
        ),
      ),
    );
  }
}

/// Animated send button
class _SendButton extends StatefulWidget {
  final bool hasText;
  final VoidCallback onPressed;

  const _SendButton({required this.hasText, required this.onPressed});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(_SendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasText && !oldWidget.hasText) {
      _controller.forward();
    } else if (!widget.hasText && oldWidget.hasText) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.hasText ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: widget.hasText
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryMain, AppColors.primaryDark],
                  )
                : null,
            color: widget.hasText ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            boxShadow: widget.hasText
                ? AppShadows.createColoredShadow(
                    color: AppColors.primaryMain,
                    opacity: 0.4,
                    blurRadius: 12,
                  )
                : null,
          ),
          child: Icon(
            Icons.send_rounded,
            color: widget.hasText ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Organic message bubble with distinctive shape
class _OrganicMessageBubble extends StatefulWidget {
  final Message message;
  final bool isFirstInGroup;

  const _OrganicMessageBubble({
    required this.message,
    this.isFirstInGroup = true,
  });

  @override
  State<_OrganicMessageBubble> createState() => _OrganicMessageBubbleState();
}

class _OrganicMessageBubbleState extends State<_OrganicMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: widget.message.isMe ? 30 : -30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final isImage = widget.message.messageType == MessageType.image;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: widget.isFirstInGroup ? 12 : 4,
            bottom: 4,
            left: isMe ? 48 : 0,
            right: isMe ? 0 : 48,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: isImage
                    ? const EdgeInsets.all(4)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryMain,
                            AppColors.primaryDark.withValues(alpha: 0.95),
                          ],
                        )
                      : null,
                  color: isMe ? null : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 20),
                  ),
                  border: !isMe
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
                          width: 1,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? AppColors.primaryMain.withValues(alpha: 0.25)
                          : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: isMe ? 12 : 8,
                      offset: const Offset(0, 3),
                      spreadRadius: isMe ? -2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isImage && widget.message.mediaPath != null)
                      _buildImageContent()
                    else if (!isImage)
                      _buildTextContent(isMe),
                    const SizedBox(height: 4),
                    _buildMessageMeta(isMe),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(widget.message.mediaPath!),
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 220,
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextContent(bool isMe) {
    return Text(
      widget.message.content,
      style: GoogleFonts.dmSans(
        color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildMessageMeta(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.message.formattedTime,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: isMe
                ? Colors.white.withValues(alpha: 0.75)
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 5),
          _MessageStatusIcon(status: widget.message.status),
        ],
      ],
    );
  }
}

/// Message status icon with color coding
class _MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;

  const _MessageStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.pending:
        icon = Icons.access_time;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = Colors.white.withValues(alpha: 0.8);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white.withValues(alpha: 0.85);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.successLight;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = AppColors.errorLight;
        break;
    }

    return Icon(icon, size: 15, color: color);
  }
}

/// Date separator between message groups
class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Aujourd'hui";
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else {
      final months = [
        '',
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              _formatDate(),
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Attachment bottom sheet with organic design
class _AttachmentBottomSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onAudioTap;

  const _AttachmentBottomSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppShadows.modal,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Envoyer un fichier',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Caméra',
                    gradient: [AppColors.primaryMain, AppColors.primaryDark],
                    onTap: onCameraTap,
                  ),
                  _AttachmentOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Galerie',
                    gradient: AppColors.pendingGradient,
                    onTap: onGalleryTap,
                  ),
                  _AttachmentOption(
                    icon: Icons.mic_outlined,
                    label: 'Audio',
                    gradient: AppColors.sportsGradient,
                    onTap: onAudioTap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual attachment option
class _AttachmentOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_AttachmentOption> createState() => _AttachmentOptionState();
}

class _AttachmentOptionState extends State<_AttachmentOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                shape: BoxShape.circle,
                boxShadow: AppShadows.createColoredShadow(
                  color: widget.gradient.first,
                  opacity: 0.3,
                  blurRadius: 12,
                ),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry button with gradient
class _RetryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RetryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryMain, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.button,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Réessayer',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for chat background pattern
class _ChatBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryMain.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle organic shapes in the background
    final path = Path();

    // Top right blob
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 1.1,
      size.height * 0.15,
      size.width,
      size.height * 0.25,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Bottom left blob
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.3,
      size.height,
    );
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
