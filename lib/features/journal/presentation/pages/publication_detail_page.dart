import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../publication/domain/entities/work.dart';

class PublicationDetailPage extends StatelessWidget {
  final Work work;

  const PublicationDetailPage({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Publication Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    work.title,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (work.authors.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: work.authors
                          .map(
                            (a) => Chip(
                              label: Text(a.displayName),
                              labelStyle: tt.labelSmall,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: cs.secondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _InfoRow(work: work, cs: cs, tt: tt),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'Abstract', cs: cs),
                  const SizedBox(height: 8),
                  if (work.abstract_ != null && work.abstract_!.isNotEmpty)
                    SelectableText(
                      work.abstract_!,
                      style: tt.bodyMedium?.copyWith(
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    )
                  else
                    Text(
                      'No abstract available for this publication.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _CitationSection(count: work.citedByCount, cs: cs, tt: tt),
                  if (work.doi != null) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    _DoiSection(doi: work.doi!, cs: cs, tt: tt),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Work work;
  final ColorScheme cs;
  final TextTheme tt;
  const _InfoRow({required this.work, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (work.publicationYear != null)
          _tag(Icons.calendar_today_outlined, work.publicationYear.toString()),
        if (work.sourceName != null)
          _tag(Icons.library_books_outlined, work.sourceName!),
        if (work.isOpenAccess)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, size: 12, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'Open Access',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: cs.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

class _CitationSection extends StatelessWidget {
  final int count;
  final ColorScheme cs;
  final TextTheme tt;
  const _CitationSection({
    required this.count,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Citations', cs: cs),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.format_quote, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormatter.compact(count),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                Text(
                  'times cited',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _DoiSection extends StatelessWidget {
  final String doi;
  final ColorScheme cs;
  final TextTheme tt;
  const _DoiSection({required this.doi, required this.cs, required this.tt});

  Future<void> _open() async {
    final uri = Uri.tryParse(doi);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'DOI', cs: cs),
        const SizedBox(height: 10),
        InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.link, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doi,
                    style: tt.bodySmall?.copyWith(color: cs.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.open_in_new, size: 14, color: cs.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
