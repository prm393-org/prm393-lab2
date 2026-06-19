import 'package:flutter/material.dart';

import '../cubit/journal_state.dart';

/// Thanh bộ lọc: nút "Bộ lọc" (chọn năm), chip năm đang chọn (xoá được),
/// và menu sắp xếp — bố cục theo thiết kế.
class JournalFilterBar extends StatelessWidget {
  final List<int> years;
  final int? selectedYear;
  final WorkSortOption sort;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<WorkSortOption> onSortChanged;

  const JournalFilterBar({
    super.key,
    required this.years,
    required this.selectedYear,
    required this.sort,
    required this.onYearChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          // Nút "Bộ lọc" — mở menu chọn năm.
          _FilterButton(
            years: years,
            selectedYear: selectedYear,
            onYearChanged: onYearChanged,
          ),
          if (selectedYear != null) ...[
            const SizedBox(width: 8),
            // Chip năm đang chọn, có nút xoá.
            InputChip(
              label: Text('Năm: $selectedYear'),
              onDeleted: () => onYearChanged(null),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor: primary.withValues(alpha: 0.08),
              side: BorderSide(color: primary.withValues(alpha: 0.4)),
              labelStyle: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              deleteIconColor: primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
          const SizedBox(width: 8),
          // Menu sắp xếp.
          PopupMenuButton<WorkSortOption>(
            tooltip: 'Sắp xếp',
            onSelected: onSortChanged,
            itemBuilder: (_) => [
              for (final option in WorkSortOption.all)
                PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option == sort
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: option == sort ? primary : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(option.label),
                    ],
                  ),
                ),
            ],
            child: _Pill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sắp xếp: ${sort.label}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final List<int> years;
  final int? selectedYear;
  final ValueChanged<int?> onYearChanged;

  const _FilterButton({
    required this.years,
    required this.selectedYear,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int?>(
      tooltip: 'Lọc theo năm',
      enabled: years.isNotEmpty,
      onSelected: onYearChanged,
      itemBuilder: (_) => [
        const PopupMenuItem<int?>(value: null, child: Text('Tất cả các năm')),
        const PopupMenuDivider(),
        for (final year in years)
          PopupMenuItem<int?>(
            value: year,
            child: Row(
              children: [
                Icon(
                  year == selectedYear
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 18,
                  color: year == selectedYear
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text('$year'),
              ],
            ),
          ),
      ],
      child: _Pill(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.tune, size: 16),
            SizedBox(width: 6),
            Text('Bộ lọc',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}
