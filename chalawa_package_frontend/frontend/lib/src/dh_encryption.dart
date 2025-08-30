import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'types.dart';

/// Helper function to convert hex string to bytes
Uint8List _hexToBytes(String hex) {
  final length = hex.length;
  if (length % 2 != 0) {
    hex = '0$hex'; // Pad with leading zero if odd length
  }
  
  final bytes = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < hex.length; i += 2) {
    bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
  }
  return bytes;
}

/// Encrypts data using AES-256-GCM with a Diffie-Hellman shared secret
String dhEncrypt(DHEncryptionInput input) {
  try {
    // Generate random IV (16 bytes for AES-256-GCM)
    final random = Random.secure();
    final iv = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      iv[i] = random.nextInt(256);
    }

    // Derive encryption key from shared secret (same as Node.js implementation)
    // Node.js treats sharedSecret as hex, so we need to convert hex to bytes first
    final sharedSecretBytes = _hexToBytes(input.sharedSecret);
    final hash = sha512.convert(sharedSecretBytes);
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
    throw Exception('DH encryption failed: $e');
  }
}

/// Decrypts data using AES-256-GCM with a Diffie-Hellman shared secret
dynamic dhDecrypt(DHDecryptionInput input) {
  try {
    // Parse encrypted text format: encryptedData:iv:authTag
    final parts = input.encryptedText.split(':');
    if (parts.length != 3) {
      throw ArgumentError('Invalid encrypted text format');
    }

    final encryptedData = base64.decode(parts[0]);
    final iv = base64.decode(parts[1]);
    final authTag = base64.decode(parts[2]);

    // Derive decryption key from shared secret (same as Node.js implementation)
    // Node.js treats sharedSecret as hex, so we need to convert hex to bytes first
    final sharedSecretBytes = _hexToBytes(input.sharedSecret);
    final hash = sha512.convert(sharedSecretBytes);
    final keyString = hash.toString();
    final key = utf8.encode(keyString.substring(0, 32));

    // Combine encrypted data and auth tag for GCM
    final combinedData = Uint8List(encryptedData.length + authTag.length);
    combinedData.setAll(0, encryptedData);
    combinedData.setAll(encryptedData.length, authTag);

    // Initialize AES-256-GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(Uint8List.fromList(key));
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0)); // 128-bit auth tag
    
    cipher.init(false, params); // false = decrypt

    // Decrypt
    final decryptedBytes = cipher.process(combinedData);
    
    // Convert back to string and parse JSON
    final decryptedString = utf8.decode(decryptedBytes);
    return jsonDecode(decryptedString);
  } catch (e) {
    throw Exception('DH decryption failed: $e');
  }
}
