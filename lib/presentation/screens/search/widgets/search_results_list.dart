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
    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultItem(
          result: result,
          onTap: () => onResultTap(result),
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = result.languageCode == 'hi';
    final badgeColor = isHindi ? AppColors.hindiBadge : AppColors.englishBadge;

    return ListTile(
      onTap: onTap,
      leading: _LanguageBadge(
        languageCode: result.languageCode,
        color: badgeColor,
      ),
      title: Text(
        result.word,
        style: TextStyle(
          fontFamily: isHindi ? 'NotoSansDevanagari' : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildSubtitle(context),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <String>[];

    if (result.pos != null) {
      parts.add(result.pos!);
    }

    if (result.matchedTranslation != null) {
      parts.add('→ ${result.matchedTranslation}');
    }

    if (result.previewDefinition != null) {
      parts.add(result.previewDefinition!);
    }

    if (parts.isEmpty) {
      return null;
    }

    return Text(
      parts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  final String languageCode;
  final Color color;

  const _LanguageBadge({
    required this.languageCode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        languageCode.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
