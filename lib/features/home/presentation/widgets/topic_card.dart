import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../publication/domain/entities/topic.dart';
import 'domain_palette.dart';

/// Thẻ topic: domain/field, display_name, description, keywords,
/// works_count, cited_by_count và trung bình trích dẫn.
class TopicCard extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = DomainPalette.of(topic.domainName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (topic.domainName != null)
                    _badge(topic.domainName!.toUpperCase(), accent),
                  const Spacer(),
                  if (isSelected)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Đang chọn',
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                topic.displayName,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (topic.fieldName != null) ...[
                const SizedBox(height: 2),
                Text(
                  topic.fieldName!,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ],
              if (topic.description != null &&
                  topic.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  topic.description!,
                  style: tt.bodySmall?.copyWith(height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (topic.keywords.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: topic.keywords
                      .take(4)
                      .map((k) => _keyword(k, cs))
                      .toList(),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _stat(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Bài báo',
                    value: NumberFormatter.compact(topic.worksCount),
                  ),
                  _stat(
                    context,
                    icon: Icons.format_quote,
                    label: 'Trích dẫn',
                    value: NumberFormatter.compact(topic.citedByCount),
                  ),
                  _stat(
                    context,
                    icon: Icons.trending_up,
                    label: 'TB trích dẫn',
                    value: topic.avgCitations.toStringAsFixed(1),
                    color: accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  Widget _keyword(String k, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        k,
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _stat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color ?? cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                value,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: tt.labelSmall
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}
