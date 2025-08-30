import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'types.dart';

/// Decrypts encrypted text using AES-256-GCM with password-derived key
dynamic decrypt(DecryptionInput input) {
  try {
    // Parse encrypted text format: encryptedData:iv:authTag
    final parts = input.encryptedText.split(':');
    if (parts.length != 3) {
      throw ArgumentError('Invalid encrypted text format');
    }

    final encryptedData = base64.decode(parts[0]);
    final iv = base64.decode(parts[1]);
    final authTag = base64.decode(parts[2]);

    // Create key from password using SHA-512 hash (same as Node.js implementation)
    final hash = sha512.convert(utf8.encode(input.password));
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
    throw Exception('Decryption failed: $e');
  }
}
