/// Types for encryption operations
class EncryptionInput {
  final String plainText;
  final String password;

  const EncryptionInput({
    required this.plainText,
    required this.password,
  });
}

/// Types for decryption operations
class DecryptionInput {
  final String encryptedText;
  final String password;

  const DecryptionInput({
    required this.encryptedText,
    required this.password,
  });
}

/// Types for Diffie-Hellman key exchange
class DHKeyExchangeInput {
  final String? password; // Optional fallback password

  const DHKeyExchangeInput({this.password});
}

/// Diffie-Hellman key pair
class DHKeyPair {
  final String privateKey;
  final String publicKey;

  const DHKeyPair({
    required this.privateKey,
    required this.publicKey,
  });

  @override
  String toString() {
    return 'DHKeyPair{privateKey: ${privateKey.substring(0, 16)}..., publicKey: ${publicKey.substring(0, 16)}...}';
  }
}

/// Types for computing shared secret
class DHSharedSecretInput {
  final String privateKey;
  final String otherPublicKey;
  final String? password; // Optional fallback password

  const DHSharedSecretInput({
    required this.privateKey,
    required this.otherPublicKey,
    this.password,
  });
}

/// Types for DH encryption
class DHEncryptionInput {
  final String plainText;
  final String sharedSecret;

  const DHEncryptionInput({
    required this.plainText,
    required this.sharedSecret,
  });
}

/// Types for DH decryption
class DHDecryptionInput {
  final String encryptedText;
  final String sharedSecret;

  const DHDecryptionInput({
    required this.encryptedText,
    required this.sharedSecret,
  });
}
