import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';

/// Cấu hình điều hướng toàn app (go_router).
///
/// Khi triển khai UI, thay route placeholder bên dưới bằng `StatefulShellRoute`
/// chứa 4 tab: Home | Journal | Keywords | Profile, và route push cho
/// `PublicationDetailPage`.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SetupPlaceholderPage(),
      ),

      // TODO(team): thay bằng shell 4 tab khi làm UI, ví dụ:
      // StatefulShellRoute.indexedStack(
      //   builder: (context, state, navigationShell) =>
      //       MainScaffold(navigationShell: navigationShell),
      //   branches: [
      //     StatefulShellBranch(routes: [GoRoute(path: '/home', ...)]),
      //     StatefulShellBranch(routes: [GoRoute(path: '/journal', ...)]),
      //     StatefulShellBranch(routes: [GoRoute(path: '/keywords', ...)]),
      //     StatefulShellBranch(routes: [GoRoute(path: '/profile', ...)]),
      //   ],
      // ),
    ],
  );
}

/// Trang tạm thời xác nhận project đã setup xong. Xoá khi bắt đầu làm UI.
class _SetupPlaceholderPage extends StatelessWidget {
  const _SetupPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 64),
              SizedBox(height: 16),
              Text(
                'Project skeleton đã sẵn sàng.\nBắt đầu triển khai Home | Journal | Keywords | Profile.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
