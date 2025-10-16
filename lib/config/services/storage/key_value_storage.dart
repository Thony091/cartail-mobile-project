abstract class KeyValueStorage {

  Future<T?> getValue<T> (String key);
  Future<bool> removekey(String key);
  Future<void> setKey<T>(String key, T value);

}