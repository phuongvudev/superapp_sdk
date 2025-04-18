import 'dart:async';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

abstract class Encryptor {
  String encrypt(Map<String, dynamic> data);

  Map<String, dynamic> decrypt(String encryptedData);
}

class AESEncryptor implements Encryptor {
  final String encryptionKey;

  AESEncryptor(this.encryptionKey);

  @override
  String encrypt(Map<String, dynamic> data) {
    final key = Key.fromUtf8(encryptionKey);
    final iv = IV.fromLength(16); // Initialization Vector (IV)
    final encryptor = Encrypter(AES(key));

    final jsonData = jsonEncode(data);
    final encrypted = encryptor.encrypt(jsonData, iv: iv);
    return encrypted.base64;
  }

  @override
  Map<String, dynamic> decrypt(String encryptedData) {
    final key = Key.fromUtf8(encryptionKey);
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(key));

    final decrypted = encryptor.decrypt64(encryptedData, iv: iv);
    return jsonDecode(decrypted);
  }
}
