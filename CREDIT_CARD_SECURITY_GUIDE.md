# 🔒 Guía de Seguridad para Tarjetas de Crédito

Explicación completa sobre las consideraciones de seguridad para almacenamiento de tarjetas de crédito en aplicaciones móviles.

---

## 📋 Índice

1. [El Problema Actual](#el-problema-actual)
2. [Almacenamiento de Claves de Encriptación](#almacenamiento-de-claves)
3. [PCI DSS Compliance](#pci-dss-compliance)
4. [Soluciones Recomendadas](#soluciones-recomendadas)
5. [Implementación con Flutter Secure Storage](#implementación-flutter-secure-storage)
6. [Tokenización (Recomendado)](#tokenización)
7. [Comparación de Enfoques](#comparación)

---

## ⚠️ El Problema Actual

### Implementación Actual (SOLO PARA DESARROLLO)

```dart
// ❌ INSEGURO PARA PRODUCCIÓN
class EncryptionService {
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // La clave de encriptación se guarda en SharedPreferences
    String? keyString = prefs.getString('encryption_key');

    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = base64.encode(key.bytes);
      await prefs.setString('encryption_key', keyString);
    }
  }
}
```

### ¿Por qué es inseguro?

1. **SharedPreferences no es seguro**:
   - Es almacenamiento de texto plano
   - Cualquier app con root/jailbreak puede leerlo
   - No usa el hardware de seguridad del dispositivo
   - Fácil de extraer con herramientas de debugging

2. **Ejemplo de ataque**:
   ```bash
   # Android - Cualquiera con ADB puede leer SharedPreferences
   adb shell
   cd /data/data/com.tu.app/shared_prefs
   cat flutter.FlutterSharedPreferences.xml

   # ¡La clave de encriptación está ahí en texto plano! 😱
   <string name="encryption_key">kJ8s9dK3mN4pQ5rT6uV7wX8yZ9...</string>
   ```

3. **Consecuencia**:
   - Si un atacante obtiene la clave de encriptación
   - Puede desencriptar TODAS las tarjetas guardadas
   - Robo masivo de información sensible

---

## 🔐 Almacenamiento de Claves de Encriptación

### Solución: Usar Almacenamiento Seguro del Sistema

Cada sistema operativo tiene un almacén seguro de credenciales respaldado por hardware:

| Plataforma | Sistema Seguro | Características |
|------------|----------------|-----------------|
| **Android** | Keystore | Hardware-backed, encriptación por TEE/SE |
| **iOS** | Keychain | Hardware-backed, Secure Enclave |
| **macOS** | Keychain | Integrado con Touch ID/Face ID |
| **Windows** | Credential Manager | DPAPI (Data Protection API) |
| **Linux** | Keyring | libsecret |

### Android Keystore

```
┌─────────────────────────────────────┐
│         Tu Aplicación               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Solicita Clave            │   │
│  └─────────────┬───────────────┘   │
└────────────────┼───────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│     Android Keystore API            │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Trusted Execution Environment      │
│  (TEE) o Secure Element (SE)       │
│                                     │
│  • Hardware de seguridad            │
│  • Aislado del sistema operativo   │
│  • Imposible extraer claves         │
└─────────────────────────────────────┘
```

**Características**:
- Las claves NUNCA salen del hardware seguro
- Operaciones criptográficas dentro del TEE
- Protección contra root/malware
- Integración con biometría (huella, face ID)

### iOS Keychain

```
┌─────────────────────────────────────┐
│         Tu Aplicación               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Solicita Clave            │   │
│  └─────────────┬───────────────┘   │
└────────────────┼───────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│     Keychain Services API           │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│       Secure Enclave                │
│                                     │
│  • Coprocesador dedicado            │
│  • Separado del procesador principal│
│  • Claves nunca salen del enclave   │
│  • Touch ID / Face ID integrado     │
└─────────────────────────────────────┘
```

**Características**:
- Secure Enclave es hardware dedicado
- Protección incluso contra jailbreak
- Claves vinculadas al dispositivo
- Sincronización segura con iCloud Keychain (opcional)

---

## 📜 PCI DSS Compliance

### ¿Qué es PCI DSS?

**PCI DSS** = Payment Card Industry Data Security Standard

Es un conjunto de **requisitos de seguridad** obligatorios para cualquier organización que:
- Almacena
- Procesa
- Transmite

información de tarjetas de crédito.

### Historia y Propósito

```
2004 - Visa y Mastercard crean PCI DSS
   │
   ├─ Objetivo: Reducir fraude con tarjetas
   ├─ Proteger datos de titulares de tarjetas
   └─ Estandarizar seguridad en la industria
```

### 12 Requisitos Principales de PCI DSS

```
┌─────────────────────────────────────────────────────┐
│  Construir y Mantener Red Segura                    │
├─────────────────────────────────────────────────────┤
│  1. Firewall para proteger datos                   │
│  2. No usar contraseñas/claves por defecto         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Proteger Datos de Titulares                        │
├─────────────────────────────────────────────────────┤
│  3. Proteger datos almacenados ⚠️                   │
│  4. Encriptar transmisión de datos en redes públicas│
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Mantener Programa de Gestión de Vulnerabilidades   │
├─────────────────────────────────────────────────────┤
│  5. Proteger contra virus/malware                   │
│  6. Desarrollar sistemas y apps seguros             │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Implementar Medidas de Control de Acceso           │
├─────────────────────────────────────────────────────┤
│  7. Restringir acceso a datos por necesidad         │
│  8. Identificar y autenticar acceso                 │
│  9. Restringir acceso físico a datos                │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Monitorear y Probar Redes                          │
├─────────────────────────────────────────────────────┤
│  10. Rastrear y monitorear accesos                  │
│  11. Probar sistemas y procesos regularmente        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Mantener Política de Seguridad                     │
├─────────────────────────────────────────────────────┤
│  12. Política de seguridad de información           │
└─────────────────────────────────────────────────────┘
```

### Requisito #3: Proteger Datos Almacenados

**Datos que NUNCA debes almacenar**:
```
❌ PROHIBIDO ALMACENAR:
   ├─ Track completo de banda magnética
   ├─ CVV/CVC/CVV2/CVC2 (código de seguridad)
   └─ PIN o bloque PIN encriptado

⚠️ SI ALMACENAS, DEBES:
   ├─ PAN (Primary Account Number - número de tarjeta)
   │   └─ DEBE estar encriptado con algoritmo fuerte
   │   └─ DEBE mostrar máximo primeros 6 y últimos 4 dígitos
   │
   ├─ Nombre del titular
   │   └─ Proteger según requisitos de privacidad
   │
   └─ Fecha de expiración
       └─ Proteger según requisitos de privacidad
```

### Niveles de Certificación PCI DSS

```
┌──────────────────────────────────────────────────┐
│ Nivel 1: Más de 6 millones transacciones/año    │
│ ├─ Auditoría anual por QSA (auditor certificado)│
│ ├─ Escaneo trimestral de vulnerabilidades       │
│ └─ Costo: $50,000 - $500,000 USD/año           │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ Nivel 2: 1-6 millones transacciones/año         │
│ ├─ Autoevaluación anual (SAQ)                   │
│ ├─ Escaneo trimestral de vulnerabilidades       │
│ └─ Costo: $10,000 - $50,000 USD/año            │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ Nivel 3: 20,000-1 millón transacciones/año      │
│ ├─ Autoevaluación anual (SAQ)                   │
│ ├─ Escaneo trimestral de vulnerabilidades       │
│ └─ Costo: $5,000 - $20,000 USD/año             │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ Nivel 4: Menos de 20,000 transacciones/año      │
│ ├─ Autoevaluación anual (SAQ)                   │
│ ├─ Escaneo trimestral de vulnerabilidades       │
│ └─ Costo: $2,000 - $10,000 USD/año             │
└──────────────────────────────────────────────────┘
```

### ¿Qué pasa si NO cumples PCI DSS?

```
┌─────────────────────────────────────────┐
│  Consecuencias del Incumplimiento       │
├─────────────────────────────────────────┤
│  • Multas: $5,000 - $100,000/mes       │
│  • Suspensión de procesamiento pagos   │
│  • Demandas de clientes afectados      │
│  • Daño reputacional irreparable       │
│  • Responsabilidad por fraudes         │
│  • Cárcel en casos de negligencia      │
└─────────────────────────────────────────┘
```

**Ejemplos reales**:
- **Target (2013)**: Brecha de 40 millones de tarjetas → $18.5 millones en multas
- **Home Depot (2014)**: 56 millones de tarjetas → $19.5 millones en multas
- **Equifax (2017)**: 147 millones de personas → $700 millones en acuerdo

---

## ✅ Soluciones Recomendadas

### Opción 1: Flutter Secure Storage (Mejor para Almacenamiento Local)

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

#### Migración del Código Actual

**Antes (Inseguro)**:
```dart
// ❌ NO USAR EN PRODUCCIÓN
class EncryptionService {
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString('encryption_key');

    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = base64.encode(key.bytes);
      await prefs.setString('encryption_key', keyString);
    }

    _key = Key.fromBase64(keyString);
  }
}
```

**Después (Seguro)**:
```dart
// ✅ SEGURO PARA PRODUCCIÓN
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late final Encrypter _encrypter;
  late final IV _iv;

  // Usa almacenamiento seguro del sistema
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Usa Android Keystore
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      // Usa iOS Keychain
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'PortfolioApp',
    ),
  );

  Future<void> init() async {
    // Intenta obtener clave existente
    String? keyString = await _secureStorage.read(key: 'encryption_key');
    String? ivString = await _secureStorage.read(key: 'encryption_iv');

    if (keyString == null || ivString == null) {
      // Genera nueva clave si no existe
      final key = Key.fromSecureRandom(32); // AES-256
      final iv = IV.fromSecureRandom(16);

      // Guarda en almacenamiento seguro
      await _secureStorage.write(
        key: 'encryption_key',
        value: base64.encode(key.bytes),
      );
      await _secureStorage.write(
        key: 'encryption_iv',
        value: base64.encode(iv.bytes),
      );

      _key = key;
      _iv = iv;
    } else {
      // Recupera clave existente
      _key = Key.fromBase64(keyString);
      _iv = IV.fromBase64(ivString);
    }

    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    return _encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: _iv);
  }

  // CRÍTICO: Método para eliminar claves (logout, desinstalar app)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: 'encryption_key');
    await _secureStorage.delete(key: 'encryption_iv');
  }
}
```

#### Configuración por Plataforma

**Android - `android/app/src/main/AndroidManifest.xml`**:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Requiere Android 6.0+ (API 23) para Keystore -->
    <uses-sdk android:minSdkVersion="23" />

    <!-- Opcional: Requerir hardware de seguridad -->
    <uses-feature
        android:name="android.hardware.fingerprint"
        android:required="false" />
</manifest>
```

**iOS - `ios/Runner/Info.plist`**:
```xml
<dict>
    <!-- Requiere iOS 11.0+ para Keychain moderno -->
    <key>MinimumOSVersion</key>
    <string>11.0</string>

    <!-- Opcional: Descripción para Face ID -->
    <key>NSFaceIDUsageDescription</key>
    <string>Usamos Face ID para proteger tus tarjetas de crédito</string>
</dict>
```

#### Implementación con Biometría

```dart
import 'package:local_auth/local_auth.dart';

class SecureCardStorage {
  final _auth = LocalAuthentication();
  final _encryptionService = EncryptionService();

  Future<void> saveCard(CreditCard card) async {
    // 1. Verificar biometría antes de guardar
    final authenticated = await _authenticateWithBiometrics();
    if (!authenticated) {
      throw Exception('Autenticación requerida');
    }

    // 2. Encriptar y guardar
    final encryptedNumber = _encryptionService.encrypt(card.cardNumber);
    final encryptedCvv = _encryptionService.encrypt(card.cvv);

    // 3. Guardar en Isar
    // ...
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await _auth.authenticate(
        localizedReason: 'Autentícate para acceder a tus tarjetas',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

---

### Opción 2: Tokenización (🌟 RECOMENDADO)

**Tokenización** = Reemplazar datos reales con tokens (referencias) que solo el procesador de pagos puede descifrar.

```
┌─────────────────────────────────────────────────┐
│              TU APLICACIÓN                      │
│                                                 │
│  Usuario ingresa:                               │
│  4532 1234 5678 9012                           │
│  CVV: 123                                       │
│  Expiry: 12/25                                  │
└──────────────────┬──────────────────────────────┘
                   │ (1) Envía datos sensibles
                   │     SOLO UNA VEZ
                   ▼
┌─────────────────────────────────────────────────┐
│         PROCESADOR DE PAGOS                     │
│         (Stripe, MercadoPago, etc.)            │
│                                                 │
│  • Valida tarjeta                               │
│  • Almacena de forma segura (PCI compliant)    │
│  • Genera token: tok_1A2B3C4D5E6F              │
└──────────────────┬──────────────────────────────┘
                   │ (2) Devuelve token
                   ▼
┌─────────────────────────────────────────────────┐
│              TU APLICACIÓN                      │
│                                                 │
│  Almacena SOLO el token:                        │
│  • Token: tok_1A2B3C4D5E6F                     │
│  • Últimos 4 dígitos: 9012                     │
│  • Marca: Visa                                  │
│  • Expiry: 12/25                                │
│                                                 │
│  ❌ NO almacena número completo                │
│  ❌ NO almacena CVV                            │
└─────────────────────────────────────────────────┘

Para cobrar:
┌─────────────────────────────────────────────────┐
│  1. Usuario compra algo                         │
│  2. Tu app envía: token + monto                 │
│  3. Procesador usa token para cobrar            │
│  4. Tu app recibe: éxito/fallo                  │
└─────────────────────────────────────────────────┘
```

#### Implementación con Stripe

```yaml
# pubspec.yaml
dependencies:
  flutter_stripe: ^10.0.0
```

```dart
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentService {
  static Future<void> init() async {
    Stripe.publishableKey = 'pk_test_tu_clave_publica';
  }

  Future<PaymentMethod?> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    try {
      // 1. Crear método de pago (tokenización)
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardholderName,
            ),
          ),
        ),
      );

      // 2. paymentMethod.id es el TOKEN
      // Ejemplo: pm_1A2B3C4D5E6F
      print('Token: ${paymentMethod.id}');
      print('Últimos 4: ${paymentMethod.card.last4}');
      print('Marca: ${paymentMethod.card.brand}');

      return paymentMethod;
    } catch (e) {
      print('Error tokenizando: $e');
      return null;
    }
  }

  Future<bool> processPayment({
    required String paymentMethodId,
    required double amount,
  }) async {
    try {
      // 3. Enviar token + monto a tu backend
      final response = await http.post(
        Uri.parse('https://tuapi.com/payment'),
        body: {
          'payment_method_id': paymentMethodId,
          'amount': (amount * 100).toInt(), // centavos
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

**Backend (Node.js con Stripe)**:
```javascript
const stripe = require('stripe')('sk_test_tu_clave_secreta');

app.post('/payment', async (req, res) => {
  const { payment_method_id, amount } = req.body;

  try {
    // Stripe usa el token para cobrar
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'usd',
      payment_method: payment_method_id,
      confirm: true,
    });

    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

#### Modelo de Datos con Tokenización

```dart
// Solo almacenas metadata, NO datos sensibles
class TokenizedCard {
  final String id;
  final String token; // pm_1A2B3C4D5E6F
  final String last4; // 9012
  final String brand; // Visa, Mastercard
  final String expiryMonth; // 12
  final String expiryYear; // 2025
  final String cardholderName;
  final bool isDefault;

  // ✅ NO hay cardNumber completo
  // ✅ NO hay CVV
  // ✅ NO hay datos sensibles

  TokenizedCard({
    required this.id,
    required this.token,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.isDefault = false,
  });
}
```

---

## 📊 Comparación de Enfoques

| Aspecto | SharedPreferences | Flutter Secure Storage | Tokenización |
|---------|-------------------|------------------------|--------------|
| **Seguridad** | ❌ Muy baja | ⚠️ Media-Alta | ✅ Muy Alta |
| **PCI DSS Compliance** | ❌ No | ⚠️ Parcial* | ✅ Sí |
| **Costo** | Gratis | Gratis | Variable (comisiones) |
| **Complejidad** | Baja | Media | Alta |
| **Riesgo Legal** | 🔴 Muy Alto | 🟡 Medio | 🟢 Bajo |
| **Hardware Security** | ❌ No | ✅ Sí | ✅ Sí (servidor) |
| **Root/Jailbreak** | ❌ Vulnerable | ⚠️ Resistente | ✅ Inmune |
| **Backend Requerido** | No | No | Sí |
| **Uso Recomendado** | Desarrollo | Producción pequeña | Producción |

\* *Aún debes auditar y cumplir otros requisitos PCI DSS*

---

## 🎯 Recomendaciones Finales

### Para Desarrollo/Prototipos
```dart
// ✅ OK para desarrollo
SharedPreferences + Encriptación básica
```

### Para Producción - App Pequeña (< 1000 usuarios)
```dart
// ✅ Flutter Secure Storage + Encriptación AES-256
// ✅ Limitar almacenamiento local
// ✅ Ofrecer opción de NO guardar tarjeta
// ⚠️ Consultar abogado sobre responsabilidad legal
```

### Para Producción - App Mediana/Grande
```dart
// ✅ Tokenización con Stripe/MercadoPago
// ✅ NO almacenar datos de tarjetas localmente
// ✅ Cumplimiento PCI DSS delegado al proveedor
// ✅ Reducción drástica de riesgo legal
```

---

## 📚 Servicios de Tokenización Recomendados

### Stripe
- **Global**: Disponible en 40+ países
- **Costo**: 2.9% + $0.30 por transacción
- **PCI Certified**: Level 1
- **URL**: https://stripe.com

### MercadoPago
- **Latinoamérica**: Argentina, Brasil, Chile, Colombia, México, Perú, Uruguay
- **Costo**: 3.5% - 5% por transacción
- **PCI Certified**: Level 1
- **URL**: https://www.mercadopago.com

### PayPal
- **Global**: 200+ países
- **Costo**: 2.9% - 4.4% por transacción
- **PCI Certified**: Level 1
- **URL**: https://www.paypal.com

### Transbank (Chile)
- **Chile**: Específico para Chile
- **Costo**: Variable según negociación
- **PCI Certified**: Sí
- **URL**: https://www.transbank.cl

---

## ⚖️ Consideraciones Legales

### ¿Cuándo NECESITAS tokenización?

```
✅ TOKENIZACIÓN OBLIGATORIA SI:
   ├─ Procesas más de 20,000 transacciones/año
   ├─ Almacenas datos de tarjetas
   ├─ Tu app es comercial (no personal)
   └─ Operas en múltiples países

⚠️ TOKENIZACIÓN RECOMENDADA SI:
   ├─ Tienes más de 100 usuarios
   ├─ Manejas dinero real
   ├─ No eres experto en seguridad
   └─ No quieres riesgo legal

❌ NUNCA almacenes localmente SI:
   ├─ No tienes certificación PCI DSS
   ├─ No tienes seguro de ciberataques
   ├─ No tienes equipo de seguridad
   └─ Es una app de producción real
```

### Responsabilidad Legal

Si almacenas tarjetas y hay una brecha:
1. **Multas PCI DSS**: $5,000 - $100,000/mes
2. **Demandas de usuarios**: Daños y perjuicios
3. **Suspensión de servicios**: Stripe/bancos te bloquean
4. **Responsabilidad penal**: En casos de negligencia grave

---

## 🚀 Plan de Migración

### Paso 1: Evaluación (Semana 1)
```bash
□ Determinar volumen de transacciones
□ Evaluar presupuesto para tokenización
□ Consultar requisitos legales en tu país
□ Decidir: Secure Storage o Tokenización
```

### Paso 2: Implementación (Semanas 2-4)

**Opción A: Flutter Secure Storage**
```bash
□ Agregar flutter_secure_storage
□ Migrar EncryptionService
□ Implementar biometría (opcional)
□ Migrar datos existentes
□ Probar en producción limitada
```

**Opción B: Tokenización**
```bash
□ Crear cuenta en Stripe/MercadoPago
□ Configurar SDK
□ Implementar tokenización
□ Crear backend para procesar pagos
□ Eliminar almacenamiento local de tarjetas completas
□ Probar end-to-end
```

### Paso 3: Migración de Usuarios (Semana 5)
```dart
// Borrar tarjetas almacenadas con método inseguro
await _secureStorage.deleteAll();
await _isar.creditCardModels.clear();

// Notificar usuarios
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Actualización de Seguridad'),
    content: Text(
      'Por tu seguridad, hemos mejorado el sistema de pagos. '
      'Por favor, vuelve a agregar tus tarjetas.'
    ),
  ),
);
```

---

## 📖 Recursos Adicionales

- **PCI DSS Official**: https://www.pcisecuritystandards.org/
- **Flutter Secure Storage**: https://pub.dev/packages/flutter_secure_storage
- **Stripe Documentation**: https://stripe.com/docs
- **OWASP Mobile Security**: https://owasp.org/www-project-mobile-security/

---

**Recuerda**: La seguridad no es opcional cuando se trata de dinero de otras personas. 💳🔒
