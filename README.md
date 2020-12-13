# tribes

A social platform for connecting family and friends in their private Tribes.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Testing
Integration tests are created using the Flutter pub.dev package [integration_test](https://pub.dev/packages/integration_test), which extends the Flutter API libraries [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) and [flutter_driver](https://api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html).

> **Note:** The ```integration_test``` package is now the recommended way to write integration tests. See the [Integration testing](https://flutter.dev/docs/testing/integration-tests/) page for details.

> **Note:** You should only use ```testWidgets``` to declare your tests, or errors will not be reported correctly.

To run the ```test/integration_test/<name>_test.dart``` test with the ```test_driver/integration_test.dart``` driver, use the following command:

```
flutter drive \
 --driver=test_driver/integration_test.dart \
 --target=integration_test/<name>_test.dart
```

### [Firebase Test Lab](https://firebase.google.com/docs/test-lab/?gclid=EAIaIQobChMIs5qVwqW25QIV8iCtBh3DrwyUEAAYASAAEgLFU_D_BwE)

To run a test on Android devices using **Firebase Test Lab**, use *gradle* commands to build an instrumentation test for Android

```
pushd android
# flutter build generates files in android/ for building the app
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=<path_to_test>.dart
popd
```

Upload the generated **debug** *build* APK to Firebase Test Lab with [Google Cloud SDK](https://cloud.google.com/sdk/gcloud/reference/firebase/test/android/run)

```
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk\
  --timeout 2m \
```
