import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/colors.dart';
import '../../../domain/entities/language.dart';
import '../../providers/settings_provider.dart';
import '../../providers/dictionary_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final statsAsync = ref.watch(databaseStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _SectionHeader(title: 'Appearance'),
          _ThemeSelector(
            currentTheme: settings.themeMode,
            onChanged: (mode) {
              ref.read(settingsProvider.notifier).setThemeMode(mode);
            },
          ),
          const Divider(),

          // Language section
          _SectionHeader(title: 'Language'),
          _LanguageSelector(
            currentPair: settings.languagePair,
            onChanged: (pair) {
              ref.read(settingsProvider.notifier).setLanguagePair(pair);
            },
          ),
          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          statsAsync.when(
            data: (stats) => _AboutTile(
              version: stats.version ?? 'Unknown',
              wordCount: stats.totalWordCount,
            ),
            loading: () => const ListTile(
              title: Text('Loading...'),
            ),
            error: (_, __) => const ListTile(
              title: Text('Error loading info'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Data Source'),
            subtitle: const Text('Wiktionary (kaikki.org)'),
            onTap: () {
              _showLicenseInfo(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLicenseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data License'),
        content: const Text(
          'Dictionary data is sourced from Wiktionary and is licensed under '
          'CC BY-SA 3.0 (Creative Commons Attribution-ShareAlike 3.0).\n\n'
          'The data is pre-processed and extracted from kaikki.org.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(_getThemeLabel(currentTheme)),
      onTap: () {
        _showThemeDialog(context);
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose theme'),
        children: [
          _ThemeOption(
            title: 'System default',
            icon: Icons.settings_suggest,
            isSelected: currentTheme == ThemeMode.system,
            onTap: () {
              onChanged(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          _ThemeOption(
            title: 'Light',
            icon: Icons.light_mode,
            isSelected: currentTheme == ThemeMode.light,
            onTap: () {
              onChanged(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          _ThemeOption(
            title: 'Dark',
            icon: Icons.dark_mode,
            isSelected: currentTheme == ThemeMode.dark,
            onTap: () {
              onChanged(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final LanguagePair currentPair;
  final ValueChanged<LanguagePair> onChanged;

  const _LanguageSelector({
    required this.currentPair,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.translate),
      title: const Text('Translation direction'),
      subtitle: Text(currentPair.displayString),
      onTap: () {
        _showLanguageDialog(context);
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose direction'),
        children: [
          _LanguageOption(
            pair: LanguagePair.englishToHindi,
            isSelected: currentPair == LanguagePair.englishToHindi,
            onTap: () {
              onChanged(LanguagePair.englishToHindi);
              Navigator.pop(context);
            },
          ),
          _LanguageOption(
            pair: LanguagePair.hindiToEnglish,
            isSelected: currentPair == LanguagePair.hindiToEnglish,
            onTap: () {
              onChanged(LanguagePair.hindiToEnglish);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final LanguagePair pair;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.pair,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pair.displayString),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}

class _AboutTile extends StatelessWidget {
  final String version;
  final int wordCount;

  const _AboutTile({
    required this.version,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage_outlined),
      title: const Text('Dictionary'),
      subtitle: Text('Version $version • ${_formatNumber(wordCount)} words'),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
