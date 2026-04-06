import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
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
    final color =
        isHindiTarget ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.translate_rounded, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                'Translations',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  targetLanguage.nativeName,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: isHindiTarget ? 'NotoSansDevanagari' : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: translations.map((translation) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.15)),
                ),
                child: Text(
                  translation,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: isHindiTarget ? 'NotoSansDevanagari' : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
