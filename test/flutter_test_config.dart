import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

// Global test entry point — Flutter looks for this filename and runs it once
// before any test in the same directory tree. We use it to install the
// flutter_secure_storage MethodChannel mock so that every test exercising
// an EncryptedStore-backed notifier (journal, cravings, slips, intentions,
// recovery capital, etc.) has a working in-memory storage backend instead
// of throwing "Binding has not yet been initialized" / silently returning
// null after the recent migration off plain SharedPreferences.
//
// Without this file, ~28 unit tests fail because each notifier's build()
// awaits EncryptedStore.read(), which calls FlutterSecureStorage which has
// no platform binding in pure-Dart test mode.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  installSecureStorageMock();
  // Reset the in-memory secure-storage map before every individual test so
  // state from one test does not leak into the next. setUp/tearDown
  // registered here apply to every group/test declared inside testMain.
  setUp(resetSecureStorageMock);
  await testMain();
}
