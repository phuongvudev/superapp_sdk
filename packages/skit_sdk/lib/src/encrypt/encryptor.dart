import 'dart:convert';
import 'package:encrypt/encrypt.dart';

abstract class EncryptorBase<Input> {
  /// Encrypts a data with data type [Input] into a string.
  String encrypt(Input data);

  /// Decrypts an encrypted string back into a map of data.
  ///
  /// [encryptedData] - The encrypted string to be decrypted.
  ///
  /// Returns the decrypted Input data.
  Input decrypt(String encryptedData);
}

/// Abstract class for encryption and decryption of data.
abstract class MapEncryptor extends EncryptorBase<Map<String, dynamic>> {
  /// Encrypts a map of data into a string.
  ///
  /// [data] - The map of data to be encrypted.
  ///
  /// Returns the encrypted string.
  @override
  String encrypt(Map<String, dynamic> data);

  /// Decrypts an encrypted string back into a map of data.
  ///
  /// [encryptedData] - The encrypted string to be decrypted.
  ///
  /// Returns the decrypted map of data.
  @override
  Map<String, dynamic> decrypt(String encryptedData);
}

/// Implementation of the Encryptor interface using AES encryption.
class AESEncryptor implements MapEncryptor {
  /// The encryption key used for AES encryption.
  final String encryptionKey;

  /// Creates an instance of [AESEncryptor] with the provided encryption key.
  ///
  /// [encryptionKey] - The key used for encryption and decryption.
  AESEncryptor(this.encryptionKey);

  @override
  String encrypt(Map<String, dynamic> data) {
    // Create an AES key from the encryption key.
    final key = Key.fromUtf8(encryptionKey);

    // Generate an Initialization Vector (IV) of 16 bytes.
    final iv = IV.fromLength(16);

    // Create an AES encryptor.
    final encryptor = Encrypter(AES(key));

    // Convert the data map to a JSON string.
    final jsonData = jsonEncode(data);

    // Encrypt the JSON string using the AES encryptor and IV.
    final encrypted = encryptor.encrypt(jsonData, iv: iv);

    // Return the encrypted data as a Base64-encoded string.
    return encrypted.base64;
  }

  @override
  Map<String, dynamic> decrypt(String encryptedData) {
    // Create an AES key from the encryption key.
    final key = Key.fromUtf8(encryptionKey);

    // Generate an Initialization Vector (IV) of 16 bytes.
    final iv = IV.fromLength(16);

    // Create an AES decryptor.
    final encryptor = Encrypter(AES(key));

    // Decrypt the Base64-encoded string using the AES decryptor and IV.
    final decrypted = encryptor.decrypt64(encryptedData, iv: iv);

    // Convert the decrypted JSON string back to a map and return it.
    return jsonDecode(decrypted);
  }
}
