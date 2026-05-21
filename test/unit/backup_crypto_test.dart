import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/backup_crypto.dart';

// Critical flow: an encrypted backup must be readable with the right
// passphrase, reject the wrong one, and detect tampering. A silent
// "decryption succeeds but plaintext is garbage" outcome would corrupt
// the user's profile on restore — that's the bug shape these tests prevent.

void main() {
  group('BackupCrypto', () {
    const sample = '{"app":"Journey Forward","data":{"profile":"x"}}';

    test('round-trips through encrypt/decrypt with the right passphrase', () {
      final ciphertext = BackupCrypto.encrypt(sample, 'correct horse battery');
      final out = BackupCrypto.decrypt(ciphertext, 'correct horse battery');
      expect(out, sample);
    });

    test('two encrypts of the same input produce different ciphertexts', () {
      // Random salt + nonce per encrypt → no ciphertext reuse across backups.
      final a = BackupCrypto.encrypt(sample, 'pass');
      final b = BackupCrypto.encrypt(sample, 'pass');
      expect(a, isNot(equals(b)));
    });

    test('wrong passphrase throws — never returns garbled plaintext', () {
      final ciphertext = BackupCrypto.encrypt(sample, 'right');
      expect(
        () => BackupCrypto.decrypt(ciphertext, 'wrong'),
        throwsA(isA<BackupCryptoException>()),
      );
    });

    test('tampered ciphertext is rejected by the MAC', () {
      final ciphertext = BackupCrypto.encrypt(sample, 'pass');
      // Flip a single byte deep inside the base64 ct field.
      final i = ciphertext.indexOf('"ct":"') + 8;
      final flipped =
          '${ciphertext.substring(0, i)}A${ciphertext.substring(i + 1)}';
      expect(
        () => BackupCrypto.decrypt(flipped, 'pass'),
        throwsA(isA<BackupCryptoException>()),
      );
    });

    test('empty passphrase on encrypt throws (no accidental zero-key)', () {
      expect(() => BackupCrypto.encrypt(sample, ''),
          throwsA(isA<BackupCryptoException>()));
    });

    test('looksEncrypted recognises envelope but not plaintext JSON', () {
      final plain = '{"app":"Journey Forward","data":{}}';
      final enc = BackupCrypto.encrypt(plain, 'pass');
      expect(BackupCrypto.looksEncrypted(enc), isTrue);
      expect(BackupCrypto.looksEncrypted(plain), isFalse);
      expect(BackupCrypto.looksEncrypted('not json'), isFalse);
    });

    test('handles unicode and long plaintext', () {
      final big = 'café — 漢字 — ' * 500;
      final ct = BackupCrypto.encrypt(big, 'p');
      expect(BackupCrypto.decrypt(ct, 'p'), big);
    });
  });
}
