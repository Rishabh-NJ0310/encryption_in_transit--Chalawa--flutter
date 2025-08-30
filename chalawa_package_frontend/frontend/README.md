# Chalawa - Flutter Encryption Package

A Flutter package for applying encryption at transit state, designed to be compatible with the Node.js TypeScript backend implementation.

## Features

- **AES-256-GCM Encryption**: Secure symmetric encryption with authentication
- **Diffie-Hellman Key Exchange**: Secure key agreement protocol
- **Cross-Platform Compatibility**: Works seamlessly with Node.js TypeScript backend
- **Password Enhancement**: Optional password-based key derivation
- **JSON Encoding**: Automatic JSON serialization for complex data types

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  chalawa: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Encryption/Decryption

```dart
import 'package:chalawa/chalawa.dart';

// Encrypt data
final encrypted = encrypt(EncryptionInput(
  plainText: 'Hello World!',
  password: 'your-secret-password',
));

// Decrypt data
final decrypted = decrypt(DecryptionInput(
  encryptedText: encrypted,
  password: 'your-secret-password',
));
```

### Diffie-Hellman Key Exchange

```dart
import 'package:chalawa/chalawa.dart';

// Generate key pairs
final aliceKeyPair = generateDHKeyPair();
final bobKeyPair = generateDHKeyPair();

// Compute shared secrets
final aliceSecret = computeSharedSecret(DHSharedSecretInput(
  privateKey: aliceKeyPair.privateKey,
  otherPublicKey: bobKeyPair.publicKey,
));

final bobSecret = computeSharedSecret(DHSharedSecretInput(
  privateKey: bobKeyPair.privateKey,
  otherPublicKey: aliceKeyPair.publicKey,
));

// Both secrets will be identical
assert(aliceSecret == bobSecret);

// Encrypt using shared secret
final encrypted = dhEncrypt(DHEncryptionInput(
  plainText: 'Secret message',
  sharedSecret: aliceSecret,
));

// Decrypt using shared secret
final decrypted = dhDecrypt(DHDecryptionInput(
  encryptedText: encrypted,
  sharedSecret: bobSecret,
));
```

### Password-Enhanced DH

```dart
const password = 'shared-password';

final aliceKeyPair = generateDHKeyPair(
  input: DHKeyExchangeInput(password: password),
);
final bobKeyPair = generateDHKeyPair(
  input: DHKeyExchangeInput(password: password),
);

final sharedSecret = computeSharedSecret(DHSharedSecretInput(
  privateKey: aliceKeyPair.privateKey,
  otherPublicKey: bobKeyPair.publicKey,
  password: password,
));
```

## Compatibility

This Flutter package is designed to be fully compatible with the Node.js TypeScript backend implementation. The encryption formats, key derivation methods, and algorithms are identical between both implementations.

### Key Compatibility Features:

- Same AES-256-GCM implementation
- Identical key derivation using SHA-512
- Compatible base64 encoding
- Same Diffie-Hellman parameters (RFC 5114 - 2048-bit MODP Group)
- Matching JSON serialization

## Example

See the [example](examples/dh_example.dart) for a complete demonstration of all features.

## Testing

Run the tests with:
```bash
flutter test
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
