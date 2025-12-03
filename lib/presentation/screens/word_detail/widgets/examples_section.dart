import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class ExamplesSection extends StatelessWidget {
  final List<String> examples;

  const ExamplesSection({
    super.key,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Examples',
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
              children: examples.asMap().entries.map((entry) {
                final index = entry.key;
                final example = entry.value;
                return _ExampleItem(
                  example: example,
                  isLast: index == examples.length - 1,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExampleItem extends StatelessWidget {
  final String example;
  final bool isLast;

  const _ExampleItem({
    required this.example,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 20,
            color: AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: AppTypography.exampleText,
            ),
          ),
        ],
      ),
    );
  }
}
