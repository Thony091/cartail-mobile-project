# Implementación de Better Auth para Flutter

Esta guía documenta cómo está estructurada la implementación de Better Auth en el proyecto y cómo migrar desde Firebase Auth.

## 📋 Tabla de Contenidos

- [Estructura del Proyecto](#estructura-del-proyecto)
- [Arquitectura](#arquitectura)
- [Configuración del Backend](#configuración-del-backend)
- [Integración en Flutter](#integración-en-flutter)
- [Guía de Migración](#guía-de-migración)
- [Uso de la API](#uso-de-la-api)
- [Ejemplos de Código](#ejemplos-de-código)

## 📁 Estructura del Proyecto

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   ├── auth_user.dart          # Entidad de usuario (agnóstico del proveedor)
│   │   └── auth_session.dart       # Entidad de sesión
│   ├── repositories/
│   │   └── auth_repository.dart    # Interface del repositorio
│   └── errors/
│       └── auth_exceptions.dart    # Excepciones personalizadas
├── data/
│   ├── models/
│   │   ├── better_auth_user_model.dart     # Modelo de respuesta del usuario
│   │   └── better_auth_session_model.dart  # Modelo de respuesta de sesión
│   ├── datasources/
│   │   ├── better_auth_datasource.dart      # Interface del datasource
│   │   └── better_auth_datasource_impl.dart # Implementación con Dio
│   ├── repositories/
│   │   └── better_auth_repository_impl.dart # Implementación del repositorio
│   └── services/
│       ├── better_auth_config.dart          # Configuración
│       └── token_storage_service.dart       # Almacenamiento de tokens
└── presentation/
    └── providers/
        └── better_auth_provider.dart        # Providers de Riverpod
```

## 🏗️ Arquitectura

La implementación sigue **Clean Architecture** con tres capas:

### Domain Layer (Capa de Dominio)
- **Entities**: Modelos de negocio independientes del framework
- **Repositories**: Interfaces que definen contratos
- **Errors**: Excepciones específicas del dominio

### Data Layer (Capa de Datos)
- **Models**: DTOs que mapean respuestas de la API
- **Datasources**: Comunicación con la API de Better Auth
- **Repositories**: Implementación de las interfaces
- **Services**: Servicios auxiliares (configuración, storage)

### Presentation Layer (Capa de Presentación)
- **Providers**: Estado de la aplicación con Riverpod
- **State Management**: BetterAuthNotifier para manejar autenticación

## 🔧 Configuración del Backend

### 1. Instalación de Better Auth (Backend)

Si aún no tienes un backend con Better Auth, aquí está la configuración básica:

```bash
# Crear proyecto backend
npm init -y
npm install better-auth express
```

### 2. Configuración básica (backend/index.js)

```javascript
import { betterAuth } from "better-auth"
import express from "express"

const app = express()
app.use(express.json())

const auth = betterAuth({
  database: {
    // Tu configuración de base de datos
    provider: "postgresql",
    url: process.env.DATABASE_URL,
  },
  emailAndPassword: {
    enabled: true,
    // Campos adicionales personalizados
    additionalFields: {
      phone: { type: "string" },
      rut: { type: "string" },
      birthday: { type: "string" },
      address: { type: "string" },
      bio: { type: "string" },
      role: { type: "string", default: "user" },
    }
  },
  session: {
    expiresIn: 60 * 60 * 24, // 24 horas
    updateAge: 60 * 60, // 1 hora
  }
})

// Montar las rutas de autenticación
app.use("/api/auth/*", auth.handler)

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000")
})
```

### 3. Variables de Entorno (.env)

```env
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
BETTER_AUTH_SECRET=your-secret-key-here
BETTER_AUTH_URL=http://localhost:3000
```

## 📱 Integración en Flutter

### 1. Instalar Dependencias

Estas dependencias ya están en tu `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.9.0
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.5.3
```

### 2. Configurar en main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/providers/better_auth_provider.dart';
import 'features/auth/data/services/better_auth_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribir el provider con la instancia real
        sharedPreferencesProvider.overrideWithValue(prefs),

        // Configurar la URL del backend
        betterAuthConfigProvider.overrideWithValue(
          BetterAuthConfig(
            baseUrl: 'https://tu-backend.com', // Cambia esto a tu URL
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}
```

### 3. Variables de Entorno en Flutter

Crea o actualiza tu `.env`:

```env
BETTER_AUTH_BASE_URL=http://localhost:3000
# BETTER_AUTH_BASE_URL=https://tu-backend-produccion.com  # Para producción
```

Luego en tu código:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// En main.dart, antes de runApp:
await dotenv.load(fileName: ".env");

// Configurar el provider:
betterAuthConfigProvider.overrideWithValue(
  BetterAuthConfig(
    baseUrl: dotenv.env['BETTER_AUTH_BASE_URL'] ?? 'http://localhost:3000',
  ),
),
```

## 🔄 Guía de Migración desde Firebase Auth

### Comparación de APIs

| Firebase Auth | Better Auth |
|--------------|-------------|
| `FirebaseAuth.instance.signInWithEmailAndPassword()` | `ref.read(betterAuthProvider.notifier).signIn()` |
| `FirebaseAuth.instance.createUserWithEmailAndPassword()` | `ref.read(betterAuthProvider.notifier).signUp()` |
| `FirebaseAuth.instance.signOut()` | `ref.read(betterAuthProvider.notifier).signOut()` |
| `FirebaseAuth.instance.sendPasswordResetEmail()` | `ref.read(betterAuthProvider.notifier).sendPasswordResetEmail()` |
| `FirebaseAuth.instance.currentUser` | `ref.watch(betterAuthProvider).user` |

### Paso 1: Mantener Ambos Sistemas (Fase de Transición)

Puedes crear un wrapper que permita usar ambos:

```dart
// lib/features/auth/presentation/providers/unified_auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthBackend { firebase, betterAuth }

final authBackendProvider = StateProvider<AuthBackend>((ref) {
  // Por defecto usa Firebase, cambia a betterAuth cuando estés listo
  return AuthBackend.firebase;
});

final unifiedAuthProvider = Provider((ref) {
  final backend = ref.watch(authBackendProvider);

  switch (backend) {
    case AuthBackend.firebase:
      return ref.watch(authProvider); // Tu provider actual de Firebase
    case AuthBackend.betterAuth:
      return ref.watch(betterAuthProvider);
  }
});
```

### Paso 2: Migración de Datos de Usuarios

Si necesitas migrar usuarios existentes de Firebase a tu backend:

```dart
// Script de migración (ejecutar una sola vez)
Future<void> migrateUsersFromFirebase() async {
  // 1. Exportar usuarios desde Firebase (Admin SDK en backend)
  // 2. Importar a tu base de datos de Better Auth
  // 3. Notificar a usuarios para que restablezcan contraseña
}
```

### Paso 3: Actualizar UI Components

Antes (Firebase):
```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authProvider);

    if (authState.authStatus == AuthStatus.authenticated) {
      return HomeScreen();
    }
    return LoginScreen();
  },
)
```

Después (Better Auth):
```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(betterAuthProvider);

    if (authState.status == BetterAuthStatus.authenticated) {
      return HomeScreen();
    }
    return LoginScreen();
  },
)
```

## 💻 Uso de la API

### Inicio de Sesión

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(betterAuthProvider.notifier);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authNotifier.signIn(
            email: 'usuario@example.com',
            password: 'password123',
          );
          // Navegar a home
        } catch (e) {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Text('Iniciar Sesión'),
    );
  }
}
```

### Registro

```dart
await authNotifier.signUp(
  email: 'nuevo@example.com',
  password: 'password123',
  name: 'Juan Pérez',
  phone: '+56912345678',
  rut: '12345678-9',
  birthday: '1990-01-01',
);
```

### Verificar Estado de Autenticación

```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(betterAuthProvider);

    return authState.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (state) {
        if (state.isAuthenticated) {
          return Text('Bienvenido ${state.user?.name}');
        }
        return Text('No autenticado');
      },
    );
  },
)
```

### Actualizar Perfil

```dart
await authNotifier.updateProfile(
  name: 'Nuevo Nombre',
  phone: '+56987654321',
  bio: 'Mi biografía actualizada',
);
```

### Cerrar Sesión

```dart
await authNotifier.signOut();
```

## 📝 Ejemplos de Código

### Guard de Rutas con Go Router

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetterAuthGuard extends Redirect {
  final Ref ref;

  BetterAuthGuard(this.ref);

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(betterAuthProvider);

    final isAuthenticated = authState.isAuthenticated;
    final isGoingToLogin = state.matchedLocation == '/login';

    // Si no está autenticado y no va al login, redirigir a login
    if (!isAuthenticated && !isGoingToLogin) {
      return '/login';
    }

    // Si está autenticado y va al login, redirigir a home
    if (isAuthenticated && isGoingToLogin) {
      return '/';
    }

    return null; // No redirigir
  }
}
```

### Pantalla de Perfil

```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(betterAuthProvider);
    final user = authState.user;

    if (user == null) {
      return Center(child: Text('No hay usuario autenticado'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Column(
        children: [
          if (user.image != null)
            CircleAvatar(
              backgroundImage: NetworkImage(user.image!),
              radius: 50,
            ),
          Text('Nombre: ${user.name ?? 'Sin nombre'}'),
          Text('Email: ${user.email}'),
          Text('Teléfono: ${user.phone ?? 'No especificado'}'),
          Text('Rol: ${user.role.name}'),
          ElevatedButton(
            onPressed: () async {
              await ref.read(betterAuthProvider.notifier).signOut();
            },
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
```

### Manejo de Roles

```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(betterAuthProvider);

    if (authState.isAdmin) {
      return AdminDashboard();
    } else if (authState.isOperator) {
      return OperatorDashboard();
    } else if (authState.isUser) {
      return UserDashboard();
    } else {
      return GuestView();
    }
  },
)
```

## 🔒 Seguridad

### Almacenamiento Seguro de Tokens

Los tokens se almacenan usando `SharedPreferences`. Para mayor seguridad, considera usar:

```yaml
# En pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

Y actualiza `TokenStorageService` para usar secure storage:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
```

### Refresh de Tokens Automático

El sistema ya incluye refresh automático de tokens. La sesión se refresca automáticamente cuando:
- El token ha expirado
- Se detecta un error 401 (no autorizado)

## 🐛 Debugging

### Habilitar Logs de Dio

```dart
import 'package:dio/dio.dart';

final dio = Dio()
  ..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
```

### Ver Estado de Autenticación

```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(betterAuthProvider);

    return Text('Estado: ${authState.status}');
  },
)
```

## 📞 Soporte

Si encuentras problemas:
1. Verifica que el backend esté corriendo
2. Verifica las URLs en la configuración
3. Revisa los logs de Dio para ver las requests/responses
4. Verifica que SharedPreferences esté inicializado

## 🚀 Próximos Pasos

1. [ ] Configurar el backend de Better Auth
2. [ ] Actualizar las variables de entorno
3. [ ] Probar el sistema en desarrollo
4. [ ] Migrar usuarios si es necesario
5. [ ] Actualizar la UI para usar Better Auth
6. [ ] Eliminar dependencias de Firebase cuando todo funcione
