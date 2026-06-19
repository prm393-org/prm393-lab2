import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../publication/domain/entities/topic.dart';
import 'domain_palette.dart';

/// Khu vực 3 biểu đồ khám phá topic (vuốt ngang để đổi):
/// Horizontal Bar · Bubble · Treemap theo domain. Tap để chọn topic.
class TopicChartsSection extends StatefulWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const TopicChartsSection({
    super.key,
    required this.topics,
    required this.onSelect,
  });

  @override
  State<TopicChartsSection> createState() => _TopicChartsSectionState();
}

class _TopicChartsSectionState extends State<TopicChartsSection> {
  final _controller = PageController();
  int _page = 0;

  static const _titles = ['Top bài báo', 'Bài báo × Trích dẫn', 'Theo lĩnh vực'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topics.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  _titles[_page],
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Vuốt để xem thêm',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _HorizontalBarChart(
                      topics: widget.topics, onSelect: widget.onSelect),
                  _BubbleChart(
                      topics: widget.topics, onSelect: widget.onSelect),
                  _DomainTreemap(
                      topics: widget.topics, onSelect: widget.onSelect),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Chart 1: Horizontal bar (top 5 theo works_count) ──────────────────
class _HorizontalBarChart extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const _HorizontalBarChart({required this.topics, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final top = ([...topics]
          ..sort((a, b) => b.worksCount.compareTo(a.worksCount)))
        .take(5)
        .toList();
    final maxV = top.isEmpty
        ? 1
        : top.map((t) => t.worksCount).reduce(math.max).clamp(1, 1 << 62);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final t in top)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: InkWell(
              onTap: () => onSelect(t),
              borderRadius: BorderRadius.circular(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        NumberFormatter.compact(t.worksCount),
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: t.worksCount / maxV,
                      minHeight: 8,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                          DomainPalette.of(t.domainName)),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// ── Chart 2: Bubble (works_count × cited_by_count, log scale) ──────────
class _BubbleChart extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const _BubbleChart({required this.topics, required this.onSelect});

  double _log(num v) => math.log(v < 1 ? 1 : v) / math.ln10;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pts = topics.take(40).toList();
    if (pts.isEmpty) return const SizedBox.shrink();

    final maxAvg =
        pts.map((t) => t.avgCitations).fold<double>(1, math.max);

    final spots = <ScatterSpot>[];
    for (final t in pts) {
      final radius = 5 + (t.avgCitations / maxAvg) * 13;
      spots.add(
        ScatterSpot(
          _log(t.worksCount),
          _log(t.citedByCount),
          dotPainter: FlDotCirclePainter(
            radius: radius,
            color: DomainPalette.of(t.domainName).withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 6),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: 0,
          minY: 0,
          scatterTouchData: ScatterTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              final idx = response?.touchedSpot?.spotIndex;
              if (idx != null && idx >= 0 && idx < pts.length) {
                onSelect(pts[idx]);
              }
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text('Trích dẫn (log)',
                  style: TextStyle(
                      fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5))),
              axisNameSize: 16,
              sideTitles: const SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Bài báo (log)',
                  style: TextStyle(
                      fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5))),
              axisNameSize: 16,
              sideTitles: const SideTitles(showTitles: false),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cs.outlineVariant, strokeWidth: 0.5),
            getDrawingVerticalLine: (_) =>
                FlLine(color: cs.outlineVariant, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

/// ── Chart 3: Treemap theo domain ──────────────────────────────────────
class _DomainTreemap extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const _DomainTreemap({required this.topics, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Gom theo domain: tổng works + topic tiêu biểu (works nhiều nhất).
    final groups = <String, List<Topic>>{};
    for (final t in topics) {
      groups.putIfAbsent(t.domainName ?? 'Khác', () => []).add(t);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => _sum(b.value).compareTo(_sum(a.value)));
    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold<int>(0, (s, e) => s + _sum(e.value));

    return Column(
      children: [
        for (final e in entries)
          Expanded(
            flex: (_sum(e.value) / total * 100).round().clamp(1, 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                onTap: () {
                  final top = [...e.value]
                    ..sort((a, b) => b.worksCount.compareTo(a.worksCount));
                  onSelect(top.first);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: DomainPalette.of(e.key == 'Khác' ? null : e.key)
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value.length} chủ đề · ${NumberFormatter.compact(_sum(e.value))}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _sum(List<Topic> ts) => ts.fold(0, (s, t) => s + t.worksCount);
}
