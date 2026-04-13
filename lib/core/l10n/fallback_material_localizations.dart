import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Fallback Material Localizations Delegate
/// Provides French localizations for Hausa locale since Flutter doesn't have built-in support
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support Hausa by providing French localizations
    return locale.languageCode == 'ha';
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // For Hausa, load French Material localizations
    if (locale.languageCode == 'ha') {
      return GlobalMaterialLocalizations.delegate.load(const Locale('fr'));
    }
    return GlobalMaterialLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback Cupertino Localizations Delegate
/// Provides French localizations for Hausa locale since Flutter doesn't have built-in support
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support Hausa by providing French localizations
    return locale.languageCode == 'ha';
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    // For Hausa, load French Cupertino localizations
    if (locale.languageCode == 'ha') {
      return GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));
    }
    return GlobalCupertinoLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
