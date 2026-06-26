import '../../../publication/domain/entities/paged.dart';
import '../../../publication/domain/entities/topic.dart';
import '../../../publication/domain/entities/trend_point.dart';
import '../../../publication/domain/entities/work.dart';
import '../entities/research_dashboard_summary.dart';

class BuildResearchDashboard {
  const BuildResearchDashboard();

  ResearchDashboardSummary call({
    required Topic topic,
    required Paged<Work> worksPage,
  }) {
    final works = worksPage.items;
    final totalCitations = works.fold<int>(
      0,
      (sum, work) => sum + work.citedByCount,
    );

    final yearCounts = <int, int>{};
    final journalCounts = <String, int>{};
    final authorCounts = <String, int>{};

    for (final work in works) {
      final year = work.publicationYear;
      if (year != null) {
        yearCounts[year] = (yearCounts[year] ?? 0) + 1;
      }

      final journal = _safeName(work.sourceName, 'Unknown Journal');
      journalCounts[journal] = (journalCounts[journal] ?? 0) + 1;

      if (work.authors.isEmpty) {
        authorCounts['Unknown Author'] =
            (authorCounts['Unknown Author'] ?? 0) + 1;
      } else {
        final authorsInWork = work.authors
            .map((author) => _safeName(author.displayName, 'Unknown Author'))
            .toSet();
        for (final author in authorsInWork) {
          authorCounts[author] = (authorCounts[author] ?? 0) + 1;
        }
      }
    }

    final yearlyTrend =
        yearCounts.entries
            .map((entry) => TrendPoint(year: entry.key, count: entry.value))
            .toList()
          ..sort((a, b) => a.year.compareTo(b.year));

    final mostActiveYear = yearlyTrend.isEmpty
        ? null
        : yearlyTrend.reduce((current, candidate) {
            if (candidate.count > current.count) return candidate;
            if (candidate.count == current.count &&
                candidate.year > current.year) {
              return candidate;
            }
            return current;
          }).year;

    final topPapers = [...works]
      ..sort((a, b) {
        final citationOrder = b.citedByCount.compareTo(a.citedByCount);
        if (citationOrder != 0) return citationOrder;
        return (b.publicationYear ?? 0).compareTo(a.publicationYear ?? 0);
      });

    // Bài báo có năm xuất bản → dữ liệu cho scatter Năm × Citations.
    final scatterPapers =
        works.where((w) => w.publicationYear != null).toList(growable: false);

    return ResearchDashboardSummary(
      topic: topic,
      totalPublications: worksPage.total,
      totalCitations: totalCitations,
      averageCitations: works.isEmpty ? 0 : totalCitations / works.length,
      mostActiveYear: mostActiveYear,
      sampleSize: works.length,
      yearlyTrend: yearlyTrend,
      topJournals: _rank(journalCounts, limit: 5),
      topAuthors: _rank(authorCounts, limit: 5),
      topPapers: topPapers.take(5).toList(growable: false),
      scatterPapers: scatterPapers,
    );
  }

  List<RankedResearchItem> _rank(
    Map<String, int> counts, {
    required int limit,
  }) {
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countOrder = b.value.compareTo(a.value);
        return countOrder != 0 ? countOrder : a.key.compareTo(b.key);
      });

    return entries
        .take(limit)
        .map((entry) => RankedResearchItem(name: entry.key, count: entry.value))
        .toList(growable: false);
  }

  String _safeName(String? value, String fallback) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }
}
