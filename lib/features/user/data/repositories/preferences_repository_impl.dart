import 'package:portafolio_project/config/constants/preferences_keys.dart';

import '../../../../features/shared/presentation/shared/services/storage/key_value_storage_service.dart';
import '../../domain/entities/user_preferences.dart';
import 'preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final KeyValueStorageService _storage;

  PreferencesRepositoryImpl(this._storage);

  @override
  Future<UserPreferences> getPreferences() async {
    final isDarkMode =
        await _storage.getValue<bool>(PreferencesKeys.themeMode) ?? false;
    final notificationsEnabled =
        await _storage.getValue<bool>(PreferencesKeys.notificationsEnabled) ??
            true;
    final language =
        await _storage.getValue<String>(PreferencesKeys.language) ?? 'es';

    return UserPreferences(
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      language: language,
    );
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await _storage.setKeyValue(PreferencesKeys.themeMode, preferences.isDarkMode);
    await _storage.setKeyValue(
        PreferencesKeys.notificationsEnabled, preferences.notificationsEnabled);
    await _storage.setKeyValue(PreferencesKeys.language, preferences.language);
  }

  @override
  Future<void> setTheme(bool isDarkMode) async {
    await _storage.setKeyValue(PreferencesKeys.themeMode, isDarkMode);
  }

  @override
  Future<void> setNotifications(bool enabled) async {
    await _storage.setKeyValue(PreferencesKeys.notificationsEnabled, enabled);
  }
}
