import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../domain/entities/search_result.dart';

class SearchResultsList extends StatelessWidget {
  final List<SearchResultEntity> results;
  final ValueChanged<SearchResultEntity> onResultTap;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: results.length,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultCard(
          result: result,
          onTap: () => onResultTap(result),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = result.languageCode == 'hi';
    final color =
        isHindi ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.dividerC),
          boxShadow: [
            BoxShadow(
              color: context.subtleShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Language indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                result.languageCode.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Word and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          result.word,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryC,
                            fontFamily: isHindi ? 'NotoSansDevanagari' : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (result.isExactMatch) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EXACT',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      _subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasSubtitle {
    return result.pos != null ||
        result.matchedTranslation != null ||
        result.previewDefinition != null;
  }

  String get _subtitleText {
    final parts = <String>[];
    if (result.pos != null) parts.add(result.pos!);
    if (result.matchedTranslation != null) {
      parts.add('→ ${result.matchedTranslation}');
    }
    if (result.previewDefinition != null) {
      parts.add(result.previewDefinition!);
    }
    return parts.join(' • ');
  }
}
