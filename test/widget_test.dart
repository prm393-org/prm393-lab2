import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/app.dart';
import 'package:journal_trend_analyzer/core/di/injection.dart';
import 'package:journal_trend_analyzer/core/error/failures.dart';
import 'package:journal_trend_analyzer/features/home/presentation/cubit/home_cubit.dart';
import 'package:journal_trend_analyzer/features/publication/domain/entities/paged.dart';
import 'package:journal_trend_analyzer/features/publication/domain/entities/topic.dart';
import 'package:journal_trend_analyzer/features/publication/domain/entities/trend_point.dart';
import 'package:journal_trend_analyzer/features/publication/domain/entities/work.dart';
import 'package:journal_trend_analyzer/features/publication/domain/repositories/publication_repository.dart';
import 'package:journal_trend_analyzer/features/publication/domain/usecases/search_topics.dart';
import 'package:journal_trend_analyzer/features/shared/presentation/cubit/selected_topic_cubit.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    final repository = _InMemoryPublicationRepository();
    getIt.registerSingleton<SelectedTopicCubit>(SelectedTopicCubit());
    getIt.registerFactory<HomeCubit>(() => HomeCubit(SearchTopics(repository)));
  });

  tearDown(() => getIt.reset());

  testWidgets('App khởi động và hiển thị trang setup placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _InMemoryPublicationRepository implements PublicationRepository {
  @override
  Future<Either<Failure, Paged<Topic>>> searchTopics({
    String? query,
    String sort = 'works_count:desc',
    int page = 1,
    int perPage = 25,
  }) async {
    return Right(
      Paged<Topic>(items: const [], total: 0, page: page, perPage: perPage),
    );
  }

  @override
  Future<Either<Failure, Paged<Work>>> getWorksByTopic(
    String topicId, {
    int page = 1,
    int perPage = 25,
    int? year,
    String sort = 'cited_by_count:desc',
  }) async {
    return Right(
      Paged<Work>(items: const [], total: 0, page: page, perPage: perPage),
    );
  }

  @override
  Future<Either<Failure, List<TrendPoint>>> getTopicTrend(
    String topicId,
  ) async {
    return const Right([]);
  }
}
