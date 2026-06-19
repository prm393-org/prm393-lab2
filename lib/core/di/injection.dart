import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

/// Service locator toàn cục.
final GetIt getIt = GetIt.instance;

/// Đăng ký dependency hạ tầng (core). Mỗi feature tự đăng ký
/// datasource / repository / usecase / bloc của mình ở hàm riêng và
/// gọi tại đây (vd: `_initHome(getIt)`).
Future<void> configureDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton<ApiClient>(() {
    final client = ApiClient(getIt<Dio>());
    // Nạp credential mặc định từ .env (user có thể override trong Settings).
    client.setCredentials(
      apiKey: AppConfig.defaultApiKey,
      mailto: AppConfig.defaultMailto,
    );
    return client;
  });

  // Features — đăng ký tại đây khi triển khai:
  // _initHome(getIt);
  // _initJournal(getIt);
  // _initKeywords(getIt);
  // _initProfile(getIt);
}
