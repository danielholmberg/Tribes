import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/services/firebase/auth_service.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';
import 'package:tribes/services/util_service.dart';

GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<DialogService>(() => DialogService());
  locator.registerLazySingleton<UtilService>(() => UtilService());
}