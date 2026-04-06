import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              decoration: BoxDecoration(
                color: context.headerBg,
                boxShadow: [
                  BoxShadow(
                    color: context.subtleShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.textPrimaryC,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryC,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // Appearance section
                  _SectionLabel(title: 'APPEARANCE'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Theme',
                        subtitle: _getThemeLabel(settings.themeMode),
                        onTap: () => _showThemeDialog(context, ref, settings.themeMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Language section
                  _SectionLabel(title: 'LANGUAGE'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Translation Direction',
                        subtitle: settings.languagePair.displayString,
                        onTap: () => _showLanguageDialog(
                            context, ref, settings.languagePair),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About section
                  _SectionLabel(title: 'ABOUT'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      statsAsync.when(
                        data: (stats) => _SettingsTile(
                          icon: Icons.storage_rounded,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Dictionary',
                          subtitle:
                              'Version ${stats.version ?? "Unknown"} • ${_formatNumber(stats.totalWordCount)} words',
                          showArrow: false,
                        ),
                        loading: () => _SettingsTile(
                          icon: Icons.storage_rounded,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Dictionary',
                          subtitle: 'Loading...',
                          showArrow: false,
                        ),
                        error: (_, __) => _SettingsTile(
                          icon: Icons.storage_rounded,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Dictionary',
                          subtitle: 'Error loading info',
                          showArrow: false,
                        ),
                      ),
                      _buildDivider(context),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFFFF9800),
                        title: 'Data Source',
                        subtitle: 'Wiktionary (kaikki.org)',
                        onTap: () => _showLicenseInfo(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: context.dividerC),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                title: 'System Default',
                icon: Icons.settings_suggest_rounded,
                isSelected: current == ThemeMode.system,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                title: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: current == ThemeMode.light,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                title: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: current == ThemeMode.dark,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, LanguagePair current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Translation Direction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                pair: LanguagePair.englishToHindi,
                isSelected: current == LanguagePair.englishToHindi,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setLanguagePair(LanguagePair.englishToHindi);
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                pair: LanguagePair.hindiToEnglish,
                isSelected: current == LanguagePair.hindiToEnglish,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setLanguagePair(LanguagePair.hindiToEnglish);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLicenseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Data License'),
        content: const Text(
          'Dictionary data is sourced from Wiktionary and is licensed under '
          'CC BY-SA 3.0 (Creative Commons Attribution-ShareAlike 3.0).\n\n'
          'The data is pre-processed and extracted from kaikki.org.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF2196F3))),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.textSecondaryC,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.subtleShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryC,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.textSecondaryC,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 22),
          ],
        ),
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : context.dividerC,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color:
                isSelected ? const Color(0xFF2196F3) : context.textSecondaryC),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? const Color(0xFF2196F3)
              : context.textPrimaryC,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: Color(0xFF2196F3), size: 22)
          : null,
      onTap: onTap,
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : context.dividerC,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.swap_horiz_rounded,
            size: 20,
            color:
                isSelected ? const Color(0xFF2196F3) : context.textSecondaryC),
      ),
      title: Text(
        pair.displayString,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? const Color(0xFF2196F3)
              : context.textPrimaryC,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: Color(0xFF2196F3), size: 22)
          : null,
      onTap: onTap,
    );
  }
}
