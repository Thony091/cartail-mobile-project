# 📦 Guía de Melos y Mason

Documentación completa sobre el uso de Melos y Mason en proyectos Flutter.

---

## 📋 Índice

1. [Melos - Gestión de Monorepos](#melos)
2. [Mason - Generación de Código](#mason)
3. [Casos de Uso en Tu Proyecto](#casos-de-uso)
4. [Mejores Prácticas](#mejores-prácticas)
5. [Scripts y Comandos Útiles](#scripts-útiles)

---

## 🎯 Melos - Gestión de Monorepos

### ¿Qué es Melos?

**Melos** es una herramienta CLI para gestionar proyectos Dart/Flutter con múltiples paquetes (monorepos). Facilita la ejecución de comandos en varios paquetes simultáneamente.

### Instalación

```bash
# Activar globalmente
dart pub global activate melos

# Verificar instalación
melos --version
```

### Configuración Básica - `melos.yaml`

```yaml
name: portafolio_project
repository: https://github.com/tu-usuario/portafolio-project

packages:
  - .
  # Si tuvieras múltiples paquetes:
  # - packages/**
  # - apps/**

command:
  bootstrap:
    # Dependencias compartidas entre paquetes
    dependencies:
      - shared_dependencies

scripts:
  # ========== ANÁLISIS Y CALIDAD ==========

  analyze:
    name: "Analizar código"
    description: "Ejecuta dart analyze en todos los paquetes"
    run: melos exec -- dart analyze .

  format:
    name: "Formatear código"
    description: "Formatea el código con dart format"
    run: melos exec -- dart format .

  format:check:
    name: "Verificar formato"
    description: "Verifica que el código esté formateado"
    run: melos exec -- dart format --set-exit-if-changed .

  # ========== TESTS ==========

  test:
    name: "Ejecutar tests"
    description: "Ejecuta todos los tests del proyecto"
    run: melos exec --fail-fast -- flutter test

  test:coverage:
    name: "Test con cobertura"
    description: "Ejecuta tests y genera reporte de cobertura"
    run: |
      melos exec -- flutter test --coverage
      melos exec -- genhtml coverage/lcov.info -o coverage/html

  test:unit:
    name: "Tests unitarios"
    description: "Solo tests unitarios"
    run: melos exec -- flutter test test/unit

  test:widget:
    name: "Tests de widgets"
    description: "Solo tests de widgets"
    run: melos exec -- flutter test test/widget

  test:integration:
    name: "Tests de integración"
    description: "Solo tests de integración"
    run: melos exec -- flutter test integration_test

  # ========== BUILD ==========

  build:
    name: "Build runner"
    description: "Ejecuta build_runner para código generado"
    run: melos exec -- flutter pub run build_runner build --delete-conflicting-outputs

  build:watch:
    name: "Build runner en modo watch"
    description: "Ejecuta build_runner en modo watch"
    run: melos exec -- flutter pub run build_runner watch --delete-conflicting-outputs

  # ========== CLEAN ==========

  clean:
    name: "Limpiar proyecto"
    description: "Limpia archivos generados y dependencias"
    run: |
      melos exec -- flutter clean
      melos exec -- rm -rf .dart_tool

  clean:deep:
    name: "Limpieza profunda"
    description: "Limpieza profunda + flutter pub get"
    run: |
      melos clean
      melos exec -- flutter pub get

  # ========== GIT ==========

  version:
    name: "Actualizar versiones"
    description: "Actualiza versiones de todos los paquetes"
    run: melos version

  publish:
    name: "Publicar paquetes"
    description: "Publica paquetes a pub.dev"
    run: melos publish

  # ========== CUSTOM PARA TU PROYECTO ==========

  gen:isar:
    name: "Generar código Isar"
    description: "Genera código para modelos de Isar"
    run: flutter pub run build_runner build --delete-conflicting-outputs

  check:
    name: "Verificación completa"
    description: "Análisis + formato + tests"
    run: |
      melos run analyze
      melos run format:check
      melos run test

  setup:
    name: "Setup inicial"
    description: "Configuración inicial del proyecto"
    run: |
      melos clean
      flutter pub get
      melos run gen:isar

  fix:
    name: "Arreglar problemas automáticos"
    description: "Ejecuta dart fix --apply"
    run: melos exec -- dart fix --apply

  outdated:
    name: "Dependencias desactualizadas"
    description: "Muestra dependencias desactualizadas"
    run: melos exec -- flutter pub outdated

  upgrade:
    name: "Actualizar dependencias"
    description: "Actualiza todas las dependencias"
    run: melos exec -- flutter pub upgrade

ide:
  intellij:
    enabled: true
```

### Comandos Comunes de Melos

```bash
# ========== INICIALIZACIÓN ==========

# Bootstrap del monorepo (instala dependencias de todos los paquetes)
melos bootstrap

# Limpiar todo
melos clean

# ========== EJECUCIÓN DE SCRIPTS ==========

# Ejecutar script definido en melos.yaml
melos run <nombre-script>
melos run analyze
melos run test
melos run build

# ========== EJECUCIÓN EN PAQUETES ==========

# Ejecutar comando en todos los paquetes
melos exec -- <comando>
melos exec -- flutter pub get
melos exec -- dart analyze

# Ejecutar solo en paquetes específicos
melos exec --scope="payment" -- flutter test

# Ignorar paquetes específicos
melos exec --ignore="*example*" -- flutter test

# ========== VERSIONES ==========

# Ver versiones de paquetes
melos list

# Actualizar versiones
melos version

# Publicar paquetes
melos publish

# ========== OTROS ==========

# Ejecutar comando y fallar si algún paquete falla
melos exec --fail-fast -- flutter test

# Ver dependencias de paquetes
melos list --graph
```

---

## 🧱 Mason - Generación de Código

### ¿Qué es Mason?

**Mason** es una herramienta para generar código usando plantillas (bricks). Ideal para crear estructuras repetitivas con un solo comando.

### Instalación

```bash
# Activar globalmente
dart pub global activate mason_cli

# Verificar instalación
mason --version
```

### Configuración - `mason.yaml`

```yaml
# mason.yaml
bricks:
  # ========== BRICKS OFICIALES ==========

  # Generador de features con clean architecture
  feature_brick:
    git:
      url: https://github.com/felangel/mason.git
      path: bricks/feature_brick

  # Generador de bloc/cubit
  bloc:
    git:
      url: https://github.com/felangel/mason.git
      path: bricks/bloc

  # ========== BRICKS PERSONALIZADOS ==========

  # Brick para módulos de tu proyecto
  clean_module:
    path: bricks/clean_module

  # Brick para páginas con Riverpod
  riverpod_page:
    path: bricks/riverpod_page

  # Brick para modelos de Isar
  isar_model:
    path: bricks/isar_model

  # Brick para providers
  provider_set:
    path: bricks/provider_set
```

### Crear Bricks Personalizados

#### 1. Estructura de Brick para Clean Architecture Module

```bash
# Crear nuevo brick
mason new clean_module
```

**`bricks/clean_module/brick.yaml`**:
```yaml
name: clean_module
description: Genera un módulo completo con Clean Architecture
version: 0.1.0

vars:
  - name: name
    description: Nombre del módulo (ej. user, product)
    type: string
    prompt: ¿Nombre del módulo?

  - name: feature_path
    description: Ruta del feature
    type: string
    default: lib/features

  - name: has_local_datasource
    description: ¿Incluir datasource local?
    type: boolean
    default: true
    prompt: ¿Incluir datasource local (Isar)?

  - name: has_remote_datasource
    description: ¿Incluir datasource remoto?
    type: boolean
    default: true
    prompt: ¿Incluir datasource remoto (API)?

  - name: use_riverpod
    description: ¿Usar Riverpod?
    type: boolean
    default: true
```

**`bricks/clean_module/__brick__/`**: Estructura de archivos

```
__brick__/
├── {{feature_path}}/{{name}}/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── {{name}}.dart
│   │   ├── repositories/
│   │   │   └── {{name}}_repository.dart
│   │   └── errors/
│   │       └── {{name}}_errors.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── {{name}}_model.dart
│   │   │   └── {{name}}_mapper.dart
│   │   ├── datasources/
│   │   │   ├── {{name}}_datasource.dart
{{#has_local_datasource}}
│   │   │   ├── {{name}}_local_datasource_impl.dart
{{/has_local_datasource}}
{{#has_remote_datasource}}
│   │   │   └── {{name}}_remote_datasource_impl.dart
{{/has_remote_datasource}}
│   │   └── repositories/
│   │       └── {{name}}_repository_impl.dart
{{#use_riverpod}}
│   └── presentation/
│       ├── providers/
│       │   └── {{name}}_providers.dart
│       ├── pages/
│       │   └── {{name}}_page.dart
│       └── widgets/
│           └── {{name}}_widget.dart
{{/use_riverpod}}
```

**Ejemplo de template - `{{name}}.dart`**:
```dart
class {{name.pascalCase()}} {
  final String id;
  final String name;
  final DateTime createdAt;

  {{name.pascalCase()}}({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  {{name.pascalCase()}} copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return {{name.pascalCase()}}(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

#### 2. Brick para Página con Riverpod

**`bricks/riverpod_page/brick.yaml`**:
```yaml
name: riverpod_page
description: Genera una página con Riverpod
version: 0.1.0

vars:
  - name: page_name
    description: Nombre de la página
    type: string
    prompt: ¿Nombre de la página?

  - name: has_state
    description: ¿Tiene estado?
    type: boolean
    default: true

  - name: use_consumer_widget
    description: ¿Usar ConsumerWidget?
    type: boolean
    default: false
```

**Template - `{{page_name}}_page.dart`**:
```dart
import 'package:flutter/material.dart';
{{#use_consumer_widget}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/use_consumer_widget}}

{{#use_consumer_widget}}
class {{page_name.pascalCase()}}Page extends ConsumerWidget {
  static const name = '{{page_name.pascalCase()}}Page';

  const {{page_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
{{/use_consumer_widget}}
{{^use_consumer_widget}}
class {{page_name.pascalCase()}}Page extends StatelessWidget {
  static const name = '{{page_name.pascalCase()}}Page';

  const {{page_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
{{/use_consumer_widget}}
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{page_name.titleCase()}}'),
      ),
      body: const Center(
        child: Text('{{page_name.pascalCase()}} Page'),
      ),
    );
  }
}
```

#### 3. Brick para Modelo de Isar

**`bricks/isar_model/brick.yaml`**:
```yaml
name: isar_model
description: Genera un modelo de Isar con entidad
version: 0.1.0

vars:
  - name: model_name
    description: Nombre del modelo
    type: string
    prompt: ¿Nombre del modelo?

  - name: has_encryption
    description: ¿Tiene campos encriptados?
    type: boolean
    default: false
```

**Template - `{{model_name}}_model.dart`**:
```dart
import 'package:isar_community/isar.dart';
{{#has_encryption}}
import '../../../../config/services/storage/encryption_service.dart';
{{/has_encryption}}
import '../entities/{{model_name}}.dart';

part '{{model_name}}_model.g.dart';

@Collection()
class {{model_name.pascalCase()}}Model {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String localId;

  late String name;
  late DateTime createdAt;
{{#has_encryption}}
  late String encryptedData;
{{/has_encryption}}

  // Conversión de Entity a Model
  factory {{model_name.pascalCase()}}Model.fromEntity(
    {{model_name.pascalCase()}} entity,
{{#has_encryption}}
    EncryptionService encryption,
{{/has_encryption}}
  ) {
    return {{model_name.pascalCase()}}Model()
      ..localId = entity.id
      ..name = entity.name
      ..createdAt = entity.createdAt
{{#has_encryption}}
      ..encryptedData = encryption.encrypt(entity.sensitiveData)
{{/has_encryption}};
  }

  // Conversión de Model a Entity
  {{model_name.pascalCase()}} toEntity(
{{#has_encryption}}
    EncryptionService encryption,
{{/has_encryption}}
  ) {
    return {{model_name.pascalCase()}}(
      id: localId,
      name: name,
      createdAt: createdAt,
{{#has_encryption}}
      sensitiveData: encryption.decrypt(encryptedData),
{{/has_encryption}}
    );
  }
}
```

### Comandos de Mason

```bash
# ========== INICIALIZACIÓN ==========

# Inicializar Mason en el proyecto
mason init

# Instalar bricks definidos en mason.yaml
mason get

# ========== CREAR BRICKS ==========

# Crear nuevo brick
mason new my_brick

# Crear brick desde un bundle
mason bundle <path-to-brick> -o <output-path>

# ========== GENERAR CÓDIGO ==========

# Listar bricks disponibles
mason list

# Generar código con un brick
mason make <brick-name>
mason make clean_module
mason make riverpod_page

# Generar con variables predefinidas
mason make clean_module --name user --has_local_datasource true

# Generar en directorio específico
mason make riverpod_page -o lib/features/payment/presentation/pages

# ========== GESTIÓN DE BRICKS ==========

# Agregar brick global
mason add <brick-name>
mason add bloc

# Agregar brick desde git
mason add feature_brick --git-url https://github.com/user/repo --git-path bricks/feature

# Agregar brick local
mason add my_brick --path ./bricks/my_brick

# Eliminar brick
mason remove <brick-name>

# Actualizar bricks
mason upgrade

# ========== BÚSQUEDA ==========

# Buscar bricks en brickhub.dev
mason search <query>
mason search flutter
```

---

## 💼 Casos de Uso en Tu Proyecto

### 1. **Generar Módulos Completos con Clean Architecture**

```bash
# Crear el brick una vez
mason new clean_module

# Usarlo cada vez que necesites un nuevo módulo
mason make clean_module --name vehicle
mason make clean_module --name transaction
mason make clean_module --name notification
```

**Genera automáticamente**:
- ✅ Entidad en `domain/entities/`
- ✅ Repository interface en `domain/repositories/`
- ✅ Errores personalizados en `domain/errors/`
- ✅ Modelo en `data/models/`
- ✅ Mapper en `data/models/`
- ✅ Datasource interface y implementaciones
- ✅ Repository implementation
- ✅ Providers de Riverpod
- ✅ Página base con widgets

### 2. **Generar Modelos de Isar**

```bash
# Crear brick para modelos Isar
mason make isar_model --name payment --has_encryption true

# Genera automáticamente:
# - Modelo con anotaciones @Collection
# - Métodos toEntity y fromEntity
# - Encriptación si se especifica
```

### 3. **Crear Páginas Consistentes**

```bash
# Página con ConsumerWidget
mason make riverpod_page --page_name settings --use_consumer_widget true

# Página stateless
mason make riverpod_page --page_name about --use_consumer_widget false
```

### 4. **Generar Providers**

```bash
mason make provider_set --name auth
# Genera:
# - authServiceProvider
# - authStateProvider
# - authActionsProvider
```

### 5. **Workflow Completo con Melos + Mason**

```bash
# 1. Generar nuevo módulo
mason make clean_module --name reservation

# 2. Generar código de Isar
melos run gen:isar

# 3. Verificar código
melos run check

# 4. Ejecutar tests
melos run test
```

---

## ✨ Mejores Prácticas

### Para Melos

1. **Organiza Scripts por Categoría**
   ```yaml
   scripts:
     # Desarrollo
     dev:setup:
     dev:run:

     # Testing
     test:unit:
     test:widget:
     test:integration:

     # Build
     build:android:
     build:ios:
     build:web:
   ```

2. **Usa `fail-fast` para CI/CD**
   ```yaml
   ci:
     run: |
       melos run analyze --fail-fast
       melos run test --fail-fast
   ```

3. **Configura Scripts de Pre-commit**
   ```yaml
   pre-commit:
     run: |
       melos run format
       melos run analyze
   ```

4. **Automatiza Tareas Repetitivas**
   ```yaml
   gen:all:
     description: "Regenera todo el código"
     run: |
       melos run gen:isar
       melos run gen:routes
       melos run gen:localization
   ```

### Para Mason

1. **Convenciones de Nombres**
   - Usa `snake_case` para nombres de bricks
   - Usa `{{name.pascalCase()}}` para clases
   - Usa `{{name.camelCase()}}` para variables
   - Usa `{{name.snakeCase()}}` para archivos

2. **Variables Útiles**
   ```yaml
   vars:
     - name: name
       type: string
     - name: description
       type: string
     - name: author
       type: string
       default: "{{pub_author}}"
     - name: with_tests
       type: boolean
       default: true
   ```

3. **Helpers de Mustache**
   ```mustache
   {{#uppercase}}{{name}}{{/uppercase}}          → USER
   {{#lowercase}}{{name}}{{/lowercase}}          → user
   {{#pascalCase}}{{name}}{{/pascalCase}}        → User
   {{#camelCase}}{{name}}{{/camelCase}}          → user
   {{#snakeCase}}{{name}}{{/snakeCase}}          → user
   {{#constantCase}}{{name}}{{/constantCase}}    → USER
   {{#titleCase}}{{name}}{{/titleCase}}          → User
   ```

4. **Condiciones**
   ```mustache
   {{#has_remote_datasource}}
   // Código para datasource remoto
   {{/has_remote_datasource}}

   {{^has_remote_datasource}}
   // Código cuando NO hay datasource remoto
   {{/has_remote_datasource}}
   ```

5. **Iteraciones**
   ```mustache
   {{#fields}}
   final {{type}} {{name}};
   {{/fields}}
   ```

---

## 🚀 Scripts Útiles para Tu Proyecto

### `melos.yaml` Completo Recomendado

```yaml
name: portafolio_project
repository: https://github.com/tu-usuario/portafolio-project

packages:
  - .

scripts:
  # ========== SETUP ==========

  setup:
    description: "Setup inicial completo"
    run: |
      flutter pub get
      melos run gen:isar
      melos run format

  # ========== DESARROLLO ==========

  dev:
    description: "Modo desarrollo"
    run: flutter run --dart-define-from-file=.env

  dev:watch:
    description: "Desarrollo con hot reload + build runner watch"
    run: |
      melos run build:watch &
      flutter run --dart-define-from-file=.env

  # ========== GENERACIÓN DE CÓDIGO ==========

  gen:isar:
    description: "Generar código Isar"
    run: flutter pub run build_runner build --delete-conflicting-outputs

  gen:isar:watch:
    description: "Generar código Isar en modo watch"
    run: flutter pub run build_runner watch --delete-conflicting-outputs

  # ========== CALIDAD DE CÓDIGO ==========

  analyze:
    description: "Analizar código"
    run: flutter analyze

  format:
    description: "Formatear código"
    run: dart format lib test -l 120

  format:check:
    description: "Verificar formato"
    run: dart format lib test -l 120 --set-exit-if-changed

  fix:
    description: "Aplicar correcciones automáticas"
    run: dart fix --apply

  # ========== TESTING ==========

  test:
    description: "Ejecutar todos los tests"
    run: flutter test

  test:coverage:
    description: "Tests con cobertura"
    run: |
      flutter test --coverage
      lcov --remove coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.freezed.dart' -o coverage/lcov.info
      genhtml coverage/lcov.info -o coverage/html

  test:watch:
    description: "Tests en modo watch"
    run: flutter test --watch

  # ========== BUILD ==========

  build:android:
    description: "Build APK"
    run: flutter build apk --release

  build:android:bundle:
    description: "Build App Bundle"
    run: flutter build appbundle --release

  build:ios:
    description: "Build iOS"
    run: flutter build ios --release

  build:web:
    description: "Build Web"
    run: flutter build web --release

  # ========== LIMPIEZA ==========

  clean:
    description: "Limpiar proyecto"
    run: |
      flutter clean
      rm -rf .dart_tool
      rm -rf build

  clean:deep:
    description: "Limpieza profunda"
    run: |
      melos run clean
      flutter pub get
      melos run gen:isar

  # ========== CI/CD ==========

  ci:
    description: "Pipeline de CI"
    run: |
      melos run format:check
      melos run analyze
      melos run test:coverage

  # ========== DEPENDENCIAS ==========

  deps:check:
    description: "Verificar dependencias desactualizadas"
    run: flutter pub outdated

  deps:upgrade:
    description: "Actualizar dependencias"
    run: flutter pub upgrade

  # ========== CUSTOM ==========

  icons:
    description: "Generar iconos de la app"
    run: flutter pub run flutter_launcher_icons

  splash:
    description: "Generar splash screen"
    run: flutter pub run flutter_native_splash:create
```

---

## 📝 Ejemplo de Uso Diario

### Flujo de Trabajo Normal

```bash
# 1. Setup inicial (solo una vez)
melos setup

# 2. Crear nuevo módulo
mason make clean_module --name notification

# 3. Generar código Isar en modo watch
melos run gen:isar:watch

# 4. Desarrollar...
melos run dev

# 5. Antes de commit
melos run ci

# 6. Build para producción
melos run build:android:bundle
```

### Crear Nuevo Feature

```bash
# 1. Generar estructura con Mason
mason make clean_module \
  --name order \
  --has_local_datasource true \
  --has_remote_datasource true \
  --use_riverpod true

# 2. Generar modelos de Isar
mason make isar_model \
  --model_name order \
  --has_encryption false

# 3. Generar código
melos run gen:isar

# 4. Verificar
melos run analyze
melos run test
```

---

## 🎓 Recursos Adicionales

### Documentación Oficial
- **Melos**: https://melos.invertase.dev/
- **Mason**: https://github.com/felangel/mason
- **BrickHub**: https://brickhub.dev/

### Bricks Útiles de la Comunidad
- `bloc`: Generador de BLoC/Cubit
- `feature_brick`: Feature completo con clean architecture
- `flutter_template`: Template completo de app Flutter
- `riverpod_simple_architecture`: Arquitectura con Riverpod

### Tips Finales

1. **Versión de Melos/Mason en `pubspec.yaml`** (opcional):
   ```yaml
   dev_dependencies:
     melos: ^3.0.0
   ```

2. **Ignorar archivos generados en `.gitignore`**:
   ```gitignore
   # Melos
   .melos_tool/

   # Mason
   .mason/
   ```

3. **Pre-commit hooks con Melos**:
   ```bash
   # .git/hooks/pre-commit
   #!/bin/sh
   melos run format
   melos run analyze
   ```

4. **CI/CD con Melos**:
   ```yaml
   # .github/workflows/ci.yml
   - name: Run Melos CI
     run: |
       dart pub global activate melos
       melos bootstrap
       melos run ci
   ```

---

**¡Listo!** Con Melos y Mason puedes automatizar y acelerar significativamente tu desarrollo en Flutter. 🚀
