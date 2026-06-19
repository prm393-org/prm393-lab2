import 'package:flutter/material.dart';

/// Ô tìm kiếm topic kèm dropdown gợi ý các chủ đề mẫu.
///
/// Bấm vào ô → hiện danh sách mẫu; gõ chữ → lọc dần; chọn hoặc Enter để tìm.
class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Tìm chủ đề (vd: fusion, machine learning)…',
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return sampleTopics;
        return sampleTopics
            .where((t) => t.toLowerCase().contains(q));
      },
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
            onFieldSubmitted();
            onSearch(v);
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
            fillColor: cs.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.outlineVariant),
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
