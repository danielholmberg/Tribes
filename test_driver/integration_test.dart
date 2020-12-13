import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> delay([int milliseconds = 250]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();

  // Uses the Extended Integration Driver, see used import.
  // https://pub.dev/packages/integration_test#driver-entrypoint
  await integrationDriver(
    driver: driver,
    onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
      return true;
    },
  );
}