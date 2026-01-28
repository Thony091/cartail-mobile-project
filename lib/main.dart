import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/config.dart';
import 'config/services/storage/encryption_service.dart';
import 'config/services/storage/isar_service.dart';
import 'config/theme/theme_provider.dart';
import 'core/logging/logger_service.dart';
import 'presentation/widgets/connectivity_banner.dart';
import 'presentation/widgets/debug_fab_button.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el logger global
  initializeLogger();

  await Enviroment.initEnvironment();

  await Future.delayed(
    const Duration(milliseconds:1000),
    () => HttpOverrides.global = MyHttpOverrides()
  );
  
  // Background FCM 
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
  /// Initialize Firebase
  await FirebaseService.init();

  // Captura errores de Flutter (UI / framework)
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Captura errores async que no pasan por FlutterError
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };

  /// Initialize Encryption Service (for sensitive data) - Servicios locales
  final encryptionService = EncryptionService();
  await encryptionService.init();

  /// Initialize Isar Database (for local storage)
  final isarService = IsarService();
  await isarService.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final appRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ModernAppTheme();

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // Tema claro
      theme: appTheme.getTheme(),
      // Tema oscuro
      darkTheme: appTheme.getDarkTheme(),
      // Modo de tema dinámico (light, dark, o system)
      themeMode: themeMode,
      // Configuración del título de la app
      title: 'DriveTail - Detailing Center',
      // Builder para configuraciones adicionales
      builder: (context, child) {
        return ConnectivityBannerLayer(
          child: MediaQuery(
            // Asegurar que el texto no se escale más allá de ciertos límites
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              ),
            ),
            child: Stack(
              children: [
                child!,
                // Debug FAB button (solo en debug mode)
                DebugFabButton(
                  onTap: () => appRouter.push('/debug/connectivity'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
