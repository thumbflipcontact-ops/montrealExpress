import '../entities/message.dart';

abstract class MessageRepository {
  /// Save a message to local storage
  Future<void> saveMessage(Message message);

  /// Save multiple messages at once
  Future<void> saveAll(List<Message> messages);

  /// Get all messages for a specific conversation with pagination
  Future<List<Message>> getMessagesForConversation(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get a specific message by ID
  Future<Message?> getMessageById(String messageId);

  /// Update message status (sent, delivered, read, etc.)
  Future<void> updateMessageStatus(String messageId, MessageStatus status);

  /// Get all messages that haven't been synced to backend
  Future<List<Message>> getUnsyncedMessages();

  /// Mark a message as synced with backend
  Future<void> markAsSynced(String messageId);

  /// Delete a specific message
  Future<void> deleteMessage(String messageId);

  /// Delete all messages for a conversation
  Future<void> deleteConversation(String conversationId);

  /// Get total message count for a conversation
  Future<int> getMessageCount(String conversationId);

  /// Clear all messages from local storage
  Future<void> clearAll();
}
