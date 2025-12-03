import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
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
    this.readOnly = false,
    this.autofocus = false,
    this.hintText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: trailing ??
              (controller != null && !readOnly
                  ? _ClearButton(controller: controller!)
                  : null),
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
