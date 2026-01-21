# 🔐 Better Auth - Implementación Completa

## 📦 ¿Qué se ha preparado?

Se ha creado una implementación completa de **Better Auth** para Flutter siguiendo Clean Architecture y mejores prácticas. Todo está listo para integrar cuando lo decidas, sin afectar tu sistema actual de Firebase.

## 📂 Archivos Creados

### Domain Layer
```
lib/features/auth/domain/
├── entities/
│   ├── auth_user.dart          ✅ Entidad de usuario agnóstica
│   └── auth_session.dart       ✅ Entidad de sesión con tokens
├── repositories/
│   └── auth_repository.dart    ✅ Interface del repositorio
├── errors/
│   └── auth_exceptions.dart    ✅ Excepciones personalizadas
└── domain.dart                 ✅ Barrel file
```

### Data Layer
```
lib/features/auth/data/
├── models/
│   ├── better_auth_user_model.dart     ✅ DTO de usuario
│   └── better_auth_session_model.dart  ✅ DTO de sesión
├── datasources/
│   ├── better_auth_datasource.dart      ✅ Interface
│   └── better_auth_datasource_impl.dart ✅ Implementación con Dio
├── repositories/
│   └── better_auth_repository_impl.dart ✅ Implementación
├── services/
│   ├── better_auth_config.dart          ✅ Configuración
│   └── token_storage_service.dart       ✅ Almacenamiento seguro
└── data.dart                            ✅ Barrel file
```

### Presentation Layer
```
lib/features/auth/presentation/
└── providers/
    └── better_auth_provider.dart        ✅ Providers de Riverpod
```

### Documentación
```
docs/
├── BETTER_AUTH_IMPLEMENTATION.md        ✅ Guía completa de implementación
├── BETTER_AUTH_INTEGRATION_STEPS.md     ✅ Pasos prácticos de integración
└── BETTER_AUTH_README.md               ✅ Este archivo
```

## 🎯 Características Implementadas

### Autenticación
- ✅ Login con email y contraseña
- ✅ Registro de usuarios
- ✅ Cierre de sesión
- ✅ Recuperación de contraseña
- ✅ Verificación de email

### Gestión de Sesión
- ✅ Almacenamiento seguro de tokens
- ✅ Refresh automático de tokens
- ✅ Detección de expiración de sesión
- ✅ Persistencia de sesión entre reinicios

### Gestión de Perfil
- ✅ Actualización de perfil
- ✅ Cambio de contraseña
- ✅ Eliminación de cuenta
- ✅ Campos personalizados (phone, rut, birthday, bio, address)

### Sistema de Roles
- ✅ Roles: guest, user, operator, admin
- ✅ Helpers para verificar roles
- ✅ Integración con guards de rutas

### Manejo de Errores
- ✅ Excepciones tipadas
- ✅ Manejo de errores de red
- ✅ Manejo de errores de validación
- ✅ Mensajes de error amigables

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌────────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ BetterAuthProvider│  │ AuthState    │  │ UI Widgets  │ │
│  └────────────────┘  └──────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────────┐  │
│  │ AuthUser     │  │ AuthSession │  │ AuthRepository│  │
│  │ (Entity)     │  │ (Entity)    │  │ (Interface)   │  │
│  └──────────────┘  └─────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ BetterAuthRepository │  │ BetterAuthDatasource     │ │
│  │ Impl                 │  │ Impl                     │ │
│  └──────────────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                   External Services                      │
│                 ┌─────────────────────┐                  │
│                 │  Better Auth API    │                  │
│                 │  (Backend Server)   │                  │
│                 └─────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Cómo Empezar

### Opción 1: Lectura Rápida (5 minutos)
Lee el archivo [BETTER_AUTH_README.md](BETTER_AUTH_README.md) (este archivo)

### Opción 2: Guía Completa (20 minutos)
Lee [BETTER_AUTH_IMPLEMENTATION.md](BETTER_AUTH_IMPLEMENTATION.md) para entender toda la arquitectura

### Opción 3: Implementación Práctica (1-2 horas)
Sigue paso a paso [BETTER_AUTH_INTEGRATION_STEPS.md](BETTER_AUTH_INTEGRATION_STEPS.md)

## 📝 Quick Start

### 1. Backend (Node.js + Better Auth)

```bash
# Instalar better-auth en tu backend
npm install better-auth

# Configurar (ver BETTER_AUTH_INTEGRATION_STEPS.md para detalles)
```

### 2. Flutter

```dart
// En main.dart, agregar:
final prefs = await SharedPreferences.getInstance();

runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      betterAuthConfigProvider.overrideWithValue(
        BetterAuthConfig(baseUrl: 'http://localhost:3000'),
      ),
    ],
    child: MainApp(),
  ),
);
```

### 3. Usar en tu UI

```dart
// Login
await ref.read(betterAuthProvider.notifier).signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Verificar autenticación
final isAuthenticated = ref.watch(betterAuthProvider).isAuthenticated;

// Obtener usuario
final user = ref.watch(betterAuthProvider).user;
```

## 🔄 Estrategia de Migración

### Fase 1: Pruebas (Sin afectar producción)
- Mantén Firebase como está
- Prueba Better Auth en desarrollo
- Usa pantalla de prueba incluida

### Fase 2: Sistema Dual (Transición)
- Ambos sistemas funcionan en paralelo
- Puedes cambiar con un flag
- Los usuarios pueden elegir

### Fase 3: Migración Completa
- Better Auth como principal
- Migrar usuarios gradualmente
- Eliminar Firebase cuando estés listo

## 💡 Ventajas de Better Auth vs Firebase

| Característica | Firebase Auth | Better Auth |
|----------------|---------------|-------------|
| **Costo** | Escala con usuarios | Tu servidor, costos predecibles |
| **Control** | Limitado | Control total de datos |
| **Personalización** | Limitada | Altamente personalizable |
| **Vendor Lock-in** | Alto | Ninguno |
| **Base de datos** | Firestore/RTDB | Tu DB preferida (PostgreSQL, MySQL, etc.) |
| **Campos custom** | Limitado | Ilimitado |
| **Backend propio** | No | Sí (Node.js, Python, Go, etc.) |

## 🛠️ Tecnologías Usadas

### Flutter
- **flutter_riverpod**: State management
- **dio**: HTTP client
- **shared_preferences**: Almacenamiento local
- **formz**: Validación de formularios (opcional)

### Backend (Recomendado)
- **better-auth**: Framework de autenticación
- **express**: Web framework
- **PostgreSQL**: Base de datos (puedes usar MySQL, MongoDB, etc.)

## 📚 API Reference

### BetterAuthNotifier Methods

```dart
// Autenticación
await signIn({required String email, required String password})
await signUp({required String email, required String password, String? name, ...})
await signOut()

// Gestión de perfil
await updateProfile({String? name, String? image, ...})
await changePassword({required String currentPassword, required String newPassword})
await deleteAccount()

// Utilidades
await sendPasswordResetEmail(String email)
```

### BetterAuthState Properties

```dart
final status              // BetterAuthStatus (loading, authenticated, etc.)
final session             // AuthSession? (token, user, expiresAt)
final user                // AuthUser? (id, email, name, role, etc.)
final token               // String? (JWT token)
final isAuthenticated     // bool
final userRole            // UserRole (guest, user, operator, admin)
final isAdmin             // bool
final isOperator          // bool
final isUser              // bool
final errorMessage        // String?
```

## 🔐 Seguridad

### Tokens
- ✅ JWT tokens con expiración
- ✅ Refresh tokens para renovación
- ✅ Almacenamiento seguro en dispositivo
- ✅ Validación en cada request

### Passwords
- ✅ Hash con bcrypt en backend
- ✅ Validación de fortaleza (configurable)
- ✅ Reset de contraseña por email

### Sesiones
- ✅ Expiración automática
- ✅ Refresh automático
- ✅ Logout en todos los dispositivos (opcional)

## 🐛 Troubleshooting

### Error: "Target of URI doesn't exist"
- Asegúrate de que todos los archivos estén creados
- Ejecuta `flutter pub get`

### Error: "sharedPreferencesProvider must be overridden"
- Inicializa SharedPreferences en main.dart
- Sobrescribe el provider en ProviderScope

### Error de conexión al backend
- Verifica que el backend esté corriendo
- Verifica la URL en `.env`
- En Android, usa `http://10.0.2.2:3000` en lugar de `localhost:3000`

### Token expira muy rápido
- Ajusta `expiresIn` en la configuración del backend
- Implementa refresh automático (ya incluido)

## 📞 Soporte

Si tienes dudas:
1. Revisa la documentación completa en `BETTER_AUTH_IMPLEMENTATION.md`
2. Sigue los pasos en `BETTER_AUTH_INTEGRATION_STEPS.md`
3. Busca ejemplos en el código generado

## ✨ Próximos Pasos

1. [ ] Leer documentación completa
2. [ ] Configurar backend de Better Auth
3. [ ] Probar con la pantalla de test
4. [ ] Integrar en tu flujo de autenticación
5. [ ] Migrar usuarios (si es necesario)
6. [ ] ¡Disfrutar de tu sistema de auth personalizado! 🎉

---

**Nota**: Esta implementación está lista para usar pero NO está activa. Tu sistema actual de Firebase sigue funcionando normalmente. Puedes probar Better Auth sin romper nada.

**Creado**: $(date)
**Versión**: 1.0.0
**Estado**: ✅ Listo para integrar
