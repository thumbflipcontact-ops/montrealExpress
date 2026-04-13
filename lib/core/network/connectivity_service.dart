import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  // Current connectivity status
  bool _isConnected = true;
  StreamSubscription? _subscription;

  /// Get stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if currently connected
  bool get isConnected => _isConnected;

  /// Initialize the service and start monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus([result]);
    });
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus([result]);
      return _isConnected;
    } catch (e) {
      // If we can't check, assume no connection
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    }
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // Check if any connection is available
    final hasConnection = result.any((connectivityResult) =>
        connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet);

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectivityController.add(_isConnected);
    }
  }

  /// Wait for internet connection
  /// Returns true if already connected, waits up to [timeout] if not
  Future<bool> waitForConnection({Duration? timeout}) async {
    if (_isConnected) return true;

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    // Set up timeout
    Timer? timer;
    if (timeout != null) {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.complete(false);
        }
      });
    }

    // Listen for connection
    subscription = connectivityStream.listen((isConnected) {
      if (isConnected && !completer.isCompleted) {
        timer?.cancel();
        subscription?.cancel();
        completer.complete(true);
      }
    });

    return completer.future;
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
