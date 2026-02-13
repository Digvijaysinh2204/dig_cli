import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CryptoHelper {
  static final _base64Key = dotenv.env['API_KEY']!;
  static final _key = Key(base64Decode(_base64Key));

  /// Generate random 12-byte IV
  static IV generateIV() {
    final rand = Random.secure();
    final iv = Uint8List(12);
    for (int i = 0; i < 12; i++) {
      iv[i] = rand.nextInt(256);
    }
    return IV(iv);
  }

  /// Encrypt data (returns ciphertext + IV)
  static Map<String, String> encryptGCM(String plainText) {
    final iv = generateIV();
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Flutter encrypt package appends the 16-byte tag at the end of encrypted.bytes
    return {
      'iv': base64Encode(iv.bytes),
      'encrypted': base64Encode(encrypted.bytes),
    };
  }

  /// Decrypt data (Flutter ↔ Flutter only)
  static String decryptGCM({
    required String encryptedText,
    required String ivBase64,
  }) {
    final iv = IV(base64Decode(ivBase64));
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));

    final decrypted = encrypter.decrypt(
      Encrypted(base64Decode(encryptedText)),
      iv: iv,
    );

    return decrypted;
  }
}
