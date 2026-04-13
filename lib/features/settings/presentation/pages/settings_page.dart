import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/core/l10n/language_cubit.dart';
import 'package:abdoul_express/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:abdoul_express/features/settings/presentation/pages/about_page.dart';
import 'package:abdoul_express/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:abdoul_express/features/settings/presentation/pages/terms_of_service_page.dart';
import 'package:abdoul_express/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Language Section with flags
          _SectionHeader(title: l10n.settingsLanguage),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              return Column(
                children: AppLanguage.values.map((language) {
                  final isSelected = state.language == language;
                  return ListTile(
                    leading: Text(
                      _getLanguageFlag(language),
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      _getLanguageDisplayName(language, l10n),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<LanguageCubit>().changeLanguage(language);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Language changed to ${_getLanguageDisplayName(language, l10n)}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          const Divider(height: 32),

          // About Section
          _SectionHeader(title: l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsTerms),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TermsOfServicePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(AppLanguage language, AppLocalizations l10n) {
    switch (language) {
      case AppLanguage.english:
        return l10n.settingsLanguageEnglish;
      case AppLanguage.french:
        return l10n.settingsLanguageFrench;
      case AppLanguage.hausa:
        return l10n.settingsLanguageHausa;
    }
  }

  String _getLanguageFlag(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return '🇬🇧'; // UK flag for English
      case AppLanguage.french:
        return '🇫🇷'; // French flag
      case AppLanguage.hausa:
        return '🇳🇪'; // Niger flag for Hausa
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
