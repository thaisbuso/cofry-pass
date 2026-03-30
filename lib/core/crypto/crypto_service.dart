import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class CryptoService {
  final _algorithm = AesGcm.with256bits();

  Future<SecretKey> deriveKeyFromPassword(String password) async {
    final passwordBytes = utf8.encode(password);
    final keyBytes = Uint8List(32);

    for (int i = 0; i < 32; i++) {
      keyBytes[i] = passwordBytes[i % passwordBytes.length];
    }

    return SecretKey(keyBytes);
  }

  Future<Map<String, String>> encryptText({
    required String plainText,
    required String password,
  }) async {
    final secretKey = await deriveKeyFromPassword(password);

    final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  Future<String> decryptText({
    required String cipherText,
    required String nonce,
    required String mac,
    required String password,
  }) async {
    final secretKey = await deriveKeyFromPassword(password);

    final secretBox = SecretBox(
      base64Decode(cipherText),
      nonce: base64Decode(nonce),
      mac: Mac(base64Decode(mac)),
    );

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearBytes);
  }
}