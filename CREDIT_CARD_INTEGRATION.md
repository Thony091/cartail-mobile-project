# 🔐 Sistema de Tarjetas de Crédito con Encriptación e Isar

Sistema completo de gestión de tarjetas de crédito con almacenamiento local seguro usando Isar y encriptación AES-256.

## ✅ Lo que se ha implementado

### 1. **Servicios de Seguridad**
- **[EncryptionService](lib/config/services/storage/encryption_service.dart)**: Encriptación AES-256 para datos sensibles
- **[IsarService](lib/config/services/storage/isar_service.dart)**: Gestión singleton de la base de datos Isar

### 2. **Capa de Dominio**
- **[CreditCard Entity](lib/features/payment/domain/entities/credit_card.dart)**: Entidad con detección automática de tipo de tarjeta
- **[CreditCardRepository](lib/features/payment/domain/repositories/credit_card_repository.dart)**: Interfaz del repositorio

### 3. **Capa de Datos**
- **[CreditCardModel](lib/features/payment/data/models/credit_card_model.dart)**: Modelo de Isar con anotaciones y código generado
- **[CreditCardLocalDatasource](lib/features/payment/data/datasources/credit_card_local_datasource_impl.dart)**: Implementación con Isar
- **[CreditCardRepositoryImpl](lib/features/payment/data/repositories/credit_card_repository_impl.dart)**: Implementación del repositorio

### 4. **Capa de Presentación**
- **[Providers](lib/features/payment/presentation/providers/credit_card_providers.dart)**: Providers de Riverpod para estado y acciones
- **[AddCreditCardPage](lib/features/payment/presentation/pages/add_credit_card_page.dart)**: Formulario moderno con previsualización de tarjeta

---

## 🚀 Pasos de Integración

### Paso 1: Inicializar servicios en `main.dart`

Agrega la inicialización de servicios **ANTES** de `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Enviroment.initEnvironment();

  await Future.delayed(
    const Duration(milliseconds:1000),
    () => HttpOverrides.global = MyHttpOverrides()
  );

  /// Initialize Firebase
  await FirebaseService.init();

  // ========== NUEVO: Inicializar servicios de encriptación e Isar ==========
  final encryptionService = EncryptionService();
  await encryptionService.init();

  final isarService = IsarService();
  await isarService.init();
  // ========================================================================

  runApp(
    const ProviderScope(child: MainApp())
  );
}
```

### Paso 2: Agregar imports necesarios en `main.dart`

```dart
import 'config/services/storage/encryption_service.dart';
import 'config/services/storage/isar_service.dart';
```

### Paso 3: Actualizar la página de métodos de pago

Modifica [lib/features/payment/presentation/pages/modern_payment_methods_page.dart](lib/features/payment/presentation/pages/modern_payment_methods_page.dart):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/credit_card_providers.dart';
import 'add_credit_card_page.dart';

class ModernPaymentMethodsPage extends ConsumerStatefulWidget {
  // ... código existente
}

class ModernPaymentMethodsPageState extends ConsumerState<ModernPaymentMethodsPage> {
  @override
  Widget build(BuildContext context) {
    // Reemplazar datos simulados con datos reales
    final cardsAsyncValue = ref.watch(creditCardsProvider);

    return ModernScaffoldWithDrawer(
      title: 'Métodos de Pago',
      body: Container(
        decoration: BoxDecoration(/* ... */),
        child: cardsAsyncValue.when(
          data: (cards) => cards.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: _buildCreditCardItem(card, index),
                          );
                        },
                      ),
                    ),
                    _buildAddButton(),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardItem(CreditCard card, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(card.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _showDeleteConfirmation(card),
        background: Container(/* ... */),
        child: ModernCard(
          child: Row(
            children: [
              Container(/* Icono de tarjeta */),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          card.cardType.displayName,
                          style: const TextStyle(/* ... */),
                        ),
                        const SizedBox(width: 8),
                        if (card.isDefault)
                          Container(/* Badge Principal */),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(card.maskedNumber),
                    Text('Vence: ${card.formattedExpiry}'),
                  ],
                ),
              ),
              PopupMenuButton(/* ... */),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    // Navegar al formulario de agregar tarjeta
    context.push('/payment/add-card');
  }

  Future<void> _deletePaymentMethod(CreditCard card) async {
    final confirmed = await _showDeleteConfirmation(card);
    if (confirmed == true && mounted) {
      final actions = ref.read(creditCardActionsProvider);
      await actions.deleteCard(card.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta eliminada'),
            backgroundColor: Color(0xFFe74c3c),
          ),
        );
      }
    }
  }

  Future<void> _setAsDefault(CreditCard card) async {
    final actions = ref.read(creditCardActionsProvider);
    await actions.setDefaultCard(card.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card.cardType.displayName} establecida como principal'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }
}
```

### Paso 4: Agregar ruta en el router

En tu configuración de GoRouter, agrega la ruta para agregar tarjetas:

```dart
GoRoute(
  path: '/payment/add-card',
  name: AddCreditCardPage.name,
  builder: (context, state) => const AddCreditCardPage(),
),
```

---

## 🔒 Seguridad Implementada

### Encriptación de Datos Sensibles
- **Algoritmo**: AES-256 en modo CBC
- **Datos encriptados**:
  - Número completo de la tarjeta
  - Código CVV/CVC
- **Almacenamiento de claves**: SharedPreferences (temporal - considerar KeyStore en producción)

### Características de Seguridad
✅ Número de tarjeta nunca se almacena en texto plano
✅ CVV encriptado con clave única por dispositivo
✅ Detección automática de tipo de tarjeta
✅ Validación de formato y fecha de expiración
✅ Base de datos local con Isar (muy rápida)

---

## 📱 Características del Formulario

### Previsualización de Tarjeta en Tiempo Real
- Actualización dinámica mientras el usuario escribe
- Detección automática de marca (Visa, Mastercard, Amex)
- Animaciones suaves con `animate_do`

### Validaciones
- ✅ Formato de número de tarjeta (13-19 dígitos)
- ✅ Formato de fecha MM/AA
- ✅ CVV de 3-4 dígitos
- ✅ Nombre del titular obligatorio

### Formateo Automático
- Número de tarjeta: `1234 5678 9012 3456`
- Fecha: `MM/AA`
- CVV: Oculto con `obscureText`

---

##  Uso en el Código

### Obtener todas las tarjetas
```dart
final cardsAsyncValue = ref.watch(creditCardsProvider);
```

### Obtener tarjeta predeterminada
```dart
final defaultCardAsyncValue = ref.watch(defaultCreditCardProvider);
```

### Guardar una nueva tarjeta
```dart
final actions = ref.read(creditCardActionsProvider);
await actions.saveCard(
  cardholderName: 'Juan Pérez',
  cardNumber: '4532123456789012',
  expiryMonth: '12',
  expiryYear: '2025',
  cvv: '123',
  setAsDefault: true,
);
```

### Eliminar una tarjeta
```dart
final actions = ref.read(creditCardActionsProvider);
await actions.deleteCard(cardId);
```

### Establecer como predeterminada
```dart
final actions = ref.read(creditCardActionsProvider);
await actions.setDefaultCard(cardId);
```

---

## 🔧 Comandos Útiles

### Regenerar código de Isar (si modificas el modelo)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Ver base de datos con Isar Inspector
```bash
# La base de datos está en: Application Documents Directory/portafolio_db.isar
# El inspector está habilitado en modo debug
```

---

## 📦 Dependencias Agregadas

```yaml
dependencies:
  isar_community: ^3.3.0
  isar_community_flutter_libs: ^3.3.0
  encrypt: ^5.0.3
  path_provider: ^2.1.5
  uuid: ^4.5.2

dev_dependencies:
  build_runner: ^2.7.1
  isar_community_generator: ^3.3.0
```

---

## ⚠️ Consideraciones de Producción

1. **Almacenamiento de Claves**:
   - Actualmente usa SharedPreferences
   - Para producción, migrar a:
     - Android: Android Keystore
     - iOS: Keychain

2. **PCI DSS Compliance**:
   - NO almacenar tarjetas completas en producción sin certificación PCI DSS
   - Considerar usar tokenización con servicios como Stripe, MercadoPago, etc.

3. **Testing**:
   - Datos de tarjeta se almacenan localmente
   - Ideal para desarrollo y testing
   - Para producción real, integrar con procesador de pagos certificado

---

## 📚 Referencias

- [Isar Community Docs](https://isar-community.dev/v3/)
- [Flutter Encrypt Package](https://pub.dev/packages/encrypt)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Autor**: Sistema de Arquitectura Limpia con Isar
**Fecha**: 2026-01-11
**Versión**: 1.0.0
