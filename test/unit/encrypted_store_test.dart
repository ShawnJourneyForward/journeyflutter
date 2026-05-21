import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/encrypted_store.dart';

import '../helpers/test_harness.dart';

// Critical flow #4: when the underlying secure-storage platform fails,
// EncryptedStore.write MUST throw. Silently swallowing the failure was
// the bug that left profile data unsaved on devices where Keystore was
// temporarily unavailable — the user thought their data persisted, then
// found it gone on next launch.

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('write() throws EncryptedStoreException when the channel fails',
      () async {
    // Install a mock that returns an error for write().
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'write') {
        throw PlatformException(
          code: 'Keystore',
          message: 'simulated unavailable',
        );
      }
      return null;
    });

    expect(
      () => EncryptedStore.write('profile', '{"username":"Shawn"}'),
      throwsA(isA<EncryptedStoreException>()),
      reason:
          'Silent swallow would leave callers thinking data persisted '
          'when it did not — that is the bug this is meant to prevent.',
    );

    // Tear down so other tests are unaffected.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('write() round-trips through the in-memory mock', () async {
    installSecureStorageMock();
    resetSecureStorageMock();

    await EncryptedStore.write('profile', 'value-A');
    expect(await EncryptedStore.read('profile'), 'value-A');

    // Overwrite, confirm new value sticks.
    await EncryptedStore.write('profile', 'value-B');
    expect(await EncryptedStore.read('profile'), 'value-B');

    await EncryptedStore.delete('profile');
    expect(await EncryptedStore.read('profile'), isNull);
  });

  test('read() returns null when the platform errors (does NOT throw)',
      () async {
    // Asymmetric on purpose: a read failure is non-destructive — we
    // surface it as "no data" rather than crashing the caller. A write
    // failure is destructive (silent data loss) so it must throw.
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'read') {
        throw PlatformException(code: 'Keystore', message: 'unavailable');
      }
      return null;
    });

    expect(await EncryptedStore.read('profile'), isNull);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
