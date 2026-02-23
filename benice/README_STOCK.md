# BeniceFlutter - Tienda Online de Mascotas

Migración completa de BeniceAstro a Flutter con sistema de control de stock en tiempo real.

## 🚀 Características Implementadas

### ✅ Migración Completa desde Astro
- **Variables de entorno** migradas 1:1 desde BeniceAstro
- **Arquitectura idéntica** con adaptación a patrones Flutter
- **Base de datos** compartida con Supabase
- **Misma lógica de negocio** y constantes

### 📦 Sistema de Stock Avanzado
- **Control en tiempo real** del inventario
- **Validación preventiva** al agregar productos al carrito
- **Bloqueo automático** de compras sin stock suficiente
- **Funciones SQL atómicas** para consistencia de datos
- **Logs de movimientos** de stock

### 🛒 Carrito Inteligente
- **Validación de stock** en cada operación
- **Mensajes de error** claros cuando no hay stock
- **Prevención de sobreventa** de productos
- **Sincronización automática** con inventario

## 📋 Requisitos Previos

1. **Flutter SDK** >= 3.9.2
2. **Dart SDK** >= 3.9.2
3. **Cuenta Supabase** con schema de BeniceAstro
4. **Cuenta Stripe** (test mode para desarrollo)
5. **Cuenta Resend** (opcional, para emails)

## 🛠️ Configuración

### 1. Variables de Entorno

Copia el archivo de entorno de ejemplo:
```bash
cp .env.example .env
```

Edita `.env` con tus credenciales reales:

```env
# Supabase (Requerido)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...

# Stripe (Requerido)
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Resend (Requerido)
RESEND_API_KEY=re_xxx
FROM_EMAIL=ventas@beniceflutter.com

# Cloudinary (Requerido)
CLOUDINARY_CLOUD_NAME=tu_cloud_name
CLOUDINARY_API_KEY=tu_api_key
CLOUDINARY_API_SECRET=tu_api_secret

# Google Places API (Opcional)
GOOGLE_PLACES_API_KEY=AIza...

# Configuración App
PUBLIC_SITE_URL=http://localhost:3000
FLUTTER_ENV=development
```

### 2. Configuración Base de Datos

Ejecuta las funciones SQL de stock en Supabase:
```sql
-- Ejecuta el contenido de database/stock_functions.sql
-- Esto creará las funciones para control de stock
```

### 3. Dependencias

Instala las dependencias:
```bash
flutter pub get
```

## 🏃‍♂️ Ejecutar la Aplicación

### Desarrollo
```bash
flutter run
```

### Build para Producción
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📊 Arquitectura del Sistema de Stock

### Flujo de Control de Stock

1. **Verificación inicial**: Al agregar producto al carrito
2. **Validación múltiple**: Al modificar cantidades
3. **Validación final**: Antes del checkout
4. **Reducción atómica**: Al confirmar pedido
5. **Restauración**: Al cancelar pedido

### Funciones SQL Implementadas

- `reduce_product_stock()` - Reduce stock individual
- `restore_product_stock()` - Restaura stock individual  
- `check_cart_stock_availability()` - Verifica carrito completo
- `create_order_and_reduce_stock_flutter()` - Crea pedido + reduce stock
- `cancel_order_and_restore_stock_flutter()` - Cancela pedido + restaura stock

### Servicios Flutter

- **StockService**: Lógica de negocio de stock
- **StockProvider**: Estado reactivo del stock
- **CartProvider**: Validación integrada en carrito

## 🔄 Diferencias con BeniceAstro

### Mejoras Implementadas

1. **Validación en cliente**: Prevención de errores antes de enviar al servidor
2. **Estado reactivo**: UI actualizada instantáneamente con cambios de stock
3. **Mensajes específicos**: Error detallado sobre stock disponible
4. **Bloqueo preventivo**: No permite agregar productos sin stock
5. **Logs completos**: Registro de todos los movimientos de stock

### Compatibilidad 100%

- ✅ **Misma base de datos** Supabase
- ✅ **Mismas variables de entorno**
- ✅ **Misma lógica de negocio**
- ✅ **Mismas constantes** (envío gratis, etc.)
- ✅ **Mismos endpoints** de Stripe

## 🧪 Testing del Sistema de Stock

### Casos de Prueba

1. **Producto sin stock**: No se puede agregar al carrito
2. **Stock insuficiente**: Solo permite cantidad disponible
3. **Carrito mixto**: Valida todos los productos juntos
4. **Concurrencia**: Maneja múltiples usuarios
5. **Cancelación**: Restaura stock correctamente

### Comandos de Test

```bash
# Ejecutar todos los tests
flutter test

# Tests específicos de stock
flutter test test/stock_test.dart

# Tests con cobertura
flutter test --coverage
```

## 🚨 Manejo de Errores

### Stock Insuficiente
```dart
// Mensaje automático
'No hay stock suficiente para Producto X. Stock disponible: 5'
```

### Producto Agotado
```dart
// Mensaje automático  
'Producto X está agotado'
```

### Carrito Vacío
```dart
// Mensaje automático
'El carrito está vacío'
```

## 📱 Componentes UI Afectados

- **ProductCard**: Muestra estado de stock
- **AddToCartButton**: Deshabilitado si no hay stock
- **CartPage**: Validación antes de checkout
- **CheckoutPage**: Verificación final de stock
- **ProductDetail**: Selector de cantidad con límites

## 🔧 Configuración Avanzada

### Umbrales de Stock
```dart
// En lib/core/constants/app_constants.dart
static const int lowStockThreshold = 10;    // Alerta stock bajo
static const int outOfStockThreshold = 0;   // Sin stock
```

### Máximo por Producto
```dart
static const int maxQuantityPerProduct = 10;  // Límite de compra
```

## 🚀 Deploy

### Variables de Producción
```env
FLUTTER_ENV=production
PUBLIC_SITE_URL=https://beniceflutter.com
```

### Consideraciones
- Usar claves de Stripe en modo `live`
- Configurar webhooks de producción
- Verificar límites de Supabase
- Monitorear logs de stock

## 📞 Soporte

Para problemas relacionados con el stock:
1. Revisar logs en Supabase
2. Verificar funciones SQL ejecutadas
3. Validar variables de entorno
4. Comprobar estado de productos

---

**BeniceFlutter** - Todo lo que tu mascota necesita, con control de stock perfecto. 🐾
