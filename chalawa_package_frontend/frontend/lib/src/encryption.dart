import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'types.dart';

/// Encrypts plain text using AES-256-GCM with password-derived key
String encrypt(EncryptionInput input) {
  try {
    // Generate random IV (16 bytes for AES-256-GCM)
    final random = Random.secure();
    final iv = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      iv[i] = random.nextInt(256);
    }

    // Create key from password using SHA-512 hash (same as Node.js implementation)
    final hash = sha512.convert(utf8.encode(input.password));
    final keyString = hash.toString();
    final key = utf8.encode(keyString.substring(0, 32));

    // Initialize AES-256-GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(Uint8List.fromList(key));
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0)); // 128-bit auth tag
    
    cipher.init(true, params); // true = encrypt

    // Convert plaintext to JSON string (to match Node.js behavior)
    final jsonPlainText = jsonEncode(input.plainText);
    final plainTextBytes = utf8.encode(jsonPlainText);
    
    // Encrypt
    final encryptedBytes = cipher.process(plainTextBytes);
    
    // Extract encrypted data and auth tag
    final encryptedData = encryptedBytes.sublist(0, encryptedBytes.length - 16);
    final authTag = encryptedBytes.sublist(encryptedBytes.length - 16);
    
    // Format: encryptedData:iv:authTag (all base64 encoded)
    final encryptedBase64 = base64.encode(encryptedData);
    final ivBase64 = base64.encode(iv);
    final authTagBase64 = base64.encode(authTag);
    
    return '$encryptedBase64:$ivBase64:$authTagBase64';
  } catch (e) {
    throw Exception('Encryption failed: $e');
  }
}
