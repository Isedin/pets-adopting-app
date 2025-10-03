// lib/services/chat_crypto.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// E2EE helper: X25519 (key agreement) + ChaCha20-Poly1305 (AEAD).
/// - Generates & stores device keypair once (secure storage)
/// - exportPublicKey(): publish to Firestore (base64)
/// - deriveSharedSecret(): per-peer
/// - encrypt/decrypt(): returns/consumes base64 fields
class ChatCrypto {
  static const _privKeyKey = 'chat_privkey_x25519';
  static const _pubKeyKey  = 'chat_pubkey_x25519';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final X25519 _kx = X25519();
  final Cipher _aead = Chacha20.poly1305Aead();

  // Cache the keypair in memory after first load
  KeyPair? _myKeyPair;

  Future<void> _ensureKeyPair() async {
    if (_myKeyPair != null) return;

    // Try to restore previously saved keypair
    final privB64 = await _secure.read(key: _privKeyKey);
    final pubB64  = await _secure.read(key: _pubKeyKey);

    if (privB64 != null && pubB64 != null) {
      final privBytes = base64Decode(privB64);
      final pubBytes  = base64Decode(pubB64);

      // Rebuild with SimpleKeyPairData (concrete), not KeyPair()
      _myKeyPair = SimpleKeyPairData(
        privBytes,
        type: KeyPairType.x25519,
        publicKey: SimplePublicKey(pubBytes, type: KeyPairType.x25519),
      );
      return;
    }

    // No stored keys → generate new
    final generated = await _kx.newKeyPair(); // this is SimpleKeyPair under the hood
    final rawPriv   = await generated.extractPrivateKeyBytes();

    // IMPORTANT: cast to SimplePublicKey to access .bytes
    final pubKey    = (await generated.extractPublicKey());
    final rawPub    = pubKey.bytes;

    await _secure.write(key: _privKeyKey, value: base64Encode(rawPriv));
    await _secure.write(key: _pubKeyKey,  value: base64Encode(rawPub));

    _myKeyPair = generated; // cache generated keypair
  }

  /// Public key bytes (raw). Store as base64 in Firestore users.publicKey.
  Future<Uint8List> exportPublicKey() async {
    await _ensureKeyPair();
    final pk = await _myKeyPair!.extractPublicKey() as SimplePublicKey;
    return Uint8List.fromList(pk.bytes);
  }

  /// If you need the typed public key object.
  Future<SimplePublicKey> myPublicKey() async {
    await _ensureKeyPair();
    return await _myKeyPair!.extractPublicKey() as SimplePublicKey;
  }

  /// X25519 shared secret with peer public key.
  Future<SecretKey> deriveSharedSecret(SimplePublicKey other) async {
    await _ensureKeyPair();
    return await _kx.sharedSecretKey(
      keyPair: _myKeyPair!,
      remotePublicKey: other,
    );
  }

  /// Encrypts plaintext. Returns base64(cipher+tag) and base64(nonce).
  Future<Map<String, String>> encrypt(SecretKey shared, String plainText) async {
    final nonce = _randomNonce(12); // ChaCha20-Poly1305 uses 12-byte nonce
    final secretBox = await _aead.encrypt(
      utf8.encode(plainText),
      secretKey: shared,
      nonce: nonce,
    );

    // Store ciphertext + tag concatenated (easy round-trip)
    final concatenated = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return {
      'cipherText': base64Encode(concatenated),
      'nonce': base64Encode(nonce),
    };
  }

  /// Decrypts from base64(cipher+tag) and base64(nonce).
  Future<String> decrypt(SecretKey shared, String b64Cipher, String b64Nonce) async {
    final nonce = base64Decode(b64Nonce);
    final data  = base64Decode(b64Cipher);

    // Last 16 bytes = Poly1305 tag
    const macLen = 16;
    if (data.length < macLen) {
      throw const FormatException('Invalid ciphertext length');
    }
    final cipher = data.sublist(0, data.length - macLen);
    final mac    = Mac(data.sublist(data.length - macLen));

    final box = SecretBox(cipher, nonce: nonce, mac: mac);
    final clear = await _aead.decrypt(box, secretKey: shared);
    return utf8.decode(clear);
  }

  Uint8List _randomNonce(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => r.nextInt(256)));
  }
}
