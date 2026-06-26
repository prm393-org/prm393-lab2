import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../publication/domain/entities/topic.dart';
import 'domain_palette.dart';

/// Khu vực "Research landscape": treemap 2 cấp (domain → topic) khám phá bức
/// tranh chủ đề. Tap một lĩnh vực để xem topic bên trong, tap topic để chọn.
class TopicChartsSection extends StatelessWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const TopicChartsSection({
    super.key,
    required this.topics,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final media = MediaQuery.of(context);
    final w = media.size.width;
    final isWide = w >= 600;
    final isLandscape = media.orientation == Orientation.landscape;
    final textScale = media.textScaler.scale(1).clamp(1.0, 1.5);

    // Chiều cao thích ứng: tablet rộng hơn, landscape thấp hơn, nhân theo cỡ chữ.
    final base = isWide ? 320.0 : (isLandscape ? 200.0 : 260.0);
    final chartHeight = (base * textScale).clamp(200.0, 480.0);

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
                Icon(Icons.grid_view_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Research landscape',
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: chartHeight,
              child: _DomainShareChart(topics: topics, onSelect: onSelect),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap a field to explore its topics',
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Research Landscape — Treemap 2 cấp (domain → topic) ──
///
/// Cấp 1: mỗi ô là một lĩnh vực (domain), to nhỏ theo tổng số bài. Tap để
/// "lặn" vào xem các topic bên trong (cấp 2). Cách này gọn & dễ đọc trên
/// mobile hơn là nhồi toàn bộ topic vào một treemap phẳng.
class _DomainShareChart extends StatefulWidget {
  final List<Topic> topics;
  final ValueChanged<Topic> onSelect;

  const _DomainShareChart({required this.topics, required this.onSelect});

  @override
  State<_DomainShareChart> createState() => _DomainShareChartState();
}

class _DomainShareChartState extends State<_DomainShareChart> {
  String? _openDomain;

  int _sum(List<Topic> ts) => ts.fold(0, (s, t) => s + t.worksCount);

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Topic>>{};
    for (final t in widget.topics) {
      groups.putIfAbsent(t.domainName ?? 'Other', () => []).add(t);
    }
    for (final list in groups.values) {
      list.sort((a, b) => b.worksCount.compareTo(a.worksCount));
    }
    if (groups.isEmpty) return const SizedBox.shrink();

    // Domain đang mở có thể không còn sau khi đổi filter/search → quay về cấp 1.
    final open =
        _openDomain != null && groups.containsKey(_openDomain) ? _openDomain : null;

    return open == null
        ? _buildDomainLevel(groups)
        : _buildTopicLevel(open, groups[open]!);
  }

  /// Cấp 1: treemap các domain.
  Widget _buildDomainLevel(Map<String, List<Topic>> groups) {
    final entries = groups.entries.toList()
      ..sort((a, b) => _sum(b.value).compareTo(_sum(a.value)));

    return _Treemap(
      values: entries.map((e) => _sum(e.value).toDouble()).toList(),
      tileBuilder: (i) {
        final e = entries[i];
        return _TreemapTile(
          title: e.key,
          subtitle: '${e.value.length} topics',
          color: DomainPalette.of(e.key == 'Other' ? null : e.key),
          drillable: true,
          onTap: () => setState(() => _openDomain = e.key),
        );
      },
      count: entries.length,
    );
  }

  /// Cấp 2: breadcrumb quay lại + treemap các topic trong domain.
  Widget _buildTopicLevel(String domain, List<Topic> topics) {
    final cs = Theme.of(context).colorScheme;
    final shown = topics.where((t) => t.worksCount > 0).take(14).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _openDomain = null),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  '  ·  ${topics.length} topics',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _Treemap(
            values: shown.map((t) => t.worksCount.toDouble()).toList(),
            count: shown.length,
            tileBuilder: (i) => _TreemapTile(
              title: shown[i].displayName,
              subtitle: '${NumberFormatter.compact(shown[i].worksCount)} papers',
              color: DomainPalette.of(shown[i].domainName),
              onTap: () => widget.onSelect(shown[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Khung treemap: nhận danh sách [values] (diện tích) + builder cho từng ô.
class _Treemap extends StatelessWidget {
  final List<double> values;
  final int count;
  final Widget Function(int index) tileBuilder;

  const _Treemap({
    required this.values,
    required this.count,
    required this.tileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LayoutBuilder(
        builder: (context, c) {
          final rects =
              _squarify(values, Rect.fromLTWH(0, 0, c.maxWidth, c.maxHeight));
          return SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Stack(
              children: [
                for (var i = 0; i < rects.length; i++)
                  Positioned.fromRect(
                    rect: rects[i].deflate(1),
                    child: tileBuilder(i),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Squarified treemap (Bruls et al.): chia [container] thành các ô có diện
/// tích tỉ lệ [values], ưu tiên ô gần vuông để dễ đọc. [values] đã sắp giảm dần.
List<Rect> _squarify(List<double> values, Rect container) {
  final total = values.fold<double>(0, (a, b) => a + b);
  if (total <= 0 || container.width <= 0 || container.height <= 0) return [];

  final scale = (container.width * container.height) / total;
  final areas = values.map((v) => v * scale).toList();

  final rects = <Rect>[];
  var x = container.left;
  var y = container.top;
  var w = container.width;
  var h = container.height;

  var start = 0;
  while (start < areas.length) {
    final shortSide = math.min(w, h);
    var end = start;
    var rowSum = areas[start];
    var worst = _worstRatio(areas, start, end, rowSum, shortSide);
    while (end + 1 < areas.length) {
      final newSum = rowSum + areas[end + 1];
      final newWorst = _worstRatio(areas, start, end + 1, newSum, shortSide);
      if (newWorst > worst) break;
      worst = newWorst;
      rowSum = newSum;
      end++;
    }

    if (w >= h) {
      final stripW = rowSum / h;
      var yy = y;
      for (var i = start; i <= end; i++) {
        final cellH = areas[i] / stripW;
        rects.add(Rect.fromLTWH(x, yy, stripW, cellH));
        yy += cellH;
      }
      x += stripW;
      w -= stripW;
    } else {
      final stripH = rowSum / w;
      var xx = x;
      for (var i = start; i <= end; i++) {
        final cellW = areas[i] / stripH;
        rects.add(Rect.fromLTWH(xx, y, cellW, stripH));
        xx += cellW;
      }
      y += stripH;
      h -= stripH;
    }
    start = end + 1;
  }
  return rects;
}

double _worstRatio(
    List<double> areas, int start, int end, double sum, double shortSide) {
  var maxA = areas[start];
  var minA = areas[start];
  for (var i = start + 1; i <= end; i++) {
    if (areas[i] > maxA) maxA = areas[i];
    if (areas[i] < minA) minA = areas[i];
  }
  final s2 = sum * sum;
  final side2 = shortSide * shortSide;
  if (s2 == 0 || minA == 0) return double.infinity;
  return math.max((side2 * maxA) / s2, s2 / (side2 * minA));
}

/// Một ô treemap dùng chung cho cả domain & topic.
class _TreemapTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  /// Domain (cấp 1) thì hiện icon gợi ý "tap để xem topic bên trong".
  final bool drillable;

  const _TreemapTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.drillable = false,
  });

  Color _readableOn(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white
          : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final textColor = _readableOn(color);
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          // Clip để chữ không bao giờ tràn ra ngoài ô (hết lỗi overflow).
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LayoutBuilder(
              builder: (context, c) {
                // Ô quá nhỏ thì chỉ hiện màu, không cố nhồi chữ (tránh cắt dọc).
                final showLabel = c.maxWidth >= 48 && c.maxHeight >= 24;
                if (!showLabel) return const SizedBox.expand();

                final showSub = c.maxHeight >= 44;
                final maxLines = (c.maxHeight ~/ 14).clamp(1, 3);

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ),
                          if (showSub && subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.75),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (drillable && c.maxWidth >= 60 && c.maxHeight >= 40)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.zoom_in,
                          size: 14,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
