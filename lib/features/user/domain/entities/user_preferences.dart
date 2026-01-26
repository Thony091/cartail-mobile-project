class UserPreferences {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String language;

  const UserPreferences({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.language = 'es',
  });

  UserPreferences copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
  }) =>
      UserPreferences(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        language: language ?? this.language,
      );

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'language': language,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        language: json['language'] as String? ?? 'es',
      );
}
