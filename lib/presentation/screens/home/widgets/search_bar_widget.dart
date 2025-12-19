import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final String? hintText;
  final Widget? trailing;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText ?? 'Search...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search, size: 24),
        suffixIcon: trailing ??
            (controller != null
                ? _ClearButton(controller: controller!)
                : null),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final TextEditingController controller;

  const _ClearButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
          tooltip: 'Clear',
        );
      },
    );
  }
}
