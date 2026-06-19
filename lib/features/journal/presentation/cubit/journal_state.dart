import 'package:equatable/equatable.dart';

import '../../../publication/domain/entities/topic.dart';
import '../../../publication/domain/entities/trend_point.dart';
import '../../../publication/domain/entities/work.dart';

/// Một lựa chọn sắp xếp cho danh sách bài báo (giá trị `sort` của OpenAlex).
class WorkSortOption extends Equatable {
  final String label;
  final String value;
  const WorkSortOption(this.label, this.value);

  static const citations = WorkSortOption('Trích dẫn', 'cited_by_count:desc');
  static const newest = WorkSortOption('Mới nhất', 'publication_date:desc');
  static const oldest = WorkSortOption('Cũ nhất', 'publication_date:asc');

  static const all = [citations, newest, oldest];

  static WorkSortOption fromValue(String value) =>
      all.firstWhere((o) => o.value == value, orElse: () => citations);

  @override
  List<Object?> get props => [value];
}

abstract class JournalState extends Equatable {
  const JournalState();
  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {
  const JournalInitial();
}

class JournalLoading extends JournalState {
  final Topic topic;
  const JournalLoading(this.topic);

  @override
  List<Object?> get props => [topic];
}

class JournalLoaded extends JournalState {
  final List<Work> works;
  final List<TrendPoint> trend;
  final Topic topic;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final int? year;
  final WorkSortOption sort;

  const JournalLoaded({
    required this.works,
    required this.topic,
    required this.total,
    this.trend = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.year,
    this.sort = WorkSortOption.citations,
  });

  /// Dải năm cho menu lọc (giảm dần, mới nhất trước).
  ///
  /// Lấy năm nhỏ nhất / lớn nhất từ dữ liệu trend rồi sinh dải liên tục, để
  /// menu không bị thiếu năm khi trend thưa (chỉ có vài điểm dữ liệu).
  List<int> get availableYears {
    if (trend.isEmpty) return const [];
    final years = trend.map((t) => t.year);
    final maxYear = years.reduce((a, b) => a > b ? a : b);
    final minYear = years.reduce((a, b) => a < b ? a : b);
    return [for (var y = maxYear; y >= minYear; y--) y];
  }

  JournalLoaded copyWith({
    List<Work>? works,
    List<TrendPoint>? trend,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    int? year,
    bool clearYear = false,
    WorkSortOption? sort,
  }) =>
      JournalLoaded(
        works: works ?? this.works,
        trend: trend ?? this.trend,
        topic: topic,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        year: clearYear ? null : (year ?? this.year),
        sort: sort ?? this.sort,
      );

  @override
  List<Object?> get props =>
      [works, trend, topic, total, hasMore, isLoadingMore, year, sort];
}

class JournalError extends JournalState {
  final String message;
  final Topic topic;
  const JournalError(this.message, this.topic);

  @override
  List<Object?> get props => [message, topic];
}
