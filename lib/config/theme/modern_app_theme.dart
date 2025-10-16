import 'package:flutter/material.dart';

class ModernAppTheme {
  // Singleton
  static final ModernAppTheme _instance = ModernAppTheme._internal();
  factory ModernAppTheme() => _instance;
  ModernAppTheme._internal();

  // ==================== COLORES PRINCIPALES ====================
  
  /// Azul primario - Color principal de la app
  static const Color primaryBlue = Color(0xFF3498db);
  static const Color primaryBlueDark = Color(0xFF2980b9);
  
  /// Púrpura/Violeta - Gradientes de login/register
  static const Color purpleLight = Color(0xFF667eea);
  static const Color purpleDark = Color(0xFF764ba2);
  
  /// Verde - Éxito y confirmaciones
  static const Color successGreen = Color(0xFF27ae60);
  static const Color successGreenLight = Color(0xFF2ecc71);
  
  /// Naranja - Advertencias
  static const Color warningOrange = Color(0xFFf39c12);
  static const Color warningOrangeDark = Color(0xFFe67e22);
  
  /// Rojo - Peligro y errores
  static const Color dangerRed = Color(0xFFe74c3c);
  static const Color dangerRedDark = Color(0xFFc0392b);
  
  /// Grises oscuros - Textos y fondos oscuros
  static const Color darkGray = Color(0xFF2c3e50);
  static const Color darkGrayLight = Color(0xFF34495e);
  
  /// Grises medios - Textos secundarios
  static const Color mediumGray = Color(0xFF7f8c8d);
  static const Color mediumGrayLight = Color(0xFF95a5a6);
  
  /// Grises claros - Fondos
  static const Color lightGray = Color(0xFFecf0f1);
  static const Color backgroundLight = Color(0xFFf8fafc);
  static const Color borderLight = Color(0xFFe2e8f0);

  // ==================== GRADIENTES ====================
  
  /// Gradiente principal (púrpura)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleLight, purpleDark],
  );
  
  /// Gradiente azul
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );
  
  /// Gradiente oscuro (header del menú)
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGray, darkGrayLight],
  );
  
  /// Gradiente de fondo claro
  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      purpleLight.withValues( alpha: .1 ),
      backgroundLight,
    ],
  );
  
  /// Gradiente verde (success)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, successGreenLight],
  );
  
  /// Gradiente naranja (warning)
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningOrange, warningOrangeDark],
  );
  
  /// Gradiente rojo (danger)
  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dangerRed, dangerRedDark],
  );
  
  /// Gradiente gris (secondary)
  static const LinearGradient grayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mediumGrayLight, mediumGray],
  );

  // ==================== SOMBRAS ====================
  
  /// Sombra suave para cards
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues( alpha: .08 ),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Sombra para botones
  static BoxShadow buttonShadow(Color color) => BoxShadow(
    color: color.withValues( alpha: .3 ),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
  
  /// Sombra del drawer
  static List<BoxShadow> get drawerShadow => [
    BoxShadow(
      color: Colors.black.withValues( alpha: .1 ),
      blurRadius: 20,
      offset: const Offset(5, 0),
    ),
  ];

  // ==================== BORDER RADIUS ====================
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(20));
  
  // ==================== ESPACIADO ====================
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==================== ESTILOS DE TEXTO ====================
  
  /// Título grande
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: darkGray,
  );
  
  /// Título medio
  static const TextStyle titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: darkGray,
  );
  
  /// Título pequeño
  static const TextStyle titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: darkGray,
  );
  
  /// Subtítulo
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );
  
  /// Cuerpo de texto
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: darkGray,
    height: 1.5,
  );
  
  /// Texto secundario
  static const TextStyle bodyTextSecondary = TextStyle(
    fontSize: 16,
    color: mediumGray,
    height: 1.5,
  );
  
  /// Texto de caption
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: mediumGray,
  );
  
  /// Texto de botón
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ==================== THEME DATA ====================
  
  /// Genera el ThemeData de Flutter
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      
      // Colores principales
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: purpleLight,
        error: dangerRed,
        surface: Colors.white,
        background: backgroundLight,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: backgroundLight,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
        shadowColor: Colors.black.withValues( alpha: .08 ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLarge,
            vertical: paddingMedium,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: buttonRadius,
          ),
          textStyle: buttonText,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: borderLight),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingMedium,
        ),
        labelStyle: subtitle.copyWith(color: mediumGray),
        hintStyle: caption,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: buttonRadius,
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryBlue.withValues( alpha: .2 ),
        labelStyle: caption,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingSmall,
          vertical: paddingSmall,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: chipRadius,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: titleLarge,
        displayMedium: titleMedium,
        displaySmall: titleSmall,
        headlineMedium: titleMedium,
        headlineSmall: titleSmall,
        titleLarge: titleSmall,
        titleMedium: subtitle,
        bodyLarge: bodyText,
        bodyMedium: bodyTextSecondary,
        bodySmall: caption,
        labelLarge: buttonText,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ==================== UTILIDADES ====================
  
  /// Obtiene el color según el tipo de botón
  static ButtonColors getButtonColors(ModernButtonStyle style) {
    switch (style) {
      case ModernButtonStyle.primary:
        return ButtonColors(
          gradientColors: [primaryBlue, primaryBlueDark],
          shadowColor: primaryBlue.withValues( alpha: .3 ),
        );
      case ModernButtonStyle.secondary:
        return ButtonColors(
          gradientColors: [mediumGrayLight, mediumGray],
          shadowColor: mediumGrayLight.withValues( alpha: .3 ),
        );
      case ModernButtonStyle.success:
        return ButtonColors(
          gradientColors: [successGreen, successGreenLight],
          shadowColor: successGreen.withValues( alpha: .3 ),
        );
      case ModernButtonStyle.warning:
        return ButtonColors(
          gradientColors: [warningOrange, warningOrangeDark],
          shadowColor: warningOrange.withValues( alpha: .3 ),
        );
      case ModernButtonStyle.danger:
        return ButtonColors(
          gradientColors: [dangerRed, dangerRedDark],
          shadowColor: dangerRed.withValues( alpha: .3 ),
        );
    }
  }
  
  /// Obtiene el color según la categoría
  static Color getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('detailing') || categoryLower.contains('limpieza')) {
      return primaryBlue;
    } else if (categoryLower.contains('mecánica') || categoryLower.contains('mecanica')) {
      return dangerRed;
    } else if (categoryLower.contains('pintura')) {
      return warningOrange;
    } else if (categoryLower.contains('neumático') || categoryLower.contains('neumatico')) {
      return darkGray;
    } else if (categoryLower.contains('eléctrico') || categoryLower.contains('electrico')) {
      return successGreen;
    } else {
      return mediumGray;
    }
  }
  
  /// Obtiene el gradiente según el estado
  static LinearGradient getStatusGradient(String status) {
    final statusLower = status.toLowerCase();
    
    if (statusLower.contains('pendiente') || statusLower.contains('pending')) {
      return warningGradient;
    } else if (statusLower.contains('aprobado') || statusLower.contains('approved') || 
               statusLower.contains('completado') || statusLower.contains('completed')) {
      return successGradient;
    } else if (statusLower.contains('rechazado') || statusLower.contains('rejected') ||
               statusLower.contains('cancelado') || statusLower.contains('cancelled')) {
      return dangerGradient;
    } else {
      return grayGradient;
    }
  }
}

/// Enum para los estilos de botones
enum ModernButtonStyle {
  primary,
  secondary,
  success,
  warning,
  danger,
}

/// Clase auxiliar para colores de botones
class ButtonColors {
  final List<Color> gradientColors;
  final Color shadowColor;

  ButtonColors({
    required this.gradientColors,
    required this.shadowColor,
  });
}