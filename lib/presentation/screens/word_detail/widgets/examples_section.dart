import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';

class ExamplesSection extends StatelessWidget {
  final List<String> examples;

  const ExamplesSection({
    super.key,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.format_quote_rounded,
                    size: 18, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 10),
              Text(
                'Examples',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...examples.asMap().entries.map((entry) {
            final index = entry.key;
            final example = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == examples.length - 1 ? 0 : 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.screenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  example,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: context.textSecondaryC,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
