import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/pin_hash.dart';

// Critical flow #3 (verification half): the lock screen must accept the
// correct PIN and reject anything else. The lock screen's `_verifyPin`
// delegates entirely to `PinHash.verify`, so locking down that contract
// is what actually keeps the door shut.

void main() {
  group('PinHash', () {
    test('verify() accepts the PIN it was hashed from', () {
      final encoded = PinHash.hashForStorage('4321');
      expect(PinHash.verify('4321', encoded), isTrue);
    });

    test('verify() rejects a wrong PIN of the same length', () {
      final encoded = PinHash.hashForStorage('4321');
      expect(PinHash.verify('1234', encoded), isFalse);
      expect(PinHash.verify('0000', encoded), isFalse);
      expect(PinHash.verify('4322', encoded), isFalse);
    });

    test('verify() rejects a wrong-length input', () {
      final encoded = PinHash.hashForStorage('4321');
      expect(PinHash.verify('', encoded), isFalse);
      expect(PinHash.verify('43', encoded), isFalse);
      expect(PinHash.verify('43210', encoded), isFalse);
    });

    test('verify() rejects malformed stored payloads', () {
      // No salt:hash separator
      expect(PinHash.verify('1234', 'not-a-real-hash'), isFalse);
      // Wrong number of parts
      expect(PinHash.verify('1234', 'a:b:c'), isFalse);
      // Invalid base64
      expect(PinHash.verify('1234', '!!!:???'), isFalse);
    });

    test('two hashes of the same PIN differ (salt is random)', () {
      final a = PinHash.hashForStorage('4321');
      final b = PinHash.hashForStorage('4321');
      // If salts collide PBKDF2 outputs match — vanishingly unlikely with
      // 128-bit random salt. If this ever fails the rng is broken.
      expect(a, isNot(equals(b)));
      // Both must still verify against the same PIN.
      expect(PinHash.verify('4321', a), isTrue);
      expect(PinHash.verify('4321', b), isTrue);
    });
  });
}
