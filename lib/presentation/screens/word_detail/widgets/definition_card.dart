import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class DefinitionCard extends StatelessWidget {
  final List<String> definitions;
  final String? pos;

  const DefinitionCard({
    super.key,
    required this.definitions,
    this.pos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Definitions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: definitions.asMap().entries.map((entry) {
                final index = entry.key;
                final definition = entry.value;
                return _DefinitionItem(
                  number: index + 1,
                  definition: definition,
                  isLast: index == definitions.length - 1,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DefinitionItem extends StatelessWidget {
  final int number;
  final String definition;
  final bool isLast;

  const _DefinitionItem({
    required this.number,
    required this.definition,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Definition text
          Expanded(
            child: Text(
              definition,
              style: AppTypography.definitionText,
            ),
          ),
        ],
      ),
    );
  }
}
