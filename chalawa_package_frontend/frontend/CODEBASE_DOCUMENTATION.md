# Chalawa Flutter Package - Codebase Documentation

## Overview
This Flutter package provides encryption-in-transit functionality that is fully compatible with the Node.js TypeScript backend implementation. The package implements AES-256-GCM encryption and Diffie-Hellman key exchange protocols.

## Architecture

### Core Modules

1. **types.dart** - Defines all input/output types for the encryption operations
2. **encryption.dart** - Basic AES-256-GCM encryption with password-derived keys
3. **decryption.dart** - Basic AES-256-GCM decryption with password-derived keys
4. **diffie_hellman.dart** - Diffie-Hellman key exchange implementation
5. **dh_encryption.dart** - AES-256-GCM encryption/decryption using DH shared secrets

### Key Design Decisions

#### Encoding Compatibility
- Uses the same base64 encoding format as Node.js: `encryptedData:iv:authTag`
- SHA-512 for key derivation, taking first 32 characters for AES-256 key
- JSON encoding for plaintext to match Node.js behavior

#### Diffie-Hellman Implementation
- Uses RFC 5114 2048-bit MODP Group (same prime as Node.js)
- Generator = 2 (same as Node.js)
- BigInt operations for large number arithmetic
- Password enhancement using SHA-256 mixing

#### Security Features
- AES-256-GCM for authenticated encryption
- 16-byte random IV for each encryption
- 128-bit authentication tag
- Secure random number generation
- Key validation functions

## Compatibility with Node.js Backend

### Matching Implementations
1. **Key Derivation**: Identical SHA-512 → first 32 chars process
2. **Encryption Format**: Same `data:iv:tag` base64 format
3. **DH Parameters**: Same prime and generator values
4. **JSON Handling**: Both serialize data to JSON before encryption

### Cross-Language Testing
The package includes integration tests that verify compatibility with the Node.js implementation by:
- Testing identical key derivation results
- Verifying same encryption/decryption outputs
- Validating DH shared secret computation

## Usage Patterns

### Client-Server Communication
1. **Initial Handshake**: Both client and server generate DH key pairs
2. **Key Exchange**: Public keys are exchanged
3. **Shared Secret**: Both compute the same shared secret
4. **Secure Communication**: Use shared secret for AES-256-GCM encryption

### Error Handling
- All functions throw descriptive exceptions on failure
- Input validation prevents common misuse patterns
- Format validation ensures compatibility

## Performance Considerations
- BigInt operations are CPU intensive but necessary for DH
- AES-256-GCM is hardware accelerated on most platforms
- Memory efficient with streaming operations where possible

## Security Notes
- All random values use cryptographically secure generators
- Keys are derived using industry-standard methods
- Authentication prevents tampering attacks
- Forward secrecy through ephemeral key exchange
