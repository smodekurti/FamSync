import 'package:get_it/get_it.dart';

final GetIt di = GetIt.instance;

var _didRegister = false;

void registerDependencies() {
  if (_didRegister) return;
  _didRegister = true;

  // Core singletons can be registered here.
  // Example placeholders for future services:
  // di.registerLazySingleton<AnalyticsService>(() => FirebaseAnalyticsService());
  // di.registerLazySingleton<NotificationService>(() => LocalNotificationService());
}


