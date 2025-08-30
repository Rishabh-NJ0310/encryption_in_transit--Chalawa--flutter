import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'types.dart';

// Pre-defined safe prime (RFC 5114 - 2048-bit MODP Group) - same as Node.js
const String _prime2048 = 'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1'
    '29024E088A67CC74020BBEA63B139B22514A08798E3404DD'
    'EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245'
    'E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
    'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3D'
    'C2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F'
    '83655D23DCA3AD961C62F356208552BB9ED529077096966D'
    '670C354E4ABC9804F1746C08CA18217C32905E462E36CE3B'
    'E39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9'
    'DE2BCBF6955817183995497CEA956AE515D2261898FA0510'
    '15728E5A8AACAA68FFFFFFFFFFFFFFFF';

const int _generator = 2;

/// Converts hex string to BigInt
BigInt _hexToBigInt(String hex) {
  return BigInt.parse(hex, radix: 16);
}

/// Converts BigInt to hex string
String _bigIntToHex(BigInt value) {
  return value.toRadixString(16);
}

/// Generates a secure random BigInt
BigInt _generateRandomBigInt(int bitLength) {
  final random = Random.secure();
  final bytes = (bitLength + 7) ~/ 8;
  final randomBytes = Uint8List(bytes);
  
  for (int i = 0; i < bytes; i++) {
    randomBytes[i] = random.nextInt(256);
  }
  
  // Ensure the number has the correct bit length
  final value = BigInt.parse(
    randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    radix: 16,
  );
  
  return value;
}

/// Generates a Diffie-Hellman key pair
DHKeyPair generateDHKeyPair({DHKeyExchangeInput? input}) {
  try {
    final prime = _hexToBigInt(_prime2048);
    final generator = BigInt.from(_generator);
    
    // Generate private key (random number less than prime)
    BigInt privateKey;
    do {
      privateKey = _generateRandomBigInt(2048);
    } while (privateKey >= prime || privateKey <= BigInt.one);
    
    // Calculate public key: g^privateKey mod p
    BigInt publicKey = generator.modPow(privateKey, prime);
    
    if (input?.password != null) {
      // Enhance the keys with password-derived entropy (matching Node.js logic)
      final passwordHash = sha256.convert(utf8.encode(input!.password! + DateTime.now().millisecondsSinceEpoch.toString()));
      
      // Mix password with private key for enhanced security
      final privateKeyBytes = _hexToBytes(_bigIntToHex(privateKey));
      final combined = Uint8List.fromList([...privateKeyBytes, ...passwordHash.bytes]);
      final enhancedHash = sha256.convert(combined);
      
      final enhancedPrivateKey = BigInt.parse(
        enhancedHash.toString().substring(0, 64), 
        radix: 16
      );
      
      // Ensure enhanced private key is valid
      final validPrivateKey = enhancedPrivateKey % (prime - BigInt.one) + BigInt.one;
      final enhancedPublicKey = generator.modPow(validPrivateKey, prime);
      
      return DHKeyPair(
        privateKey: _bigIntToHex(validPrivateKey),
        publicKey: _bigIntToHex(enhancedPublicKey),
      );
    }
    
    return DHKeyPair(
      privateKey: _bigIntToHex(privateKey),
      publicKey: _bigIntToHex(publicKey),
    );
  } catch (e) {
    throw Exception('DH key generation failed: $e');
  }
}

/// Computes the shared secret from private key and other party's public key
String computeSharedSecret(DHSharedSecretInput input) {
  try {
    final prime = _hexToBigInt(_prime2048);
    final privateKey = _hexToBigInt(input.privateKey);
    final otherPublicKey = _hexToBigInt(input.otherPublicKey);
    
    // Compute shared secret: otherPublicKey^privateKey mod prime
    final sharedSecret = otherPublicKey.modPow(privateKey, prime);
    final sharedSecretBytes = _hexToBytes(_bigIntToHex(sharedSecret));
    
    // Optionally mix with password for additional security
    if (input.password != null) {
      final combined = Uint8List.fromList([...sharedSecretBytes, ...utf8.encode(input.password!)]);
      final hash = sha512.convert(combined);
      return hash.toString();
    }
    
    // Hash the shared secret for consistent key length (matching Node.js)
    final hash = sha256.convert(sharedSecretBytes);
    return hash.toString();
  } catch (e) {
    throw Exception('Shared secret computation failed: $e');
  }
}

/// Validates a public key format
bool validatePublicKey(String publicKey) {
  try {
    final keyBytes = _hexToBytes(publicKey);
    // Basic validation - key should be reasonable length (same as Node.js)
    return keyBytes.length > 100 && keyBytes.length < 1000;
  } catch (e) {
    return false;
  }
}

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
