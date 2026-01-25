import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para acceder a la instancia centralizada de FlutterSecureStorage
///
/// Uso:
/// ```dart
/// final secureStorage = ref.watch(secureStorageProvider);
/// await secureStorage.write(key: 'myKey', value: 'myValue');
/// ```
///
/// O sin Riverpod (sincrónico):
/// ```dart
/// final secureStorage = SecureStorageService.instance;
/// ```
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return SecureStorageService.instance;
});

/// Servicio centralizado para acceso seguro a almacenamiento
///
/// Proporciona una instancia única (singleton) de FlutterSecureStorage
/// para toda la aplicación, evitando la creación de múltiples instancias
/// que consumen recursos innecesariamente.
///
/// Configuración:
/// - iOS: Accesibilidad `first_unlock_this_device` (máxima seguridad)
/// - Android: Opciones por defecto
///
/// Ejemplo de uso:
/// ```dart
/// // Con Riverpod (recomendado)
/// final secureStorage = ref.watch(secureStorageProvider);
///
/// // Sin Riverpod
/// final secureStorage = SecureStorageService.instance;
/// ```
class SecureStorageService {
  /// Instancia singleton de FlutterSecureStorage
  static const FlutterSecureStorage _instance = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Obtiene la instancia singleton
  static FlutterSecureStorage get instance => _instance;

  // Constructor privado para prevenir instanciación
  SecureStorageService._();
}
