import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../domain/entities/research_dashboard_summary.dart';

class ResearchDashboardKpiGrid extends StatelessWidget {
  final ResearchDashboardSummary summary;

  const ResearchDashboardKpiGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(
        label: 'Total Publications',
        value: NumberFormatter.compact(summary.totalPublications),
        detail: 'OpenAlex result count',
        icon: Icons.description_outlined,
      ),
      _KpiData(
        label: 'Total Citations',
        value: NumberFormatter.compact(summary.totalCitations),
        detail: 'Across loaded sample',
        icon: Icons.format_quote,
      ),
      _KpiData(
        label: 'Average Citations',
        value: summary.averageCitations.toStringAsFixed(1),
        detail: 'Per sampled paper',
        icon: Icons.analytics_outlined,
      ),
      _KpiData(
        label: 'Most Active Year',
        value: summary.mostActiveYear?.toString() ?? 'N/A',
        detail: 'Peak sample volume',
        icon: Icons.calendar_month_outlined,
      ),
      _KpiData(
        label: 'Top Journal',
        value: summary.topJournal?.name ?? 'Unknown Journal',
        detail: '${summary.topJournal?.count ?? 0} sampled papers',
        icon: Icons.library_books_outlined,
        isTextValue: true,
      ),
      _KpiData(
        label: 'Top Author',
        value: summary.topAuthor?.name ?? 'Unknown Author',
        detail: '${summary.topAuthor?.count ?? 0} sampled papers',
        icon: Icons.person_outline,
        isTextValue: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        final ratio = constraints.maxWidth < 350 ? 1.02 : 1.14;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) => _KpiCard(data: cards[index]),
        );
      },
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final bool isTextValue;

  const _KpiData({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.isTextValue = false,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.label,
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(data.icon, size: 16, color: cs.primary),
                ),
              ],
            ),
            const Spacer(),
            Text(
              data.value,
              style: (data.isTextValue ? tt.titleMedium : tt.headlineSmall)
                  ?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              data.detail,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.52),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
