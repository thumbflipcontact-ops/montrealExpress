import 'package:hive/hive.dart';
import '../../domain/entities/message.dart';
import '../../domain/repository/message_repository.dart';

class MessageLocalDataSource implements MessageRepository {
  static const String _boxName = 'messages';

  Future<Box<Message>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Message>(_boxName);
    }
    return Hive.box<Message>(_boxName);
  }

  @override
  Future<void> saveMessage(Message message) async {
    try {
      final box = await _getBox();
      await box.put(message.id, message);
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  @override
  Future<void> saveAll(List<Message> messages) async {
    try {
      final box = await _getBox();
      final messageMap = {for (var msg in messages) msg.id: msg};
      await box.putAll(messageMap);
    } catch (e) {
      throw Exception('Failed to save messages: $e');
    }
  }

  @override
  Future<List<Message>> getMessagesForConversation(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final box = await _getBox();
      final messages = box.values
          .where((m) => m.conversationId == conversationId)
          .toList();

      // Sort by sent time (oldest first for chat display)
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      // Apply pagination
      final start = offset.clamp(0, messages.length);
      final end = (offset + limit).clamp(0, messages.length);

      return messages.sublist(start, end);
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<Message?> getMessageById(String messageId) async {
    try {
      final box = await _getBox();
      return box.get(messageId);
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }

  @override
  Future<void> updateMessageStatus(
      String messageId, MessageStatus status) async {
    try {
      final box = await _getBox();
      final message = box.get(messageId);
      if (message != null) {
        final updatedMessage = message.copyWith(
          status: status,
          deliveredAt:
              status == MessageStatus.delivered ? DateTime.now() : message.deliveredAt,
          readAt: status == MessageStatus.read ? DateTime.now() : message.readAt,
        );
        await box.put(messageId, updatedMessage);
      }
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  @override
  Future<List<Message>> getUnsyncedMessages() async {
    try {
      final box = await _getBox();
      return box.values.where((m) => !m.isSynced).toList();
    } catch (e) {
      throw Exception('Failed to get unsynced messages: $e');
    }
  }

  @override
  Future<void> markAsSynced(String messageId) async {
    try {
      final box = await _getBox();
      final message = box.get(messageId);
      if (message != null) {
        final updatedMessage = message.copyWith(isSynced: true);
        await box.put(messageId, updatedMessage);
      }
    } catch (e) {
      throw Exception('Failed to mark message as synced: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final box = await _getBox();
      await box.delete(messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final box = await _getBox();
      final messagesToDelete = box.values
          .where((m) => m.conversationId == conversationId)
          .map((m) => m.id)
          .toList();

      for (final id in messagesToDelete) {
        await box.delete(id);
      }
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  @override
  Future<int> getMessageCount(String conversationId) async {
    try {
      final box = await _getBox();
      return box.values
          .where((m) => m.conversationId == conversationId)
          .length;
    } catch (e) {
      throw Exception('Failed to get message count: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear messages: $e');
    }
  }
}
