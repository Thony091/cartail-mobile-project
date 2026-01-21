/// Interfaz para un servicio de almacenamiento de pares clave-valor.
abstract class KeyValueStorageService{
  /// Establece un valor asociado a una clave en el almacenamiento.
  Future<void> setKeyValue<T> ( String key, T value);
  /// Obtiene el valor asociado a una clave desde el almacenamiento.
  Future<T?> getValue<T> ( String key );
  /// Elimina un par clave-valor del almacenamiento.
  Future<bool> removeKey ( String key );
}