import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../publication/domain/entities/topic.dart';
import 'domain_palette.dart';

/// Khu vực 3 biểu đồ khám phá topic (chuyển bằng SegmentedButton hoặc vuốt):
///   1. Top bài báo — Horizontal Bar (works_count + cited_by_count)
///   2. Tương quan — Bubble (works × citations, cỡ = TB trích dẫn)
///   3. Tỷ trọng lĩnh vực — thanh tỉ lệ + chú giải
/// Tap vào biểu đồ để chọn topic. Bố cục thích ứng theo kích thước màn + cỡ chữ.
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
  late final PageController _controller;
  int _page = 0;

  static const _titles = [
    'Top bài báo',
    'Bài báo × Trích dẫn',
    'Tỷ trọng lĩnh vực',
  ];
  static const _icons = [
    Icons.bar_chart_rounded,
    Icons.bubble_chart_outlined,
    Icons.grid_view_rounded,
  ];

  @override
  void initState() {
    super.initState();
    // viewportFraction < 1 để lộ mép trang kế tiếp → gợi ý "vuốt được".
    _controller = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topics.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final media = MediaQuery.of(context);
    final w = media.size.width;
    final isWide = w >= 600; // tablet / màn lớn
    final isLandscape = media.orientation == Orientation.landscape;
    final textScale = media.textScaler.scale(1).clamp(1.0, 1.5);
    final showSegmentLabels = w >= 380;

    // Chiều cao thích ứng: tablet rộng hơn, landscape thấp hơn, nhân theo cỡ chữ.
    final base = isWide ? 300.0 : (isLandscape ? 190.0 : 250.0);
    final chartHeight = (base * textScale).clamp(180.0, 480.0);

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
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Icon(_icons[_page], size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _titles[_page],
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Bộ chuyển biểu đồ (discoverability + chọn trực tiếp) ─────
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    for (var i = 0; i < 3; i++)
                      ButtonSegment<int>(
                        value: i,
                        icon: Icon(_icons[i], size: 16),
                        label: showSegmentLabels ? Text(_shortLabel(i)) : null,
                      ),
                  ],
                  selected: {_page},
                  onSelectionChanged: (s) => _goTo(s.first),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Vùng biểu đồ (chiều cao thích ứng, không tràn) ───────────
            SizedBox(
              height: chartHeight,
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _ChartPage(
                    child: _HorizontalBarChart(
                      topics: widget.topics,
                      onSelect: widget.onSelect,
                      isWide: isWide,
                    ),
                  ),
                  _ChartPage(
                    child: _BubbleChart(
                      topics: widget.topics,
                      onSelect: widget.onSelect,
                      maxPoints: isWide ? 60 : 30,
                    ),
                  ),
                  _ChartPage(
                    child: _DomainShareChart(
                      topics: widget.topics,
                      onSelect: widget.onSelect,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Chỉ báo trang + chú thích tương tác ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
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
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Chạm vào biểu đồ để chọn chủ đề',
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(int i) => switch (i) {
        0 => 'Top',
        1 => 'Tương quan',
        _ => 'Lĩnh vực',
      };
}

/// Bọc mỗi trang với chút padding ngang để có khe hở giữa các trang khi peeking.
class _ChartPage extends StatelessWidget {
  final Widget child;
  const _ChartPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: child,
    );
  }
}

/// ── Chart 1: Horizontal bar (top theo works_count, kèm cited_by_count) ──
class _HorizontalBarChart extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;
  final bool isWide;

  const _HorizontalBarChart({
    required this.topics,
    required this.onSelect,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final ts = MediaQuery.of(context).textScaler.scale(1).clamp(1.0, 1.5);
    final sorted = [...topics]
      ..sort((a, b) => b.worksCount.compareTo(a.worksCount));
    final maxV = sorted.isEmpty
        ? 1
        : sorted.map((t) => t.worksCount).reduce(math.max).clamp(1, 1 << 62);

    // Số dòng vừa khít chiều cao hiện có → không bao giờ tràn dù cỡ chữ lớn.
    return LayoutBuilder(
      builder: (context, c) {
        final perItem = 60.0 * ts;
        final hardCap = isWide ? 8 : 5;
        final fit = (c.maxHeight / perItem).floor();
        final count =
            fit.clamp(3, hardCap).clamp(1, sorted.length);
        final items = sorted.take(count).toList();

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < items.length; i++)
              _BarRow(
                rank: i + 1,
                topic: items[i],
                maxV: maxV,
                onTap: () => onSelect(items[i]),
              ),
          ],
        );
      },
    );
  }
}

class _BarRow extends StatelessWidget {
  final int rank;
  final Topic topic;
  final num maxV;
  final VoidCallback onTap;

  const _BarRow({
    required this.rank,
    required this.topic,
    required this.maxV,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = DomainPalette.of(topic.domainName);

    return Semantics(
      button: true,
      label: 'Hạng $rank: ${topic.displayName}, '
          '${topic.worksCount} bài báo, ${topic.citedByCount} trích dẫn',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48), // touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _RankBadge(rank: rank),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${NumberFormatter.compact(topic.worksCount)} bài',
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
                          value: (topic.worksCount / maxV).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.format_quote,
                              size: 11,
                              color: cs.onSurface.withValues(alpha: 0.45)),
                          const SizedBox(width: 3),
                          Text(
                            '${NumberFormatter.compact(topic.citedByCount)} trích dẫn',
                            style: tt.labelSmall?.copyWith(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final top3 = rank <= 3;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: top3
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$rank',
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: top3 ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ── Chart 2: Bubble (works × citations, cỡ = TB trích dẫn) ─────────────
class _BubbleChart extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;
  final int maxPoints;

  const _BubbleChart({
    required this.topics,
    required this.onSelect,
    required this.maxPoints,
  });

  double _log(num v) => math.log(v < 1 ? 1 : v) / math.ln10;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pts = topics.take(maxPoints).toList();
    if (pts.isEmpty) return const SizedBox.shrink();

    final maxAvg = pts.map((t) => t.avgCitations).fold<double>(1, math.max);

    final spots = <ScatterSpot>[];
    for (final t in pts) {
      final radius = (6 + (t.avgCitations / maxAvg) * 16).clamp(6.0, 22.0);
      spots.add(
        ScatterSpot(
          _log(t.worksCount),
          _log(t.citedByCount),
          dotPainter: FlDotCirclePainter(
            radius: radius,
            color: DomainPalette.of(t.domainName).withValues(alpha: 0.6),
            strokeColor: cs.surface,
            strokeWidth: 1.2,
          ),
        ),
      );
    }

    Widget axisLabel(double value) => Text(
          NumberFormatter.compact(math.pow(10, value).round()),
          style: TextStyle(
              fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5)),
        );

    return Semantics(
      label: 'Biểu đồ tương quan số bài báo và số trích dẫn của '
          '${pts.length} chủ đề. Kích thước bong bóng thể hiện trung bình '
          'trích dẫn mỗi bài. Chạm vào bong bóng để chọn chủ đề.',
      child: Column(
        children: [
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minX: 0,
                minY: 0,
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipColor: (_) => cs.inverseSurface,
                    getTooltipItems: (spot) {
                      final idx = spots.indexWhere(
                          (s) => s.x == spot.x && s.y == spot.y);
                      if (idx < 0) return null;
                      final t = pts[idx];
                      return ScatterTooltipItem(
                        t.displayName,
                        textStyle: TextStyle(
                          color: cs.onInverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '\n${NumberFormatter.compact(t.worksCount)} bài · '
                                '${NumberFormatter.compact(t.citedByCount)} trích dẫn',
                            style: TextStyle(
                              color: cs.onInverseSurface
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
                    axisNameWidget: Text('Trích dẫn',
                        style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                    axisNameSize: 14,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (v, _) => axisLabel(v),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text('Bài báo',
                        style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                    axisNameSize: 14,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 18,
                      interval: 1,
                      getTitlesWidget: (v, _) => axisLabel(v),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
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
          ),
          const SizedBox(height: 6),
          // Chú giải: ý nghĩa kích thước bong bóng.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 8, color: cs.primary),
              const SizedBox(width: 4),
              Icon(Icons.circle, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Bong bóng lớn = nhiều trích dẫn/bài · trục log',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── Chart 3: Tỷ trọng lĩnh vực (thanh tỉ lệ + chú giải, không phải treemap) ──
class _DomainShareChart extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const _DomainShareChart({required this.topics, required this.onSelect});

  int _sum(List<Topic> ts) => ts.fold(0, (s, t) => s + t.worksCount);

  Color _readableOn(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white
          : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final groups = <String, List<Topic>>{};
    for (final t in topics) {
      groups.putIfAbsent(t.domainName ?? 'Khác', () => []).add(t);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => _sum(b.value).compareTo(_sum(a.value)));
    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold<int>(0, (s, e) => s + _sum(e.value));

    Color colorOf(String key) =>
        DomainPalette.of(key == 'Khác' ? null : key);

    void selectTop(List<Topic> ts) {
      final top = [...ts]
        ..sort((a, b) => b.worksCount.compareTo(a.worksCount));
      if (top.isNotEmpty) onSelect(top.first);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thanh tỉ lệ ngang: nhãn % chỉ hiện trên mảng đủ rộng (>12%).
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                for (final e in entries)
                  Expanded(
                    flex: _sum(e.value).clamp(1, 1 << 30),
                    child: Builder(builder: (_) {
                      final frac = _sum(e.value) / total;
                      final bg = colorOf(e.key);
                      return Semantics(
                        button: true,
                        label: '${e.key}: ${(frac * 100).round()}%',
                        child: GestureDetector(
                          onTap: () => selectTop(e.value),
                          child: Container(
                            color: bg,
                            alignment: Alignment.center,
                            child: frac > 0.12
                                ? Text(
                                    '${(frac * 100).round()}%',
                                    style: TextStyle(
                                      color: _readableOn(bg),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Chú giải đầy đủ (cuộn được) — đảm bảo đọc tốt cả khi nhiều lĩnh vực.
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 2),
            itemBuilder: (context, i) {
              final e = entries[i];
              final frac = _sum(e.value) / total;
              return InkWell(
                onTap: () => selectTop(e.value),
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colorOf(e.key),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${e.value.length} chủ đề · ${(frac * 100).round()}%',
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            size: 16,
                            color: cs.onSurface.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
