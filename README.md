# DriveTail - Detailing Center

Aplicación móvil multiplataforma desarrollada en Flutter para la gestión de un centro de detailing automotriz. La aplicación ofrece funcionalidades completas para clientes y administradores, incluyendo catálogo de productos y servicios, sistema de reservas, mensajería, y galería de trabajos realizados.

## Descripción

DriveTail es una solución integral que permite:

- **Para clientes:**
  - Explorar productos y servicios de detailing automotriz
  - Realizar reservas de servicios
  - Ver galería de trabajos realizados
  - Gestionar carrito de compras
  - Enviar mensajes de contacto
  - Gestionar perfil de usuario

- **Para administradores:**
  - Gestionar catálogo de productos (CRUD completo)
  - Gestionar servicios disponibles (CRUD completo)
  - Gestionar galería de trabajos realizados
  - Administrar reservas de clientes
  - Responder mensajes de contacto
  - Ver estadísticas y métricas

## Características principales

- Autenticación de usuarios con Firebase Auth
- Base de datos en tiempo real con Cloud Firestore
- Notificaciones push con Firebase Cloud Messaging
- Diseño moderno y responsivo
- Interfaz de usuario intuitiva con animaciones
- Sistema de navegación con go_router
- Gestión de estado con Riverpod
- Soporte multiplataforma (Android, iOS, Web)
- Sistema de almacenamiento local con SharedPreferences
- Validación de formularios con Formz
- Galería de imágenes con Image Picker
- Integración con Google Maps
- Sistema de calendario para reservas

## Tecnologías y librerías utilizadas

### Core
- **Flutter SDK**: ^3.8.0
- **flutter_riverpod** (^2.6.1): Gestión de estado reactivo
- **go_router** (^6.2.0): Sistema de navegación y routing

### Firebase
- **firebase_core** (^4.0.0): Configuración base de Firebase
- **firebase_auth** (^6.0.1): Autenticación de usuarios
- **cloud_firestore** (^6.0.0): Base de datos NoSQL en tiempo real
- **firebase_messaging** (^16.0.0): Notificaciones push

### UI/UX
- **animate_do** (^4.2.0): Animaciones predefinidas
- **font_awesome_flutter** (^10.10.0): Iconos de Font Awesome
- **flutter_staggered_grid_view** (^0.7.0): Grids personalizados
- **flutter_svg** (^2.0.13): Soporte para imágenes SVG
- **marquee** (^2.3.0): Textos animados tipo marquesina
- **cupertino_icons** (^1.0.8): Iconos estilo iOS

### Formularios y validación
- **formz** (^0.8.0): Validación de formularios

### Networking
- **dio** (^5.9.0): Cliente HTTP para peticiones

### Utilidades
- **shared_preferences** (^2.5.3): Almacenamiento local key-value
- **image_picker** (^1.2.0): Selección de imágenes desde cámara/galería
- **flutter_dotenv** (^6.0.0): Gestión de variables de entorno
- **intl** (^0.20.2): Internacionalización y formateo

### Calendario y mapas
- **flutter_calendar_carousel** (^2.5.4): Widget de calendario
- **google_maps_flutter** (^2.12.3): Integración con Google Maps

### Comunicación
- **mailto** (^2.0.0): Enlaces mailto
- **url_launcher** (^6.3.2): Abrir URLs y enlaces externos
- **mailer** (^6.5.0): Envío de emails

### Configuración de app
- **flutter_launcher_icons** (^0.14.4): Generación de iconos de app
- **flutter_native_splash** (^2.4.6): Pantalla de splash nativa
- **flutter_local_notifications** (^19.4.0): Notificaciones locales
- **change_app_package_name** (^1.5.0): Cambiar nombre de paquete

### Testing
- **lorem_ipsum** (^0.0.3): Generación de texto placeholder

## Requisitos previos

- Flutter SDK 3.8.0 o superior (última compilación exitosa con 3.35.2)
- Dart SDK incluido con Flutter
- Java 14 JDK (para desarrollo móvil)
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Firebase con proyecto configurado
- Google Maps API Key (para funcionalidad de mapas)

## Instalación

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd PortfolioProject
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Crear un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# Agregar tus variables de entorno aquí
# Ejemplo:
# API_URL=https://tu-api.com
# GOOGLE_MAPS_API_KEY=tu_api_key
```

### 4. Configurar Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar aplicaciones Android/iOS según sea necesario
3. Descargar y colocar los archivos de configuración:
   - Android: `google-services.json` en `android/app/`
   - iOS: `GoogleService-Info.plist` en `ios/Runner/`
4. El archivo `firebase_options.dart` ya está generado en `lib/`

### 5. Configurar Firebase Services

Habilitar en Firebase Console:
- Authentication (Email/Password)
- Cloud Firestore
- Cloud Messaging
- Storage (si se usa)

### 6. Generar iconos y splash screen (opcional)

```bash
# Generar iconos de la aplicación
flutter pub run flutter_launcher_icons

# Generar splash screen nativo
flutter pub run flutter_native_splash:create
```

### 7. Cambiar nombre de paquete (opcional)

```bash
flutter pub run change_app_package_name:main com.tuempresa.tunombre
```

## Ejecución

### Modo desarrollo

```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome

# Especificar dispositivo
flutter run -d <device_id>
```

### Modo release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Estructura del proyecto

```
lib/
├── config/                 # Configuraciones generales
│   ├── constants/         # Constantes de la aplicación
│   ├── router/            # Configuración de rutas
│   └── services/          # Servicios (Firebase, Storage, etc.)
│       ├── firebase/      # Servicios de Firebase
│       ├── storage/       # Almacenamiento local
│       └── helpers/       # Funciones helper
├── domain/                # Capa de dominio
│   ├── datasources/       # Interfaces de fuentes de datos
│   ├── entities/          # Entidades de negocio
│   │   ├── user.dart
│   │   ├── product.dart
│   │   ├── services.dart
│   │   ├── works.dart
│   │   ├── reservation.dart
│   │   └── message.dart
│   └── repositories/      # Interfaces de repositorios
├── infrastructure/        # Implementación de infraestructura
│   ├── datasources/       # Implementaciones de datasources
│   ├── mappers/           # Mappers de datos
│   ├── models/            # Modelos de datos
│   ├── repositories/      # Implementaciones de repositorios
│   └── errors/            # Manejo de errores
└── presentation/          # Capa de presentación
    ├── pages/             # Páginas de la aplicación
    │   ├── auth/          # Pantallas de autenticación
    │   │   ├── login_page.dart
    │   │   ├── register_page.dart
    │   │   ├── modern_home_page.dart
    │   │   ├── modern_help_page.dart
    │   │   └── ...
    │   ├── admin_pages/   # Pantallas de administrador
    │   ├── product/       # Productos
    │   ├── services/      # Servicios
    │   ├── our_works/     # Galería de trabajos
    │   ├── reservations/  # Reservas
    │   ├── message/       # Mensajes
    │   ├── profile/       # Perfil de usuario
    │   └── cart_shop/     # Carrito de compras
    ├── providers/         # Proveedores de Riverpod
    ├── shared/            # Widgets y utilidades compartidas
    │   ├── inputs/        # Validadores de formularios
    │   ├── widgets/       # Widgets reutilizables
    │   └── services/      # Servicios compartidos
    └── widgets/           # Widgets personalizados
```

## Arquitectura

El proyecto implementa una arquitectura limpia (Clean Architecture) con las siguientes capas:

- **Domain**: Contiene la lógica de negocio pura
- **Infrastructure**: Implementación de acceso a datos y servicios externos
- **Presentation**: UI y gestión de estado con Riverpod

### Patrones utilizados

- Repository Pattern
- Provider Pattern (Riverpod)
- Mapper Pattern
- Form Validation con Formz

## Funcionalidades principales

### Autenticación
- Login con email y contraseña
- Registro de nuevos usuarios
- Recuperación de contraseña
- Roles de usuario (cliente/administrador)
- Persistencia de sesión

### Productos
- Catálogo de productos
- Detalle de producto con imágenes
- Búsqueda y filtrado
- CRUD completo (admin)
- Gestión de stock

### Servicios
- Listado de servicios disponibles
- Detalle de servicio
- CRUD completo (admin)
- Sistema de reservas integrado

### Reservas
- Calendario interactivo
- Selección de fecha y hora
- Gestión de reservas
- Notificaciones de confirmación
- Panel de administración de reservas

### Trabajos realizados (Portfolio)
- Galería de imágenes
- Detalle de cada trabajo
- CRUD completo (admin)
- Presentación visual atractiva

### Mensajería
- Formulario de contacto
- Bandeja de mensajes (admin)
- Sistema de respuestas
- Gestión de tickets

### Carrito de compras
- Agregar/eliminar productos
- Actualizar cantidades
- Resumen de compra
- Proceso de checkout

### Perfil de usuario
- Visualización de datos
- Edición de perfil
- Configuración de cuenta
- Historial de reservas y compras

## Configuración de Firebase

### Firestore Collections recomendadas

```
users/
  - uid (string)
  - nombre (string)
  - email (string)
  - telefono (string)
  - rut (string)
  - fechaNacimiento (timestamp)
  - isAdmin (boolean)
  - createdAt (timestamp)
  - updatedAt (timestamp)

products/
  - id (string)
  - nombre (string)
  - descripcion (string)
  - precio (number)
  - stock (number)
  - images (array)
  - categoria (string)
  - disponible (boolean)
  - createdAt (timestamp)
  - updatedAt (timestamp)

services/
  - id (string)
  - nombre (string)
  - descripcion (string)
  - duracion (number)
  - precio (number)
  - images (array)
  - disponible (boolean)
  - createdAt (timestamp)

works/
  - id (string)
  - titulo (string)
  - descripcion (string)
  - images (array)
  - fecha (timestamp)
  - categoria (string)
  - destacado (boolean)

reservations/
  - id (string)
  - userId (string)
  - serviceId (string)
  - fecha (timestamp)
  - hora (string)
  - status (string) // pending, confirmed, completed, cancelled
  - notas (string)
  - createdAt (timestamp)

messages/
  - id (string)
  - userId (string)
  - nombre (string)
  - email (string)
  - telefono (string)
  - asunto (string)
  - mensaje (string)
  - respuesta (string)
  - status (string) // new, read, answered
  - createdAt (timestamp)
  - answeredAt (timestamp)

cart/
  - userId (string)
  - productos (array)
    - productId (string)
    - cantidad (number)
    - precio (number)
  - total (number)
  - updatedAt (timestamp)
```

### Reglas de seguridad de Firestore (ejemplo)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Products collection
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Services collection
    match /services/{serviceId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Works collection
    match /works/{workId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Reservations collection
    match /reservations/{reservationId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin();
    }

    // Messages collection
    match /messages/{messageId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isAuthenticated();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
  }
}
```

## Variables de entorno

El archivo `.env` debe contener:

```env
# API Configuration (si aplica)
API_URL=https://tu-api.com

# Google Maps
GOOGLE_MAPS_API_KEY=tu_api_key_aqui

# Firebase (opcional si se usa firebase_options.dart)
# FIREBASE_API_KEY=
# FIREBASE_APP_ID=
# FIREBASE_MESSAGING_SENDER_ID=
# FIREBASE_PROJECT_ID=

# Otras configuraciones
# STRIPE_KEY=
# PAYPAL_CLIENT_ID=
```

## Solución de problemas comunes

### Error de certificados SSL en desarrollo
El proyecto incluye `MyHttpOverrides` para permitir certificados auto-firmados en desarrollo. **Remover en producción**.

```dart
// En main.dart - Solo para desarrollo
await Future.delayed(
  const Duration(milliseconds:1000),
  () => HttpOverrides.global = MyHttpOverrides()
);
```

### Error de Firebase
Verificar que los archivos de configuración estén en las rutas correctas:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### Error de dependencias
```bash
flutter clean
flutter pub get
```

### Error de build Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error de build iOS
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Problemas con permisos
Verificar en:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

Permisos necesarios:
- Internet
- Cámara
- Galería/Storage
- Ubicación (para Google Maps)
- Notificaciones

## Configuración de producción

### Android

1. Crear keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configurar `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<ruta-al-keystore>
```

3. Build:
```bash
flutter build appbundle --release
```

### iOS

1. Configurar certificados en Xcode
2. Actualizar Bundle Identifier
3. Build:
```bash
flutter build ios --release
```

## Comandos útiles

### Gestión del proyecto

```bash
# Ver dispositivos disponibles
flutter devices

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub upgrade

# Ver outdated packages
flutter pub outdated
```

### Cambiar configuración de la app

```bash
# Cambiar nombre de paquete
flutter pub run change_app_package_name:main com.tuempresa.tunombre

# Generar iconos
flutter pub run flutter_launcher_icons

# Generar splash screen
flutter pub run flutter_native_splash:create
```

### Debugging

```bash
# Run con logs verbose
flutter run -v

# Run con inspector
flutter run --observatory-port=8888

# Verificar rendimiento
flutter run --profile
```

## Contribución

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## Estándares de código

- Seguir las guías de estilo de Dart/Flutter
- Usar `flutter analyze` antes de commit
- Mantener cobertura de tests
- Documentar funciones públicas
- Usar nombres descriptivos en español para el dominio

## Licencia

Este proyecto es privado y no tiene licencia pública.

## Contacto

Proyecto desarrollado como portafolio profesional.

## Notas adicionales

- La aplicación usa `flutter_dotenv` para gestión de variables sensibles
- Se recomienda usar FVM para gestión de versiones de Flutter
- El tema de la aplicación está centralizado en `ModernAppTheme`
- Las rutas están protegidas según el rol del usuario
- Se implementa persistencia de sesión con SharedPreferences
- Los formularios usan Formz para validación reactiva
- La navegación usa go_router con guards de autenticación
- El estado global se maneja con Riverpod providers

## Roadmap

- [ ] Integración de pasarela de pagos
- [ ] Sistema de notificaciones push avanzado
- [ ] Chat en tiempo real
- [ ] Sistema de puntos/recompensas
- [ ] Modo offline
- [ ] Soporte multi-idioma
- [ ] Analytics y métricas
- [ ] Tests unitarios y de integración

## Versión

**Versión actual**: 1.0.0

**Última compilación exitosa**: Flutter 3.35.2

## Changelog

### v1.0.0
- Versión inicial del proyecto
- Implementación de autenticación
- CRUD de productos, servicios y trabajos
- Sistema de reservas
- Sistema de mensajería
- Carrito de compras
- Perfiles de usuario