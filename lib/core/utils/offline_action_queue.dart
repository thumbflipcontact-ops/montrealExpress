import 'dart:async';

/// Simple offline action queue for AbdoulExpress.
///
/// NOTE: This is a light-weight, in-memory placeholder implementation.
/// For production, persist the queue to Hive/Drift to survive app restarts.

typedef OfflineActionFn = Future<void> Function();

class OfflineAction {
  final String id;
  final OfflineActionFn action;
  final DateTime createdAt;

  OfflineAction({required this.id, required this.action}) : createdAt = DateTime.now();
}

class OfflineActionQueue {
  final List<OfflineAction> _queue = [];
  bool _isProcessing = false;

  /// Add an action to the offline queue.
  Future<void> add(OfflineAction action) async {
    _queue.add(action);
  }

  /// Process the queue. Actions are executed serially.
  Future<void> process() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final action = _queue.first;
      try {
        await action.action();
        _queue.removeAt(0);
      } catch (e) {
        // Stop processing to retry later
        break;
      }
    }

    _isProcessing = false;
  }

  /// Check if there are pending actions.
  bool get hasPending => _queue.isNotEmpty;

  /// Clear queue (useful in tests)
  void clear() => _queue.clear();
}

// A global singleton instance to use across the app. For testability, prefer to
// inject instances via DI (get_it/provider/riverpod) rather than using globals.
final OfflineActionQueue offlineQueue = OfflineActionQueue();
