import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preferences_repository.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/entities/user_preferences.dart';
import '../../../shared/presentation/shared/services/storage/key_value_storage_service_impl.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final storage = KeyValueStorageServiceImpl();
  return PreferencesRepositoryImpl(storage);
});

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final repository = ref.watch(preferencesRepositoryProvider);
  return UserPreferencesNotifier(repository);
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final PreferencesRepository _repository;

  UserPreferencesNotifier(this._repository)
      : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    state = await _repository.getPreferences();
  }

  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    await _repository.setTheme(newValue);
  }

  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newValue);
    await _repository.setNotifications(newValue);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _repository.savePreferences(state);
  }
}
