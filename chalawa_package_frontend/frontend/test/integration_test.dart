import 'package:flutter_test/flutter_test.dart';
import 'package:chalawa/chalawa.dart';

void main() {
  group('Chalawa Encryption Tests', () {
    test('Basic encryption and decryption should work', () {
      const plainText = 'Hello World!';
      const password = 'test-password-123';

      final encrypted = encrypt(const EncryptionInput(
        plainText: plainText,
        password: password,
      ));

      expect(encrypted.contains(':'), true);
      expect(encrypted.split(':').length, 3);

      final decrypted = decrypt(DecryptionInput(
        encryptedText: encrypted,
        password: password,
      ));

      expect(decrypted, plainText);
    });

    test('Diffie-Hellman key exchange should generate matching secrets', () {
      final aliceKeyPair = generateDHKeyPair();
      final bobKeyPair = generateDHKeyPair();

      expect(aliceKeyPair.privateKey.isNotEmpty, true);
      expect(aliceKeyPair.publicKey.isNotEmpty, true);
      expect(bobKeyPair.privateKey.isNotEmpty, true);
      expect(bobKeyPair.publicKey.isNotEmpty, true);

      final aliceSecret = computeSharedSecret(DHSharedSecretInput(
        privateKey: aliceKeyPair.privateKey,
        otherPublicKey: bobKeyPair.publicKey,
      ));

      final bobSecret = computeSharedSecret(DHSharedSecretInput(
        privateKey: bobKeyPair.privateKey,
        otherPublicKey: aliceKeyPair.publicKey,
      ));

      expect(aliceSecret, bobSecret);
      expect(aliceSecret.isNotEmpty, true);
    });

    test('DH encryption and decryption should work', () {
      const plainText = 'Secret message for DH!';
      
      final aliceKeyPair = generateDHKeyPair();
      final bobKeyPair = generateDHKeyPair();

      final sharedSecret = computeSharedSecret(DHSharedSecretInput(
        privateKey: aliceKeyPair.privateKey,
        otherPublicKey: bobKeyPair.publicKey,
      ));

      final encrypted = dhEncrypt(DHEncryptionInput(
        plainText: plainText,
        sharedSecret: sharedSecret,
      ));

      expect(encrypted.contains(':'), true);
      expect(encrypted.split(':').length, 3);

      final decrypted = dhDecrypt(DHDecryptionInput(
        encryptedText: encrypted,
        sharedSecret: sharedSecret,
      ));

      expect(decrypted, plainText);
    });

    test('Password-enhanced DH should generate matching secrets', () {
      const password = 'shared-password-123';
      
      final aliceKeyPair = generateDHKeyPair(
        input: const DHKeyExchangeInput(password: password),
      );
      final bobKeyPair = generateDHKeyPair(
        input: const DHKeyExchangeInput(password: password),
      );

      final aliceSecret = computeSharedSecret(DHSharedSecretInput(
        privateKey: aliceKeyPair.privateKey,
        otherPublicKey: bobKeyPair.publicKey,
        password: password,
      ));

      final bobSecret = computeSharedSecret(DHSharedSecretInput(
        privateKey: bobKeyPair.privateKey,
        otherPublicKey: aliceKeyPair.publicKey,
        password: password,
      ));

      expect(aliceSecret, bobSecret);
      expect(aliceSecret.isNotEmpty, true);
    });

    test('Public key validation should work', () {
      final keyPair = generateDHKeyPair();
      
      expect(validatePublicKey(keyPair.publicKey), true);
      expect(validatePublicKey('invalid-key'), false);
      expect(validatePublicKey(''), false);
    });

    test('Invalid encrypted text format should throw error', () {
      expect(
        () => decrypt(const DecryptionInput(
          encryptedText: 'invalid-format',
          password: 'password',
        )),
        throwsA(isA<Exception>()),
      );

      expect(
        () => dhDecrypt(const DHDecryptionInput(
          encryptedText: 'invalid-format',
          sharedSecret: 'secret',
        )),
        throwsA(isA<Exception>()),
      );
    });
  });
}
