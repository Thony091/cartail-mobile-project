# Pasos para Integrar Better Auth - Guía Práctica

Esta guía te llevará paso a paso para integrar Better Auth en tu proyecto sin romper la funcionalidad actual de Firebase.

## 🎯 Estrategia de Migración

Usaremos una **migración gradual** que permite:
- ✅ Mantener Firebase funcionando
- ✅ Probar Better Auth en paralelo
- ✅ Cambiar entre backends con un flag
- ✅ Migrar usuarios gradualmente

## 📋 Checklist de Pasos

### Fase 1: Preparación del Backend (1-2 días)

- [ ] **1.1** Crear proyecto backend con Better Auth
- [ ] **1.2** Configurar base de datos
- [ ] **1.3** Configurar campos personalizados (phone, rut, birthday, role)
- [ ] **1.4** Probar endpoints con Postman/Thunder Client
- [ ] **1.5** Desplegar backend (opcional para dev, usar localhost)

### Fase 2: Configuración en Flutter (30 minutos)

- [ ] **2.1** Actualizar `.env` con URL del backend
- [ ] **2.2** Configurar providers en `main.dart`
- [ ] **2.3** Crear pantalla de prueba para Better Auth

### Fase 3: Implementación Dual (1-2 días)

- [ ] **3.1** Crear `UnifiedAuthProvider` para manejar ambos backends
- [ ] **3.2** Actualizar guards de rutas
- [ ] **3.3** Probar login/registro con Better Auth
- [ ] **3.4** Verificar persistencia de sesión

### Fase 4: Migración de Usuarios (si es necesario)

- [ ] **4.1** Exportar usuarios de Firebase
- [ ] **4.2** Script de migración a tu DB
- [ ] **4.3** Notificar usuarios sobre cambio

### Fase 5: Limpieza (1 día)

- [ ] **5.1** Cambiar backend por defecto a Better Auth
- [ ] **5.2** Eliminar dependencias de Firebase
- [ ] **5.3** Eliminar código legacy

---

## 🚀 Implementación Detallada

### PASO 1: Configurar Backend de Better Auth

#### 1.1 Crear Proyecto Backend

```bash
# Crear carpeta para el backend
mkdir drivetail-auth-backend
cd drivetail-auth-backend

# Inicializar proyecto Node.js
npm init -y

# Instalar dependencias
npm install better-auth express dotenv
npm install -D typescript @types/node @types/express tsx

# Inicializar TypeScript
npx tsc --init
```

#### 1.2 Estructura del Backend

Crea esta estructura:

```
drivetail-auth-backend/
├── src/
│   ├── index.ts
│   ├── auth.ts
│   └── db.ts
├── .env
├── package.json
└── tsconfig.json
```

#### 1.3 Configurar Better Auth (`src/auth.ts`)

```typescript
import { betterAuth } from "better-auth"
import { Pool } from "pg"

// Configurar pool de PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

export const auth = betterAuth({
  database: pool,

  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false, // Cambiar a true en producción

    // Campos personalizados para tu app
    schema: {
      user: {
        fields: {
          phone: {
            type: "string",
            required: false,
          },
          rut: {
            type: "string",
            required: false,
            unique: true,
          },
          birthday: {
            type: "string",
            required: false,
          },
          address: {
            type: "string",
            required: false,
          },
          bio: {
            type: "string",
            required: false,
          },
          role: {
            type: "string",
            required: true,
            default: "user", // user, operator, admin
          },
        }
      }
    }
  },

  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 días
    updateAge: 60 * 60 * 24, // Actualizar cada 24 horas
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60, // 5 minutos
    },
  },

  advanced: {
    generateId: () => {
      // Generar IDs únicos
      return crypto.randomUUID()
    },
  },
})
```

#### 1.4 Servidor Express (`src/index.ts`)

```typescript
import express from "express"
import cors from "cors"
import { auth } from "./auth"
import dotenv from "dotenv"

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

// Middlewares
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}))
app.use(express.json())

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() })
})

// Montar rutas de autenticación
app.all("/api/auth/*", auth.handler)

// Endpoint personalizado para obtener usuario por ID
app.get("/api/users/:id", async (req, res) => {
  try {
    const { id } = req.params
    const token = req.headers.authorization?.replace('Bearer ', '')

    if (!token) {
      return res.status(401).json({ error: 'No autorizado' })
    }

    // Validar sesión
    const session = await auth.api.getSession({ headers: req.headers })
    if (!session) {
      return res.status(401).json({ error: 'Sesión inválida' })
    }

    // Obtener usuario
    const user = await auth.api.getUser({ userId: id })

    res.json(user)
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener usuario' })
  }
})

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`)
  console.log(`📚 Auth API disponible en http://localhost:${PORT}/api/auth/*`)
})
```

#### 1.5 Variables de Entorno (`.env`)

```env
# Base de datos
DATABASE_URL=postgresql://usuario:password@localhost:5432/drivetail_db

# Better Auth
BETTER_AUTH_SECRET=tu-clave-secreta-muy-larga-y-segura-aqui
BETTER_AUTH_URL=http://localhost:3000

# Server
PORT=3000
NODE_ENV=development

# CORS
ALLOWED_ORIGINS=http://localhost:*,capacitor://localhost
```

#### 1.6 Scripts en `package.json`

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

#### 1.7 Iniciar Backend

```bash
npm run dev
```

Deberías ver:
```
🚀 Servidor corriendo en http://localhost:3000
📚 Auth API disponible en http://localhost:3000/api/auth/*
```

---

### PASO 2: Configurar Flutter

#### 2.1 Actualizar `.env` en Flutter

```env
# Agregar al final de tu .env existente
BETTER_AUTH_BASE_URL=http://localhost:3000
```

#### 2.2 Modificar `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de Better Auth
import 'features/auth/presentation/providers/better_auth_provider.dart';
import 'features/auth/data/services/better_auth_config.dart';

// Tus importaciones existentes
import 'config/config.dart';
// ... resto de imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar SharedPreferences para Better Auth
  final prefs = await SharedPreferences.getInstance();

  await Enviroment.initEnvironment();
  await Future.delayed(
    const Duration(milliseconds: 1000),
    () => HttpOverrides.global = MyHttpOverrides(),
  );

  /// Initialize Firebase (mantener por ahora)
  await FirebaseService.init();

  /// Initialize Encryption Service
  final encryptionService = EncryptionService();
  await encryptionService.init();

  /// Initialize Isar Database
  final isarService = IsarService();
  await isarService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Provider de SharedPreferences para Better Auth
        sharedPreferencesProvider.overrideWithValue(prefs),

        // Configuración de Better Auth
        betterAuthConfigProvider.overrideWithValue(
          BetterAuthConfig(
            baseUrl: dotenv.env['BETTER_AUTH_BASE_URL'] ?? 'http://localhost:3000',
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

// ... resto del código
```

---

### PASO 3: Crear Provider Unificado (Sistema Dual)

Crea un nuevo archivo que permita usar ambos sistemas:

#### `lib/features/auth/presentation/providers/unified_auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../../user/domain/entities/user.dart' as legacy;
import 'better_auth_provider.dart';
import '../../../../presentation/providers/auth_provider.dart' as firebase_auth;

/// Enum para seleccionar el backend de autenticación
enum AuthBackend {
  firebase,
  betterAuth,
}

/// Provider para seleccionar el backend
/// Cambia esto a betterAuth cuando estés listo para migrar
final authBackendProvider = StateProvider<AuthBackend>((ref) {
  // Por defecto usa Firebase para no romper nada
  return AuthBackend.firebase;
});

/// Estado unificado que funciona con ambos backends
class UnifiedAuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? name;
  final bool isAdmin;
  final bool isOperator;
  final bool isUser;
  final String? errorMessage;

  const UnifiedAuthState({
    required this.isAuthenticated,
    this.userId,
    this.email,
    this.name,
    this.isAdmin = false,
    this.isOperator = false,
    this.isUser = false,
    this.errorMessage,
  });
}

/// Provider unificado que abstrae Firebase y Better Auth
final unifiedAuthProvider = Provider<UnifiedAuthState>((ref) {
  final backend = ref.watch(authBackendProvider);

  switch (backend) {
    case AuthBackend.firebase:
      final firebaseState = ref.watch(firebase_auth.authProvider);
      return UnifiedAuthState(
        isAuthenticated: firebaseState.authStatus == firebase_auth.AuthStatus.authenticated,
        userId: firebaseState.userData?.uid,
        email: firebaseState.userData?.email,
        name: firebaseState.userData?.nombre,
        isAdmin: firebaseState.isAdmin,
        isOperator: firebaseState.isOperator,
        isUser: firebaseState.isUser,
        errorMessage: firebaseState.errorMessage,
      );

    case AuthBackend.betterAuth:
      final betterAuthState = ref.watch(betterAuthProvider);
      return UnifiedAuthState(
        isAuthenticated: betterAuthState.isAuthenticated,
        userId: betterAuthState.user?.id,
        email: betterAuthState.user?.email,
        name: betterAuthState.user?.name,
        isAdmin: betterAuthState.isAdmin,
        isOperator: betterAuthState.isOperator,
        isUser: betterAuthState.isUser,
        errorMessage: betterAuthState.errorMessage,
      );
  }
});
```

---

### PASO 4: Crear Pantalla de Prueba

#### `lib/features/auth/presentation/pages/better_auth_test_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/better_auth_provider.dart';

class BetterAuthTestPage extends ConsumerStatefulWidget {
  const BetterAuthTestPage({super.key});

  @override
  ConsumerState<BetterAuthTestPage> createState() => _BetterAuthTestPageState();
}

class _BetterAuthTestPageState extends ConsumerState<BetterAuthTestPage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Usuario Test');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Better Auth - Pruebas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado: ${authState.status}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (authState.user != null) ...[
                      Text('ID: ${authState.user!.id}'),
                      Text('Email: ${authState.user!.email}'),
                      Text('Nombre: ${authState.user!.name ?? 'Sin nombre'}'),
                      Text('Rol: ${authState.user!.role.name}'),
                    ],
                    if (authState.errorMessage != null)
                      Text(
                        'Error: ${authState.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Formulario
            if (!authState.isAuthenticated) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre (para registro)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Botones
              ElevatedButton(
                onPressed: authState.status == BetterAuthStatus.loading
                    ? null
                    : () async {
                        try {
                          await ref.read(betterAuthProvider.notifier).signIn(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login exitoso!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                child: authState.status == BetterAuthStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: authState.status == BetterAuthStatus.loading
                    ? null
                    : () async {
                        try {
                          await ref.read(betterAuthProvider.notifier).signUp(
                                email: _emailController.text,
                                password: _passwordController.text,
                                name: _nameController.text,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registro exitoso!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                child: const Text('Registrarse'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  await ref.read(betterAuthProvider.notifier).signOut();
                },
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
```

---

### PASO 5: Agregar Ruta de Prueba

En tu `app_router.dart`:

```dart
import '../features/auth/presentation/pages/better_auth_test_page.dart';

GoRoute(
  path: '/better-auth-test',
  builder: (context, state) => const BetterAuthTestPage(),
),
```

---

## ✅ Verificación

### 1. Verificar Backend

```bash
curl http://localhost:3000/health
```

Debería responder: `{"status":"ok","timestamp":"..."}`

### 2. Verificar Registro

```bash
curl -X POST http://localhost:3000/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

### 3. Probar en Flutter

1. Ejecuta la app
2. Navega a `/better-auth-test`
3. Prueba registro y login
4. Verifica que el token se guarde

---

## 🔄 Cambiar Entre Backends

Para cambiar entre Firebase y Better Auth:

```dart
// En cualquier parte de tu app
ref.read(authBackendProvider.notifier).state = AuthBackend.betterAuth;
```

O crea un botón en settings:

```dart
SwitchListTile(
  title: const Text('Usar Better Auth'),
  value: ref.watch(authBackendProvider) == AuthBackend.betterAuth,
  onChanged: (value) {
    ref.read(authBackendProvider.notifier).state =
        value ? AuthBackend.betterAuth : AuthBackend.firebase;
  },
)
```

---

## 🎉 ¡Listo!

Ahora tienes:
- ✅ Backend de Better Auth funcionando
- ✅ Integración en Flutter lista
- ✅ Sistema dual que permite probar sin romper nada
- ✅ Pantalla de prueba funcional

**Próximo paso**: Probar exhaustivamente y luego migrar usuarios.
