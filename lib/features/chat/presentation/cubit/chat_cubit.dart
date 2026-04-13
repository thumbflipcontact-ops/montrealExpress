import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repository/message_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessageRepository messageRepository;

  // Default conversation ID for the support chat
  static const String defaultConversationId = 'support_chat_default';

  // Current user ID (in production, get from auth)
  static const String currentUserId = 'current_user';

  String _conversationId = defaultConversationId;

  ChatCubit({required this.messageRepository}) : super(ChatInitial());

  Future<void> loadMessages([String? conversationId]) async {
    _conversationId = conversationId ?? defaultConversationId;
    emit(ChatLoading());

    try {
      List<Message> messages = await messageRepository.getMessagesForConversation(
        _conversationId,
        limit: 100,
      );

      // If no messages exist, create welcome message
      if (messages.isEmpty) {
        final welcomeMessage = Message(
          id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _conversationId,
          senderUserId: 'support_agent',
          senderName: 'Agent de support',
          content: 'Bonjour! Comment pouvons-nous vous aider aujourd\'hui?',
          messageType: MessageType.text,
          status: MessageStatus.delivered,
          sentAt: DateTime.now(),
          isSynced: true,
          isMe: false,
        );

        await messageRepository.saveMessage(welcomeMessage);
        messages = [welcomeMessage];
      }

      emit(ChatLoaded(messages));
    } catch (e) {
      debugPrint('Failed to load messages: $e');
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> sendMessage({String? text, String? imagePath}) async {
    if (state is! ChatLoaded) return;

    final currentMessages = (state as ChatLoaded).messages;

    // Validate input
    if ((text == null || text.trim().isEmpty) && imagePath == null) {
      return;
    }

    // Create user message
    final userMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId,
      senderUserId: currentUserId,
      senderName: 'Vous',
      content: text?.trim() ?? '',
      messageType: imagePath != null ? MessageType.image : MessageType.text,
      mediaPath: imagePath,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
      isSynced: false,
      isMe: true,
    );

    // Optimistic UI update
    final updatedMessages = [...currentMessages, userMessage];
    emit(ChatLoaded(updatedMessages));

    try {
      // Save to local storage
      await messageRepository.saveMessage(userMessage);

      // TODO: In production, send to backend API here
      // await _syncMessageToBackend(userMessage);

      // Simulate auto-reply from support agent
      _simulateAgentReply();
    } catch (e) {
      debugPrint('Failed to send message: $e');

      // Update message status to failed
      final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
      await messageRepository.saveMessage(failedMessage);

      // Reload to show failed status
      await loadMessages(_conversationId);
    }
  }

  void _simulateAgentReply() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!isClosed && state is ChatLoaded) {
        final replyMessage = Message(
          id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _conversationId,
          senderUserId: 'support_agent',
          senderName: 'Agent de support',
          content: 'Merci pour votre message. Un agent vous répondra bientôt.',
          messageType: MessageType.text,
          status: MessageStatus.delivered,
          sentAt: DateTime.now(),
          deliveredAt: DateTime.now(),
          isSynced: true,
          isMe: false,
        );

        await messageRepository.saveMessage(replyMessage);

        final currentMessages = (state as ChatLoaded).messages;
        emit(ChatLoaded([...currentMessages, replyMessage]));
      }
    });
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await messageRepository.updateMessageStatus(messageId, MessageStatus.read);

      // Refresh messages
      if (state is ChatLoaded) {
        await loadMessages(_conversationId);
      }
    } catch (e) {
      debugPrint('Failed to mark message as read: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await messageRepository.deleteMessage(messageId);

      // Refresh messages
      if (state is ChatLoaded) {
        await loadMessages(_conversationId);
      }
    } catch (e) {
      debugPrint('Failed to delete message: $e');
      emit(ChatError('Failed to delete message'));
    }
  }

  Future<void> clearConversation() async {
    try {
      await messageRepository.deleteConversation(_conversationId);
      await loadMessages(_conversationId);
    } catch (e) {
      debugPrint('Failed to clear conversation: $e');
      emit(ChatError('Failed to clear conversation'));
    }
  }

  Future<List<Message>> getUnsyncedMessages() async {
    try {
      return await messageRepository.getUnsyncedMessages();
    } catch (e) {
      debugPrint('Failed to get unsynced messages: $e');
      return [];
    }
  }

  // TODO: Implement backend sync
  // Future<void> _syncMessageToBackend(Message message) async {
  //   try {
  //     final response = await apiService.sendMessage(message);
  //     await messageRepository.markAsSynced(message.id);
  //   } catch (e) {
  //     debugPrint('Backend sync failed: $e');
  //     throw e;
  //   }
  // }
}
