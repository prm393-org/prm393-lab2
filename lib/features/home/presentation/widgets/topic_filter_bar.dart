import 'package:flutter/material.dart';

import '../cubit/home_state.dart';

/// Hàng chip lọc topic: Phổ biến / Ảnh hưởng / Chất lượng / Theo lĩnh vực.
class TopicFilterBar extends StatelessWidget {
  final TopicSortFilter selected;
  final ValueChanged<TopicSortFilter> onChanged;

  const TopicFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TopicSortFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = TopicSortFilter.values[i];
          final isSel = f == selected;
          return ChoiceChip(
            label: Text(f.label),
            selected: isSel,
            onSelected: (_) => onChanged(f),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              color: isSel
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            selectedColor: Theme.of(context).colorScheme.primary,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
