import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de encriptación para datos sensibles
/// Usa AES-256 para encriptar información como tarjetas de crédito
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late final Encrypter _encrypter;
  late final IV _iv;
  bool _initialized = false;

  /// Inicializa el servicio de encriptación
  /// Genera o recupera la clave de encriptación de forma segura
  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Recuperar o generar la clave de encriptación
    String? keyString = prefs.getString('encryption_key');
    String? ivString = prefs.getString('encryption_iv');

    if (keyString == null || ivString == null) {
      // Generar nueva clave e IV
      final key = Key.fromSecureRandom(32); // AES-256
      final iv = IV.fromSecureRandom(16);

      // Guardar en SharedPreferences (en producción, usar más seguridad)
      await prefs.setString('encryption_key', base64.encode(key.bytes));
      await prefs.setString('encryption_iv', base64.encode(iv.bytes));

      _encrypter = Encrypter(AES(key));
      _iv = iv;
    } else {
      // Usar clave existente
      final key = Key(base64.decode(keyString));
      _iv = IV(base64.decode(ivString));
      _encrypter = Encrypter(AES(key));
    }

    _initialized = true;
  }

  /// Encripta un texto plano
  String encrypt(String plainText) {
    if (!_initialized) {
      throw Exception('EncryptionService no inicializado. Llama a init() primero.');
    }
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Desencripta un texto encriptado
  String decrypt(String encryptedText) {
    if (!_initialized) {
      throw Exception('EncryptionService no inicializado. Llama a init() primero.');
    }
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  /// Encripta un Map a JSON encriptado
  String encryptJson(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    return encrypt(jsonString);
  }

  /// Desencripta un JSON encriptado a Map
  Map<String, dynamic> decryptJson(String encryptedJson) {
    final decrypted = decrypt(encryptedJson);
    return json.decode(decrypted) as Map<String, dynamic>;
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;
}
