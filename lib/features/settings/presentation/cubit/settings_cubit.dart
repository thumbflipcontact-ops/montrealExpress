import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state
class SettingsState {
  final bool notificationsEnabled;

  const SettingsState({
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Settings Cubit for managing app settings
class SettingsCubit extends Cubit<SettingsState> {
  static const String _notificationsKey = 'notifications_enabled';

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

      emit(SettingsState(
        notificationsEnabled: notificationsEnabled,
      ));
    } catch (e) {
      // Use default settings if error
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);

      emit(state.copyWith(notificationsEnabled: enabled));
    } catch (e) {
      // Handle error silently
    }
  }
}
