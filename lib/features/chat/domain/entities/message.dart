import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 15)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String senderUserId;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String? senderAvatar;

  @HiveField(5)
  final String content;

  @HiveField(6)
  final MessageType messageType;

  @HiveField(7)
  final String? mediaPath;

  @HiveField(8)
  final String? mediaUrl;

  @HiveField(9)
  final MessageStatus status;

  @HiveField(10)
  final DateTime sentAt;

  @HiveField(11)
  final DateTime? deliveredAt;

  @HiveField(12)
  final DateTime? readAt;

  @HiveField(13)
  final bool isSynced;

  @HiveField(14)
  final bool isMe;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.messageType,
    this.mediaPath,
    this.mediaUrl,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.isSynced = false,
    required this.isMe,
  });

  String get formattedTime {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderUserId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? messageType,
    String? mediaPath,
    String? mediaUrl,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isSynced,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isSynced: isSynced ?? this.isSynced,
      isMe: isMe ?? this.isMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderUserId': senderUserId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'messageType': messageType.toString(),
      'mediaPath': mediaPath,
      'mediaUrl': mediaUrl,
      'status': status.toString(),
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isSynced': isSynced,
      'isMe': isMe,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderUserId: json['senderUserId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String?,
      content: json['content'] as String,
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == json['messageType'],
        orElse: () => MessageType.text,
      ),
      mediaPath: json['mediaPath'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      sentAt: DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isSynced: json['isSynced'] as bool? ?? false,
      isMe: json['isMe'] as bool,
    );
  }
}

@HiveType(typeId: 16)
enum MessageStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  sent,

  @HiveField(2)
  delivered,

  @HiveField(3)
  read,

  @HiveField(4)
  failed,
}

@HiveType(typeId: 17)
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  image,

  @HiveField(2)
  audio,

  @HiveField(3)
  file,
}
