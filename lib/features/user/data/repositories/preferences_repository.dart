import '../../domain/entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
  Future<void> setTheme(bool isDarkMode);
  Future<void> setNotifications(bool enabled);
}
