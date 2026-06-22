import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Ô tìm kiếm topic kèm dropdown gợi ý các chủ đề mẫu.
///
/// Bấm vào ô → hiện danh sách mẫu; gõ chữ → lọc dần; chọn hoặc Enter để tìm.
class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Search topics (e.g. fusion, machine learning)…',
  });

  /// Các chủ đề mẫu (display_name khớp với OpenAlex topics).
  static const List<String> sampleTopics = [
    'Machine Learning',
    'Deep Learning',
    'Artificial Intelligence',
    'Natural Language Processing',
    'Computer Vision',
    'Climate Change',
    'Renewable Energy',
    'Cancer Research',
    'Genomics',
    'Neuroscience',
    'Quantum Computing',
    'Blockchain',
    'Cybersecurity',
    'Robotics',
    'Bioinformatics',
    'Nanotechnology',
  ];

  /// Gợi ý local khớp với chuỗi đang gõ.
  static Iterable<String> _matchingSuggestions(String input) {
    final q = input.trim().toLowerCase();
    if (q.isEmpty) return sampleTopics;
    return sampleTopics.where((t) => t.toLowerCase().contains(q));
  }

  /// Enter: ưu tiên gợi ý đầu (khớp ô hiển thị), không thì dùng chuỗi gõ.
  static String _resolveQuery(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    final matches = _matchingSuggestions(trimmed).toList();
    if (matches.isNotEmpty) return matches.first;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.darkSurfaceMuted : const Color(0xFFE2E8F0);
    final borderColor =
        isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) =>
          _matchingSuggestions(value.text),
      onSelected: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        onSearch(value);
      },
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: (v) {
            focusNode.unfocus();
            final query = SearchBarWidget._resolveQuery(v);
            if (controller.text != query) {
              controller.value = TextEditingValue(
                text: query,
                selection: TextSelection.collapsed(offset: query.length),
              );
            }
            onSearch(query);
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, v, _) => v.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onSearch('');
                      },
                    ),
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final items = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: cs.outlineVariant),
                  itemBuilder: (context, i) {
                    final t = items[i];
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.tag, size: 18, color: cs.primary),
                      title: Text(t, style: const TextStyle(fontSize: 14)),
                      onTap: () => onSelected(t),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
