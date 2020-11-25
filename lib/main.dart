import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/core/auth/auth_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/dialog_service.dart';
import 'package:tribes/theme.dart';

import 'services/firebase/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AdaptiveThemeMode savedThemeMode = await AdaptiveTheme.getThemeMode();
  setUpLocator(); // get_it
  setUpCustomDialogUI();
  setUpCustomSnackbarUI();
  await Firebase.initializeApp();
  runApp(
    Main(savedThemeMode: savedThemeMode),
    /* 
        // See pubspec.yaml for mor info.
        DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => MyApp(),
        ),
        */
  );
}

void setUpCustomSnackbarUI() {}

class Main extends StatefulWidget {
  final AdaptiveThemeMode savedThemeMode;
  Main({this.savedThemeMode});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  final AuthService _authService = locator<AuthService>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      (widget.savedThemeMode.isDark
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light)
          .copyWith(statusBarColor: Colors.transparent),
    );
    _authService.initListener();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    _authService.disposeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        navigatorKey: locator<NavigationService>().navigatorKey,
        onGenerateRoute: MyRouter.generateRoute,
        initialRoute: MyRouter.authRoute,
        //locale: DevicePreview.of(context).locale,
        //builder: DevicePreview.appBuilder,
        home: AuthView(),
      ),
    );
  }
}
