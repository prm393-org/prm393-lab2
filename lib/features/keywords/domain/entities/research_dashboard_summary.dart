import 'package:equatable/equatable.dart';

import '../../../publication/domain/entities/topic.dart';
import '../../../publication/domain/entities/trend_point.dart';
import '../../../publication/domain/entities/work.dart';

class RankedResearchItem extends Equatable {
  final String name;
  final int count;

  const RankedResearchItem({required this.name, required this.count});

  @override
  List<Object?> get props => [name, count];
}

class ResearchDashboardSummary extends Equatable {
  final Topic topic;
  final int totalPublications;
  final int totalCitations;
  final double averageCitations;
  final int? mostActiveYear;
  final int sampleSize;
  final List<TrendPoint> yearlyTrend;
  final List<RankedResearchItem> topJournals;
  final List<RankedResearchItem> topAuthors;
  final List<Work> topPapers;

  /// Bài báo (có năm xuất bản) dùng cho scatter Năm × Citations.
  final List<Work> scatterPapers;

  const ResearchDashboardSummary({
    required this.topic,
    required this.totalPublications,
    required this.totalCitations,
    required this.averageCitations,
    required this.mostActiveYear,
    required this.sampleSize,
    required this.yearlyTrend,
    required this.topJournals,
    required this.topAuthors,
    required this.topPapers,
    required this.scatterPapers,
  });

  RankedResearchItem? get topJournal =>
      topJournals.isEmpty ? null : topJournals.first;

  RankedResearchItem? get topAuthor =>
      topAuthors.isEmpty ? null : topAuthors.first;

  @override
  List<Object?> get props => [
    topic,
    totalPublications,
    totalCitations,
    averageCitations,
    mostActiveYear,
    sampleSize,
    yearlyTrend,
    topJournals,
    topAuthors,
    topPapers,
    scatterPapers,
  ];
}
