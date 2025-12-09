import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/config.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Enviroment.initEnvironment();
  
  await Future.delayed(
    const Duration(milliseconds:1000), 
    () => HttpOverrides.global = MyHttpOverrides()
  );
  
  /// Initialize Firebase
  await FirebaseService.init();

  runApp(
    const ProviderScope(child: MainApp())
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final appRouter = ref.watch( goRouterProvider );

    return  MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // Implementación del ModernAppTheme centralizado
      theme: ModernAppTheme().getTheme(),
      // Configuración del título de la app
      title: 'DriveTail - Detailing Center',
      // Builder para configuraciones adicionales
      builder: (context, child) {
        return MediaQuery(
          // Asegurar que el texto no se escale más allá de ciertos límites
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp( 
              minScaleFactor: 0.8, 
              maxScaleFactor: 1.2
            ),
          ),
          child: child!,
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