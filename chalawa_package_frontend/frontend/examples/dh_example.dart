import 'package:chalawa/chalawa.dart';

/// Example: Diffie-Hellman Key Exchange Implementation
Future<void> demonstrateDHKeyExchange() async {
  print('=== Diffie-Hellman Key Exchange Demo ===\n');

  // Step 1: Client generates key pair
  print('1. Client generates DH key pair...');
  final clientKeyPair = generateDHKeyPair();
  print('Client Public Key: ${clientKeyPair.publicKey.substring(0, 32)}...');

  // Step 2: Server generates key pair
  print('\n2. Server generates DH key pair...');
  final serverKeyPair = generateDHKeyPair();
  print('Server Public Key: ${serverKeyPair.publicKey.substring(0, 32)}...');

  // Step 3: Both parties exchange public keys and compute shared secret
  print('\n3. Computing shared secrets...');
  
  final clientSharedSecret = computeSharedSecret(DHSharedSecretInput(
    privateKey: clientKeyPair.privateKey,
    otherPublicKey: serverKeyPair.publicKey,
  ));
  
  final serverSharedSecret = computeSharedSecret(DHSharedSecretInput(
    privateKey: serverKeyPair.privateKey,
    otherPublicKey: clientKeyPair.publicKey,
  ));

  // Verify both parties have the same shared secret
  final secretsMatch = clientSharedSecret == serverSharedSecret;
  print('Shared secrets match: $secretsMatch');
  print('Shared Secret: ${clientSharedSecret.substring(0, 32)}...');

  if (!secretsMatch) {
    throw Exception('Shared secrets do not match!');
  }

  // Step 4: Use shared secret for encryption/decryption
  print('\n4. Testing encryption with shared secret...');
  
  final sensitiveData = {
    'userId': 12345,
    'creditCard': '4532-1234-5678-9012',
    'ssn': '123-45-6789',
    'message': 'This is highly confidential information!',
    'timestamp': DateTime.now().toIso8601String(),
  };

  print('Original data: $sensitiveData');

  // Encrypt using shared secret
  final encrypted = dhEncrypt(DHEncryptionInput(
    plainText: sensitiveData.toString(),
    sharedSecret: clientSharedSecret,
  ));

  print('\n5. Encrypted data: ${encrypted.substring(0, 50)}...');

  // Decrypt using shared secret
  final decrypted = dhDecrypt(DHDecryptionInput(
    encryptedText: encrypted,
    sharedSecret: serverSharedSecret,
  ));

  print('\n6. Decrypted data: $decrypted');
  print('Decryption successful: ${decrypted == sensitiveData.toString()}');

  // Step 5: Test with password-enhanced DH
  print('\n7. Testing password-enhanced DH...');
  
  const password = 'super-secret-password-2024';
  final enhancedClientKeyPair = generateDHKeyPair(
    input: DHKeyExchangeInput(password: password),
  );
  final enhancedServerKeyPair = generateDHKeyPair(
    input: DHKeyExchangeInput(password: password),
  );

  final enhancedClientSecret = computeSharedSecret(DHSharedSecretInput(
    privateKey: enhancedClientKeyPair.privateKey,
    otherPublicKey: enhancedServerKeyPair.publicKey,
    password: password,
  ));
  
  final enhancedServerSecret = computeSharedSecret(DHSharedSecretInput(
    privateKey: enhancedServerKeyPair.privateKey,
    otherPublicKey: enhancedClientKeyPair.publicKey,
    password: password,
  ));

  final enhancedSecretsMatch = enhancedClientSecret == enhancedServerSecret;
  print('Enhanced shared secrets match: $enhancedSecretsMatch');

  // Step 6: Test basic encryption/decryption
  print('\n8. Testing basic encryption/decryption...');
  
  const basicMessage = 'Hello from Flutter!';
  const basicPassword = 'flutter-password-123';

  final basicEncrypted = encrypt(EncryptionInput(
    plainText: basicMessage,
    password: basicPassword,
  ));

  print('Basic encrypted: ${basicEncrypted.substring(0, 50)}...');

  final basicDecrypted = decrypt(DecryptionInput(
    encryptedText: basicEncrypted,
    password: basicPassword,
  ));

  print('Basic decrypted: $basicDecrypted');
  print('Basic encryption successful: ${basicDecrypted == basicMessage}');

  print('\n=== Demo completed successfully! ===');
}

void main() async {
  try {
    await demonstrateDHKeyExchange();
  } catch (e) {
    print('Demo failed with error: $e');
  }
}
