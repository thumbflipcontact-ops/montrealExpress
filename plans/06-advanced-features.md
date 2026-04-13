# Phase 6: Advanced Features

> Week 6: Chat, Notifications, and Polish

## Goals

- [ ] Implement real-time chat with WebSocket
- [ ] Add push notifications (FCM)
- [ ] Implement search with suggestions
- [ ] Add analytics tracking
- [ ] Performance optimization
- [ ] Final testing and bug fixes

## Estimated Time: 4-5 days

---

## Part 1: Real-time Chat

### Backend API

| Method | Endpoint | Description |
|--------|----------|-------------|
| WebSocket | `/chat` | Real-time messaging |
| GET | `/chat/history` | Message history |
| POST | `/chat/send` | Send message (fallback) |

### Step 1: Create Chat DTOs

**File:** `lib/features/chat/data/models/message_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

enum MessageType { text, image, file }

enum MessageStatus { sending, sent, delivered, read, failed }

@JsonSerializable()
class MessageModel {
  final String id;
  @JsonKey(name: 'conversation_id')
  final String conversationId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  @JsonKey(name: 'sender_type')
  final String senderType; // 'user', 'admin', 'system'
  final String content;
  @JsonKey(name: 'message_type')
  final MessageType type;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;
  final MessageStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_synced')
  final bool isSynced;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.status = MessageStatus.sent,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderType,
    String? content,
    MessageType? type,
    String? attachmentUrl,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  bool get isFromUser => senderType == 'user';
  bool get isFromAdmin => senderType == 'admin';
}

@JsonSerializable()
class SendMessageRequest {
  final String content;
  @JsonKey(name: 'message_type')
  final MessageType type;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;

  SendMessageRequest({
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}
```

### Step 2: Create Chat WebSocket Service

**File:** `lib/features/chat/data/services/chat_websocket_service.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/message_model.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<MessageModel>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> connect() async {
    try {
      final token = await SecureStorage.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Replace with your WebSocket URL
      final wsUrl = 'wss://api.abdoulexpress.com/chat?token=$token';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (data) {
          final json = jsonDecode(data);
          final message = MessageModel.fromJson(json);
          _messageController.add(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _connectionController.add(false);
        },
        onDone: () {
          _connectionController.add(false);
        },
      );
      
      _connectionController.add(true);
    } catch (e) {
      _connectionController.add(false);
      rethrow;
    }
  }

  void sendMessage(SendMessageRequest request) {
    if (_channel == null) throw Exception('Not connected');
    
    final data = jsonEncode(request.toJson());
    _channel!.sink.add(data);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
```

### Step 3: Update Chat Repository

**File:** `lib/features/chat/data/repositories/chat_repository_impl.dart`

```dart
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../services/chat_websocket_service.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;
  final ChatWebSocketService _webSocket;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatLocalDataSource local,
    required ChatWebSocketService webSocket,
  })  : _remote = remote,
        _local = local,
        _webSocket = webSocket;

  @override
  Future<void> connect() => _webSocket.connect();

  @override
  void disconnect() => _webSocket.disconnect();

  @override
  Stream<MessageModel> get messageStream => _webSocket.messageStream;

  @override
  Stream<bool> get connectionStream => _webSocket.connectionStream;

  @override
  Future<List<MessageModel>> getMessageHistory() async {
    try {
      final response = await _remote.getMessageHistory();
      final messages = response.data ?? [];
      await _local.cacheMessages(messages);
      return messages;
    } catch (e) {
      return await _local.getCachedMessages();
    }
  }

  @override
  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    final request = SendMessageRequest(content: content, type: type);
    
    // Save locally first
    final localMessage = MessageModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: 'default',
      senderId: 'current_user',
      senderType: 'user',
      content: content,
      type: type,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _local.saveMessage(localMessage);

    try {
      // Try WebSocket first
      _webSocket.sendMessage(request);
    } catch (e) {
      // Fallback to HTTP
      await _remote.sendMessage(request);
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await _remote.markAsRead(messageId);
  }
}
```

---

## Part 2: Push Notifications

### Firebase Cloud Messaging Setup

**File:** `lib/core/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // TODO: Send token to your backend
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'abdoul_express_channel',
            'AbdoulExpress Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.messageId}');
  }

  static Future<String?> getToken() => _messaging.getToken();

  static Future<void> subscribeToTopic(String topic) => 
      _messaging.subscribeToTopic(topic);

  static Future<void> unsubscribeFromTopic(String topic) => 
      _messaging.unsubscribeFromTopic(topic);
}
```

---

## Part 3: Search with Suggestions

### Step 1: Create Search Repository

**File:** `lib/features/search/data/repositories/search_repository_impl.dart`

```dart
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../../../products/data/models/product_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;

  SearchRepositoryImpl({required SearchRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _remote.searchProducts(query);
    return response.data?.items ?? [];
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    final response = await _remote.getSearchSuggestions(query);
    return response.data ?? [];
  }

  @override
  Future<List<String>> getRecentSearches() async {
    // Load from local storage
    return [];
  }

  @override
  Future<void> saveSearch(String query) async {
    // Save to local storage
  }

  @override
  Future<void> clearRecentSearches() async {
    // Clear local storage
  }
}
```

### Step 2: Update SearchCubit with Debounce

**File:** `lib/features/search/presentation/cubit/search_cubit.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../products/data/models/product_model.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repository;
  Timer? _debounceTimer;

  SearchCubit({required SearchRepository repository})
      : _repository = repository,
        super(const SearchState());

  void onQueryChanged(String query) {
    if (query == state.query) return;

    emit(state.copyWith(query: query));

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear results if query is empty
    if (query.isEmpty) {
      emit(state.copyWith(results: [], suggestions: []));
      return;
    }

    // Debounce for 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _getSuggestions(query);
    });
  }

  Future<void> _getSuggestions(String query) async {
    try {
      final suggestions = await _repository.getSuggestions(query);
      emit(state.copyWith(suggestions: suggestions));
    } catch (e) {
      // Silently fail for suggestions
    }
  }

  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await _repository.searchProducts(query);
      await _repository.saveSearch(query);
      
      emit(state.copyWith(
        isLoading: false,
        results: results,
        suggestions: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur de recherche',
      ));
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
```

---

## Part 4: Analytics

**File:** `lib/core/services/analytics_service.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAppOpen() => _analytics.logAppOpen();

  static Future<void> logLogin(String method) => 
      _analytics.logLogin(loginMethod: method);

  static Future<void> logSignUp(String method) => 
      _analytics.logSignUp(signUpMethod: method);

  static Future<void> logViewProduct({
    required String productId,
    required String productName,
    required String category,
    required double price,
  }) => _analytics.logViewItem(
    items: [
      AnalyticsEventItem(
        itemId: productId,
        itemName: productName,
        itemCategory: category,
        price: price,
      ),
    ],
  );

  static Future<void> logAddToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
  }) => _analytics.logAddToCart(
    items: [
      AnalyticsEventItem(
        itemId: productId,
        itemName: productName,
        price: price,
        quantity: quantity,
      ),
    ],
  );

  static Future<void> logPurchase({
    required String orderId,
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) => _analytics.logPurchase(
    transactionId: orderId,
    value: value,
    currency: currency,
    items: items,
  );

  static Future<void> setUserId(String userId) => 
      _analytics.setUserId(id: userId);

  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value?.toString(),
      );
    }
  }
}
```

---

## Part 5: Performance Optimization

### 1. Image Caching

Already using `cached_network_image`. Ensure proper configuration:

```dart
CachedNetworkImage(
  imageUrl: product.thumbnail,
  placeholder: (context, url) => const ShimmerLoading(),
  errorWidget: (context, url, error) => const ErrorPlaceholder(),
  memCacheWidth: 600, // Limit memory cache size
  maxHeightDiskCache: 800, // Limit disk cache size
)
```

### 2. List Optimization

```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(
    product: products[index],
  ),
  // Add for better performance
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: false,
  cacheExtent: 100,
)
```

### 3. API Response Caching with Dio

```dart
// In dio_client.dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

static Dio _createDio() {
  final dio = Dio(/* ... */);
  
  // Add cache interceptor
  final cacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(hours: 1),
  );
  
  dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  
  return dio;
}
```

---

## Checklist

- [ ] MessageModel DTO created
- [ ] ChatWebSocketService implemented
- [ ] ChatRepositoryImpl with WebSocket support
- [ ] Firebase Messaging configured
- [ ] NotificationService created
- [ ] Search with debounce implemented
- [ ] Search suggestions API integrated
- [ ] Analytics service created
- [ ] Performance optimizations applied
- [ ] Image caching configured
- [ ] List optimizations applied
- [ ] API response caching added
- [ ] Final testing completed
- [ ] Bug fixes applied

---

## Post-Launch Checklist

- [ ] Monitor crash reports (Sentry/Firebase Crashlytics)
- [ ] Track API performance
- [ ] Monitor error rates
- [ ] Collect user feedback
- [ ] Plan feature iterations

---

## End of Roadmap

🎉 Congratulations! The AbdoulExpress API integration is complete!

**Summary:**
- ✅ Phase 1: Infrastructure
- ✅ Phase 2: Authentication
- ✅ Phase 3: Product Catalog
- ✅ Phase 4: User Features
- ✅ Phase 5: Orders & Payments
- ✅ Phase 6: Advanced Features

**Total Estimated Time:** 6 weeks

Go back to [README](./README.md) for overview.
