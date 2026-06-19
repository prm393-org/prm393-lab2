import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../publication/domain/entities/topic.dart';
import '../../../publication/presentation/widgets/trend_chart.dart';
import '../../../publication/presentation/widgets/work_card.dart';
import '../../../shared/presentation/cubit/selected_topic_cubit.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../widgets/journal_filter_bar.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JournalCubit>(
      create: (ctx) {
        final cubit = getIt<JournalCubit>();
        final selected = ctx.read<SelectedTopicCubit>().state;
        if (selected != null) cubit.loadByTopic(selected);
        return cubit;
      },
      child: BlocListener<SelectedTopicCubit, Topic?>(
        listener: (context, topic) {
          if (topic != null) {
            context.read<JournalCubit>().loadByTopic(topic);
          } else {
            context.read<JournalCubit>().clear();
          }
        },
        child: const _JournalView(),
      ),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [_buildAppBar(context, state), _buildBody(context, state)],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, JournalState state) {
    final topic = switch (state) {
      JournalLoading s => s.topic,
      JournalLoaded s => s.topic,
      JournalError s => s.topic,
      _ => null,
    };

    return SliverAppBar(
      expandedHeight: topic != null ? 130 : 90,
      pinned: true,
      backgroundColor: const Color(0xFF1D4ED8),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      actions: [
        if (state is JournalLoaded)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Tải lại',
            onPressed: () =>
                context.read<JournalCubit>().loadByTopic(state.topic),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14, right: 56),
        title: topic != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (topic.fieldName != null)
                    Text(
                      topic.fieldName!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              )
            : const Text(
                'Bài báo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, JournalState state) {
    if (state is JournalInitial) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_outlined,
                    size: 48,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chưa chọn chủ đề',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Về tab Home, chọn một chủ đề\nđể xem danh sách bài báo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.search),
                  label: const Text('Tìm chủ đề'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is JournalLoading) {
      return const SliverFillRemaining(
        child: LoadingWidget(message: 'Đang tải bài báo…'),
      );
    }

    if (state is JournalError) {
      return SliverFillRemaining(
        child: ErrorStateWidget(
          message: state.message,
          onRetry: () => context.read<JournalCubit>().loadByTopic(state.topic),
        ),
      );
    }

    if (state is JournalLoaded) {
      final isRefreshing = state.works.isEmpty && state.isLoadingMore;
      return SliverMainAxisGroup(
        slivers: [
          if (state.trend.length >= 2)
            SliverToBoxAdapter(child: TrendChart(trend: state.trend)),
          SliverToBoxAdapter(
            child: JournalFilterBar(
              years: state.availableYears,
              selectedYear: state.year,
              sort: state.sort,
              onYearChanged: (y) => context.read<JournalCubit>().setYear(y),
              onSortChanged: (s) => context.read<JournalCubit>().setSort(s),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${state.works.length} / ${state.total} bài báo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sắp xếp: ${state.sort.label}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRefreshing)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            )
          else if (state.works.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text('Không có bài báo nào phù hợp bộ lọc.'),
                ),
              ),
            ),
          SliverList.builder(
            itemCount: state.works.length,
            itemBuilder: (context, i) => WorkCard(
              work: state.works[i],
              onTap: () =>
                  context.push('/journal/detail', extra: state.works[i]),
            ),
          ),
          if (state.isLoadingMore && state.works.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            )
          else if (state.works.isNotEmpty && state.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => context.read<JournalCubit>().loadMore(),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Load More Results'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            )
          else if (state.works.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Center(
                  child: Text(
                    '— Đã hết bài báo —',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
