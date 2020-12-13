import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/test_keys.dart';

import '../test_driver/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Email & Password Sign In", (WidgetTester tester) async {
    /** Assign */
    final emailTextField = find.byKey(ValueKey(TestKeys.signInEmailInput));
    final passwordTextField = find.byKey(ValueKey(TestKeys.signInPasswordInput));
    final signInButton = find.byKey(ValueKey(TestKeys.signInButton));
    final homeAppTitleText = find.byKey(ValueKey(TestKeys.homeAppTitle));

    final String email = 'test@test.test';
    final String password = 'test1234';

    /** Act */
    // Enter email
    //await tester.tap(emailTextField);
    await tester.enterText(emailTextField, email);
    //await takeScreenshot(driver, 'signIn_email');

    // Enter password
    //await tester.tap(passwordTextField);
    await tester.enterText(passwordTextField, password);
    //await takeScreenshot(driver, 'signIn_password');

    // Tap Sign in Button
    await tester.tap(signInButton);
    await delay(750);
    //await takeScreenshot(driver, 'signIn_onButtonPress');

    /** Assert */
    // Check that the widget tree now displays the Home page,
    // thus including the App title 'Tribes' as a widget.
    Text appTitleWidget = tester.widget(homeAppTitleText);
    expect(appTitleWidget.data, Constants.appTitle);
  });
}