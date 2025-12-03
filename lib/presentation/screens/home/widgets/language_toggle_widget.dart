import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../../providers/settings_provider.dart';

class LanguageToggleWidget extends ConsumerWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final languagePair = settings.languagePair;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Source language
            Expanded(
              child: _LanguageButton(
                languageCode: languagePair.source.code,
                languageName: languagePair.source.nativeName,
                isSource: true,
              ),
            ),

            // Swap button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IconButton.filled(
                onPressed: () {
                  ref.read(settingsProvider.notifier).swapLanguages();
                },
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Swap languages',
              ),
            ),

            // Target language
            Expanded(
              child: _LanguageButton(
                languageCode: languagePair.target.code,
                languageName: languagePair.target.nativeName,
                isSource: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final bool isSource;

  const _LanguageButton({
    required this.languageCode,
    required this.languageName,
    required this.isSource,
  });

  @override
  Widget build(BuildContext context) {
    final color = languageCode == 'en' ? AppColors.englishBadge : AppColors.hindiBadge;

    return Column(
      children: [
        Text(
          isSource ? 'From' : 'To',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            languageName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: languageCode == 'hi' ? 'NotoSansDevanagari' : null,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
