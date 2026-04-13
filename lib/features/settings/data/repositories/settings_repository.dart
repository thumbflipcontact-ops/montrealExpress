import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  AppSettingsModel? _cachedSettings;

  Future<AppSettingsModel> loadSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/abdoul_express.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _cachedSettings = AppSettingsModel.fromJson(jsonMap);
      return _cachedSettings!;
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  Future<AboutData> getAboutData() async {
    final settings = await loadSettings();
    return settings.settings.about;
  }

  Future<PrivacyPolicy> getPrivacyPolicy() async {
    final settings = await loadSettings();
    return settings.settings.privacyPolicy;
  }

  Future<TermsOfUse> getTermsOfUse() async {
    final settings = await loadSettings();
    return settings.settings.termsOfUse;
  }

  Future<CompanyInfo> getCompanyInfo() async {
    final settings = await loadSettings();
    return settings.companyInfo;
  }

  Future<StorePresentation> getStorePresentation() async {
    final settings = await loadSettings();
    return settings.storePresentation;
  }

  void clearCache() {
    _cachedSettings = null;
  }
}
