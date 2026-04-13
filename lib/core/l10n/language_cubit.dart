import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages in the app
enum AppLanguage {
  english('en', 'English'),
  french('fr', 'Français'),
  hausa('ha', 'Hausa');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.french, // Default to French for Niger market
    );
  }
}

/// State for language selection
class LanguageState {
  final Locale locale;
  final AppLanguage language;

  const LanguageState({
    required this.locale,
    required this.language,
  });

  LanguageState copyWith({
    Locale? locale,
    AppLanguage? language,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      language: language ?? this.language,
    );
  }
}

/// Cubit for managing app language
class LanguageCubit extends Cubit<LanguageState> {
  static const String _languageKey = 'app_language';

  LanguageCubit()
      : super(LanguageState(
          locale: AppLanguage.french.locale, // Default to French
          language: AppLanguage.french,
        )) {
    _loadSavedLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_languageKey);

      if (savedCode != null) {
        final language = AppLanguage.fromCode(savedCode);
        emit(LanguageState(
          locale: language.locale,
          language: language,
        ));
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  /// Change the app language
  Future<void> changeLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);

      emit(LanguageState(
        locale: language.locale,
        language: language,
      ));

      debugPrint('Language changed to: ${language.displayName}');
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Get current language
  AppLanguage get currentLanguage => state.language;

  /// Get current locale
  Locale get currentLocale => state.locale;
}
