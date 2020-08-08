import 'package:get_it/get_it.dart';
import 'package:tribes/core/auth/register/register_view_model.dart';
import 'package:tribes/core/auth/sign_in/sign_in_view_model.dart';
import 'package:tribes/core/chat/chat_view_model.dart';
import 'package:tribes/core/foundation/foundation_view_model.dart';
import 'package:tribes/core/home/home_view_model.dart';
import 'package:tribes/core/map/map_view_model.dart';
import 'package:tribes/core/profile/profile_view_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/services/dialog_service.dart';
import 'package:tribes/services/firebase_auth_service.dart';
import 'package:tribes/services/navigation_service.dart';
import 'package:tribes/services/storage_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {

  // Services
  locator.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<DialogService>(() => DialogService());

  // ViewModels
  locator.registerLazySingleton<FoundationViewModel>(() => FoundationViewModel());
  locator.registerLazySingleton<SignInViewModel>(() => SignInViewModel());
  locator.registerLazySingleton<RegisterViewModel>(() => RegisterViewModel());
  locator.registerLazySingleton<HomeViewModel>(() => HomeViewModel());
  locator.registerLazySingleton<ProfileViewModel>(() => ProfileViewModel());
  locator.registerLazySingleton<MapViewModel>(() => MapViewModel());
  locator.registerLazySingleton<ChatViewModel>(() => ChatViewModel());

}