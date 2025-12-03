import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../domain/entities/language.dart';

class TranslationSection extends StatelessWidget {
  final List<String> translations;
  final Language targetLanguage;

  const TranslationSection({
    super.key,
    required this.translations,
    required this.targetLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isHindiTarget = targetLanguage.code == 'hi';
    final badgeColor = isHindiTarget ? AppColors.hindiBadge : AppColors.englishBadge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Translations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                targetLanguage.nativeName,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: isHindiTarget ? 'NotoSansDevanagari' : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: badgeColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: translations.map((translation) {
                return _TranslationChip(
                  translation: translation,
                  isHindi: isHindiTarget,
                  color: badgeColor,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TranslationChip extends StatelessWidget {
  final String translation;
  final bool isHindi;
  final Color color;

  const _TranslationChip({
    required this.translation,
    required this.isHindi,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        translation,
        style: isHindi
            ? AppTypography.hindiText.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              )
            : Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
      ),
    );
  }
}
