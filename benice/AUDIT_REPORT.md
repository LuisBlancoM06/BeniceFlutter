# 🔍 AUDITORÍA COMPLETA — BeniceFlutter (68 archivos Dart)

**Fecha:** Junio 2025  
**Proyecto:** BeniceFlutter — App e-commerce de mascotas  
**Arquitectura:** Clean Architecture + Riverpod + Supabase + GoRouter  
**Total archivos analizados:** 68 archivos Dart  

---

## 📊 RESUMEN EJECUTIVO

| Categoría | Total |
|-----------|-------|
| 🔴 ERRORES CRÍTICOS | 7 |
| 🟠 WARNINGS | 14 |
| 🟡 MEJORAS RECOMENDADAS | 22 |

---

## 🔴 ERRORES CRÍTICOS (requieren corrección inmediata)

### E-01: Claves secretas hardcodeadas en el código fuente
**Archivo:** `lib/core/constants/app_constants.dart` (líneas 9-14)  
**Severidad:** 🔴 CRÍTICA — Seguridad  

```dart
static const String supabaseUrl = 'https://ayyknhzftdlytpapdugj.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJI...';
static const String stripePublishableKey = 'pk_test_51SXzcb...';
```

**Problema:** La `supabaseAnonKey` y `stripePublishableKey` están hardcodeadas en el código fuente y se compilarán en el binario de la app. Aunque la anon key es "pública", tenerla en el código facilita ataques. El código fuente puede subirse a un repositorio público.  
**Solución:** Usar `--dart-define` para inyectar en build time, o `flutter_dotenv`, o variables de entorno nativas por plataforma.

---

### E-02: BUG — Mock AuthRepository genera un UUID nuevo en cada llamada a getCurrentUser
**Archivo:** `lib/data/repositories/repositories_impl.dart` (método `getCurrentUser`)  
**Severidad:** 🔴 CRÍTICA — Funcionalidad rota en modo mock  

```dart
// Dentro de AuthRepositoryImpl.getCurrentUser():
Right(UserEntity(id: const Uuid().v4(), ...))
```

**Problema:** Cada vez que se llama `getCurrentUser()`, se crea un ID de usuario nuevo. Esto rompe toda la lógica que depende de un usuario consistente (pedidos, favoritos, carrito). En modo mock, el usuario efectivamente "cambia" cada vez que se accede a sus datos.  
**Solución:** Generar el UUID una sola vez y almacenarlo como campo de la clase o en SharedPreferences.

---

### E-03: BUG — Profile screen re-loguea con contraseña vacía para "refrescar" datos
**Archivo:** `lib/presentation/screens/profile/profile_screen.dart` (~línea 350)  
**Severidad:** 🔴 CRÍTICA — Funcionalidad rota  

```dart
// Después de editar el perfil:
await authNotifier.login(email, password: '');
```

**Problema:** Tras editar el perfil directamente con el repositorio, se intenta recargar el estado del usuario usando `login()` con contraseña vacía. Esto siempre fallará en Supabase Auth.  
**Solución:** Crear un método `refreshUser()` en `AuthNotifier` que invoque `getCurrentUser()` del repositorio sin requerir password.

---

### E-04: ReviewsActions usa userId hardcodeado en vez del usuario real
**Archivo:** `lib/presentation/providers/review_provider.dart` (~línea 120)  
**Severidad:** 🔴 CRÍTICA — Datos incorrectos  

```dart
userId: 'current-user',  // Hardcodeado
userName: 'Usuario',     // Hardcodeado
```

**Problema:** Al crear una reseña, se envía un `userId` y `userName` falsos. Las reseñas no se asocian al usuario real.  
**Solución:** Obtener el usuario actual desde `authProvider` y pasar sus datos reales.

---

### E-05: ContactScreen silencia errores si la tabla no existe
**Archivo:** `lib/presentation/screens/info/contact_screen.dart` (líneas 197-204)  
**Severidad:** 🔴 ERROR — Pérdida silenciosa de datos  

```dart
try {
  await Supabase.instance.client.from('contact_messages').insert({...});
} catch (_) {
  // Si la tabla no existe aún, simplemente continuamos
}
```

**Problema:** Si la tabla `contact_messages` no existe o hay cualquier error, el formulario de contacto muestra "¡Mensaje enviado!" al usuario aunque el mensaje se haya perdido. **Tabla `contact_messages` no está documentada en supabase.sql.**  
**Solución:** Propagar el error al usuario. Verificar que la tabla existe en la base de datos.

---

### E-06: ContactScreen accede directamente a Supabase desde la capa de presentación
**Archivo:** `lib/presentation/screens/info/contact_screen.dart` (línea 198)  
**Severidad:** 🔴 ERROR — Violación de arquitectura  

```dart
await Supabase.instance.client.from('contact_messages').insert({...});
```

**Problema:** La pantalla accede directamente al cliente de Supabase, saltándose las capas de datasource/repository/domain. Esto rompe la Clean Architecture del proyecto.  
**Solución:** Crear un `ContactRepository` con su implementación Supabase correspondiente.

---

### E-07: `errorBuilder: (_, _, _)` — patrón con wildcard params duplicados
**Archivos afectados:**
- `lib/presentation/screens/blog/blog_screen.dart` (líneas 202, 351)
- `lib/presentation/screens/blog/blog_detail_screen.dart` (líneas 31, 355)
- `lib/presentation/screens/admin/admin_products_screen.dart` (línea 204)
- `lib/presentation/screens/admin/admin_ofertas_screen.dart` (línea 296)  
**Severidad:** 🔴 ERROR — Error de compilación en Dart <3.6  

```dart
errorBuilder: (_, _, _) => Container(...)
```

**Problema:** En versiones de Dart anteriores a 3.6, usar múltiples wildcards `_` como parámetros formales generará un error de compilación porque `_` se trata como un identificador duplicado. Solo en Dart 3.6+ (Flutter 3.29+) los wildcards `_` son non-binding.  
**Solución:** Usar nombres distintos como `(_, __, ___)` para compatibilidad, o asegurar que el proyecto requiere Dart ≥3.6.

---

## 🟠 WARNINGS (deben corregirse pronto)

### W-01: N+1 Query — favoriteProductsProvider carga productos uno por uno
**Archivo:** `lib/presentation/providers/favorites_provider.dart` (líneas 70-85)  
**Severidad:** 🟠 WARNING — Rendimiento  

```dart
final products = <ProductEntity>[];
for (final id in ids) {
  final result = await ref.read(productRepositoryProvider).getProductById(id);
  result.fold((_) {}, (product) => products.add(product));
}
```

**Problema:** Si el usuario tiene 10 favoritos, se hacen 10 consultas secuenciales a la base de datos. Con 50 favoritos, serán 50 queries.  
**Solución:** Crear un método `getProductsByIds(List<String> ids)` en el repositorio que haga una sola consulta con `.in_('id', ids)`.

---

### W-02: N+1 Query — SupabaseOrderRepositoryImpl.getOrderById
**Archivo:** `lib/data/repositories/supabase_repositories_impl.dart` (método `getOrderById`)  
**Severidad:** 🟠 WARNING — Rendimiento  

**Problema:** Para obtener un pedido por ID, primero carga TODOS los pedidos del usuario y luego filtra en memoria.  
**Solución:** Usar `.eq('id', orderId)` para consultar directamente por ID.

---

### W-03: Import no utilizado
**Archivo:** `lib/presentation/screens/admin/admin_product_form_screen.dart` (línea 4)  
**Severidad:** 🟠 WARNING — Compilador  

```dart
import '../../../core/theme/app_theme.dart'; // Unused
```

**Problema:** Import detectado por el analizador de Dart como no utilizado.  
**Solución:** Eliminar el import.

---

### W-04: Timer del countdown de Ofertas no persiste entre visitas
**Archivo:** `lib/presentation/screens/ofertas/ofertas_screen.dart`  
**Severidad:** 🟠 WARNING — UX engañoso  

**Problema:** El countdown de "Ofertas Flash" inicia siempre en 23:59:59 y se reinicia cada vez que el usuario navega a la pantalla. Esto es engañoso para el usuario.  
**Solución:** Persistir la hora de fin en SharedPreferences o recibir el timestamp de fin del servidor (tabla `site_settings`).

---

### W-05: Mock data sources no implementan Reviews ni Admin
**Archivo:** `lib/presentation/providers/repository_providers.dart` (líneas 60-75)  
**Severidad:** 🟠 WARNING — Dev workflow roto  

```dart
// Reviews siempre usa Supabase aunque useMockData=true
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return SupabaseReviewRepositoryImpl(ref.read(supabaseDataSourceProvider));
});
```

**Problema:** Cuando `useMockData = true`, los repositorios de Reviews y Admin aún intentan conectar a Supabase, lo que puede fallar si no hay conectividad.  
**Solución:** Crear `MockReviewRepositoryImpl` y `MockAdminRepositoryImpl`.

---

### W-06: AdminInvoicesNotifier definido dentro del archivo de pantalla
**Archivo:** `lib/presentation/screens/admin/admin_invoices_screen.dart` (líneas 10-55)  
**Severidad:** 🟠 WARNING — Arquitectura  

**Problema:** El `AdminInvoicesNotifier` y su `adminInvoicesProvider` están definidos en el archivo de la pantalla en lugar de en `providers/`. Esto rompe la separación de responsabilidades.  
**Solución:** Mover `AdminInvoicesNotifier` y `AdminInvoicesState` a `presentation/providers/admin_provider.dart`.

---

### W-07: uploadProductImage cast inseguro
**Archivo:** `lib/data/datasources/supabase_data_source.dart` (~línea 415)  
**Severidad:** 🟠 WARNING — Potencial crash  

```dart
fileBytes as dynamic
```

**Problema:** Cast a `dynamic` para evitar un error de tipos. Esto anula la seguridad de tipos de Dart y puede causar errores en runtime.  
**Solución:** Usar el tipo correcto según la API de Supabase Storage (`Uint8List`).

---

### W-08: Inconsistencia en feedback de errores (ScaffoldMessenger vs CustomSnackBar)
**Archivos:**
- `lib/presentation/screens/auth/login_screen.dart` → usa `CustomSnackBar`
- `lib/presentation/screens/auth/register_screen.dart` → usa `ScaffoldMessenger` directo
- `lib/presentation/screens/admin/*.dart` → usa `ScaffoldMessenger` directo  
**Severidad:** 🟠 WARNING — Consistencia UX  

**Problema:** Diferentes pantallas usan diferentes métodos para mostrar mensajes. `CustomSnackBar` ya existe como widget reutilizable pero no se usa consistentemente.  
**Solución:** Estandarizar usando `CustomSnackBar.show()`, `CustomSnackBar.showError()`, `CustomSnackBar.showSuccess()` en toda la app.

---

### W-09: Blog con datos estáticos hardcodeados
**Archivos:**
- `lib/presentation/screens/blog/blog_screen.dart`
- `lib/presentation/screens/blog/blog_detail_screen.dart`  
**Severidad:** 🟠 WARNING — Mantenibilidad  

**Problema:** El blog tiene 6 artículos hardcodeados con URLs de Unsplash, textos, autores y fechas estáticas. No están conectados a ningún backend.  
**Solución:** Crear una tabla `blog_posts` en Supabase y un `BlogRepository`, o al mínimo mover los datos a un archivo de constantes dedicado.

---

### W-10: AdminVisitsScreen muestra datos placeholder
**Archivo:** `lib/presentation/screens/admin/admin_visits_screen.dart`  
**Severidad:** 🟠 WARNING — Feature incompleta  

**Problema:** Toda la pantalla muestra valores `'--'` como placeholder. Los KPIs de visitas, páginas populares y fuentes de tráfico son datos ficticios sin conexión a ningún servicio de analítica.  
**Solución:** Conectar con una tabla `page_views` en Supabase o integrar un servicio de analítica como Firebase Analytics.

---

### W-11: _LegalSection duplicada en 3 archivos
**Archivos:**
- `lib/presentation/screens/legal/cookies_screen.dart`
- `lib/presentation/screens/legal/privacidad_screen.dart`
- `lib/presentation/screens/legal/terminos_screen.dart`  
**Severidad:** 🟠 WARNING — Código duplicado (DRY)  

**Problema:** La clase `_LegalSection` está redefinida idénticamente en cada archivo de pantalla legal.  
**Solución:** Extraer `LegalSection` a un widget compartido en `widgets/common/`.

---

### W-12: ProductCard.onTap nunca se invoca desde producto grid
**Archivo:** `lib/presentation/widgets/product/product_card.dart`  
**Severidad:** 🟠 WARNING — UX roto  

**Problema:** `ProductCard` tiene un `onTap` callback pero `GestureDetector` envuelve toda la card. Si `onTap` es null (como cuando se usa ProductCard sin callback), el tap no navega a ningún lado. En `home_screen.dart` y `products_screen.dart`, la navegación al detalle se maneja correctamente pasando `onTap`, pero conviene verificar que todos los usos de `ProductCard` pasan el callback.  
**Solución:** Verificar todos los call sites de ProductCard y asegurar que pasan `onTap: () => context.push('/product/${product.slug}')`.

---

### W-13: AdminOrdersScreen tiene const en contexto no-const
**Archivo:** `lib/presentation/screens/admin/admin_orders_screen.dart` (~línea 142)  
**Severidad:** 🟠 WARNING — Potencial error  

```dart
decoration: BoxDecoration(
  color: const Color(0xFFE0E7FF), // const OK
  shape: BoxShape.circle,        
),  // El Container exterior no es const pero BoxDecoration sí
```

**Nota:** Este es un patrón menor, los widgets son correctos pero conviene revisar si hay inconsistencias en el uso de `const`.

---

### W-14: `sharedPreferencesProvider` no tipado
**Archivo:** `lib/main.dart` (se usa `overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]`)  
**Severidad:** 🟠 WARNING — No se ve la declaración del provider  

**Problema:** `sharedPreferencesProvider` se usa en varios archivos pero su declaración no fue encontrada entre los archivos leídos. Podría estar en un archivo no auditado o generarse. Si no existe, causará un error de compilación.  
**Solución:** Verificar que existe una declaración como `final sharedPreferencesProvider = Provider<SharedPreferences>(...)` en los providers.

---

## 🟡 MEJORAS RECOMENDADAS

### M-01: Cart persistence — usar carrito del servidor para usuarios autenticados
**Archivos:** `lib/data/repositories/repositories_impl.dart`, `lib/presentation/providers/cart_provider.dart`  
**Impacto:** Medio — El carrito actual se persiste solo en SharedPreferences local. Si el usuario cambia de dispositivo, pierde el carrito.  
**Sugerencia:** Para usuarios autenticados, sincronizar carrito con una tabla `carts` en Supabase.

---

### M-02: Implementar TextScaler.noScaling como preferencia configurable
**Archivo:** `lib/main.dart` (línea ~55)  
```dart
textScaler: TextScaler.noScaling,
```
**Impacto:** Accesibilidad — Esto deniega a los usuarios la posibilidad de ajustar el tamaño del texto según sus preferencias del sistema. Viola las pautas de accesibilidad WCAG.  
**Sugerencia:** Permitir escalado de texto o al menos limitar con `MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.4)`.

---

### M-03: Strings hardcodeados — Internacionalización ausente
**Impacto:** Alto si se planea expansión internacional  
**Archivos afectados:** Prácticamente todos los archivos de UI  

Ejemplos:
- `'No tienes favoritos'` — favorites_screen.dart
- `'Explorar Tienda'` — múltiples archivos
- `'¡Mensaje enviado! Te responderemos pronto.'` — contact_screen.dart
- `'Pedido'`, `'Cancelar'`, `'Enviar Mensaje'` — múltiples  

**Sugerencia:** Implementar `flutter_localizations` + `intl` para generar archivos `.arb` con todas las cadenas traducibles. Actualmente hay ~200+ cadenas hardcodeadas en español.

---

### M-04: Usar `CachedNetworkImage` de forma consistente
**Archivos:** `blog_screen.dart`, `blog_detail_screen.dart` usan `Image.network()` directamente, mientras el resto del app usa `CachedNetworkImage`.  
**Sugerencia:** Reemplazar todos los `Image.network()` por `CachedNetworkImage` para consistencia y rendimiento (caching).

---

### M-05: Agregar tests unitarios y de widgets
**Archivo:** `test/widget_test.dart` — solo contiene el test boilerplate por defecto.  
**Sugerencia:** Agregar tests para:
- Modelos — serialización/deserialización JSON
- Repositorios — mock data source + verificación de Either
- Providers — estados de carga, error, datos
- Widgets críticos — ProductCard, CartItemCard, OrderCard

---

### M-06: Implementar refresh token / session check
**Archivos:** `lib/presentation/providers/auth_provider.dart`  
**Problema:** No hay manejo explícito de expiración de tokens de Supabase. Si el token expira durante una sesión larga, las llamadas API fallarán silenciosamente.  
**Sugerencia:** Agregar `Supabase.instance.client.auth.onAuthStateChange.listen()` para detectar cambios de sesión.

---

### M-07: AdminDashboardScreen — KPI grid con aspect ratio fijo
**Archivo:** `lib/presentation/screens/admin/admin_dashboard_screen.dart`  
**Problema:** `childAspectRatio: 1.4` puede causar overflow en contenedores pequeños.  
**Sugerencia:** Usar `Wrap` con widgets de tamaño adaptable o `LayoutBuilder`.

---

### M-08: Eliminar `dart:convert` import de models.dart si no necesario
**Archivo:** `lib/data/models/models.dart`  
**Nota:** `dart:convert` sí se usa para `jsonEncode`/`jsonDecode` en `CartModel.toJson()`/`CartModel.fromJson()`. Este import es correcto y necesario.

---

### M-09: Checkout flow — validar stock del servidor antes de crear pedido
**Archivo:** `lib/presentation/screens/cart/checkout_screen.dart`  
**Problema:** El checkout no verifica si los productos siguen teniendo stock suficiente antes de enviar al pago. El RPC `create_order_and_reduce_stock` puede lanzar un error de PostgreSQL si no hay stock.  
**Sugerencia:** Antes del paso de pago, llamar a una API que verifique disponibilidad.

---

### M-10: Implementar manejo de errores de red global
**Impacto:** Medio — Actualmente cada pantalla maneja errores individualmente.  
**Sugerencia:** Crear un interceptor de red o un `ProviderObserver` que detecte errores de conectividad y muestre un banner global.

---

### M-11: GoRouter — rutas admin sin guard de rol
**Archivo:** `lib/presentation/router.dart`  
**Problema:** Las rutas admin solo verifican si el usuario está autenticado, pero no si su `role == 'admin'`. Un usuario normal podría acceder a `/admin/dashboard` directamente.  
**Sugerencia:** Agregar verificación del campo `role` del usuario en el `redirect` del admin route.

---

### M-12: Cart — ID basado en timestamp puede colisionar
**Archivo:** `lib/presentation/providers/cart_provider.dart`  
```dart
id: DateTime.now().millisecondsSinceEpoch.toString()
```
**Problema:** Si se añaden dos productos en el mismo milisegundo, tendrán el mismo ID.  
**Sugerencia:** Usar `const Uuid().v4()` como en otras partes del código.

---

### M-13: ProductSearchDelegate — busca en cada keypress
**Archivo:** `lib/presentation/widgets/search/search_widgets.dart`  
**Problema:** `buildSuggestions` llama a `onSearch(query)` en cada cambio de texto sin debounce.  
**Sugerencia:** Aplicar debounce o usar el `SearchNotifier` existente que ya tiene debounce.

---

### M-14: HomeScreen timers — posible memory leak
**Archivo:** `lib/presentation/screens/home/home_screen.dart`  
**Problema:** El homescreen usa `WidgetsBindingObserver` para manejar timers del carrusel y banner. Si el dispose no se ejecuta correctamente (e.g., por navegación con GoRouter), los timers podrían seguir corriendo.  
**Sugerencia:** Verificar que `removeObserver` se llama en todos los caminos de disposición.

---

### M-15: FAQ con datos hardcodeados
**Archivo:** `lib/presentation/screens/info/faq_screen.dart`  
**Problema:** Las preguntas frecuentes mencionan "envío 4.99€" y "pedidos >49€" hardcodeados en vez de usar `AppConstants`.  
**Sugerencia:** Usar `AppConstants.shippingCost` y `AppConstants.freeShippingMinAmount`.

---

### M-16: Inconsistencia de moneda "49€" vs "50€"
**Archivos:**
- `app_constants.dart`: `freeShippingMinAmount = 50.0`
- `faq_screen.dart`: "pedidos superiores a 49€"  
- `terminos_screen.dart`: "pedidos >49€"  
- `admin_settings_screen.dart`: "Pedidos > 49€"
- `envios_screen.dart`: usa `AppConstants.freeShippingMinAmount` correctamente (50€)  
**Problema:** Hay discrepancia entre 49€ y 50€ en distintas partes de la app.  
**Sugerencia:** Usar siempre `AppConstants.freeShippingMinAmount` para evitar inconsistencias.

---

### M-17: AnimalType enum tiene icono repetido
**Archivo:** `lib/core/constants/app_constants.dart` (líneas 46-50)  
```dart
perro('Perros', Icons.pets),
gato('Gatos', Icons.pets),   // Mismo icono que perro
otro('Otros Animales', Icons.cruelty_free);
```
**Sugerencia:** Usar un icono distinto para gatos, por ejemplo un custom icon o emoji.

---

### M-18: Shimmer dependency solo la usa product_card.dart
**Archivo:** `pubspec.yaml` importa `shimmer`, pero solo se usa en un archivo.  
**Sugerencia:** Verificar si vale la pena la dependencia o crear un shimmer simple propio.

---

### M-19: Optimizar image cache
**Archivo:** `lib/main.dart` (líneas 30-32)  
```dart
PaintingBinding.instance.imageCache.maximumSize = 30;
PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
```
**Nota:** 50MB de cache de imágenes es razonable para una app de e-commerce. Sin embargo, `CachedNetworkImage` tiene su propio cache separado en disco. Considerar si el cache nativo de Flutter realmente se usa o si solo CachedNetworkImage maneja el caching.

---

### M-20: ProductCard — constraints `maxWidth: 180` puede ser limitante
**Archivo:** `lib/presentation/widgets/product/product_card.dart` (línea 29)  
**Problema:** En tablets o pantallas grandes, 180px puede ser muy pequeño.  
**Sugerencia:** Hacer el `maxWidth` responsivo basado en el ancho de pantalla.

---

### M-21: Falta envío de emails transaccionales
**Archivo:** `lib/data/datasources/supabase_data_source.dart`  
**Problema:** El `createOrder` usa RPC pero no hay lógica de envío de email de confirmación de pedido, ni de notificación de envío o entrega.  
**Sugerencia:** Implementar Edge Functions en Supabase para enviar emails transaccionales, o integrar un servicio como Resend/SendGrid.

---

### M-22: Agregar logging estructurado
**Impacto:** Medio — Debugging en producción  
**Problema:** Toda la app usa `debugPrint()` o `catch (_) {}` para logging. No hay logging estructurado, crashlytics, ni reportes de error.  
**Sugerencia:** Integrar Firebase Crashlytics o Sentry para captura de errores en producción.

---

## 📋 TABLAS DE SUPABASE IDENTIFICADAS

| Tabla | Campos principales | Uso |
|-------|-------------------|-----|
| `users` | id, email, full_name, phone, address, role, created_at | Perfil de usuario |
| `products` | id, name, slug, description, price, sale_price, on_sale, stock, image_url, images, brand, animal_type, size, category, age_range, is_featured, created_at | Catálogo de productos |
| `orders` | id, user_id, total, status, promo_code, discount_amount, shipping_address, shipping_name, shipping_phone, stripe_session_id, tracking_number, created_at, updated_at | Pedidos |
| `order_items` | id, order_id, product_id, quantity, price + join products(name, image_url) | Líneas de pedido |
| `product_reviews` | id, product_id, user_id, user_name, rating, comment, verified_purchase, helpful_count, created_at | Reseñas |
| `review_helpful_votes` | review_id, user_id | Votos de utilidad |
| `promo_codes` | id, code, discount_percentage, active, max_uses, current_uses, expires_at, created_at | Códigos descuento |
| `newsletters` | id, email, promo_code, source, created_at | Suscriptores newsletter |
| `invoices` | id, order_id, user_id, invoice_number, invoice_type, subtotal, tax_amount, total, pdf_url, created_at | Facturas |
| `returns` | id, order_id, user_id, reason, status, refund_amount, admin_notes, created_at, updated_at | Devoluciones |
| `site_settings` | key, value | Configuración del sitio |
| `contact_messages` | name, email, phone, subject, message, created_at | **⚠️ No documentada en supabase.sql** |

**Storage Bucket:** `products` (imágenes de productos)

---

## 🔌 RPCs DE SUPABASE

| RPC | Parámetros | Propósito |
|-----|-----------|-----------|
| `create_order_and_reduce_stock` | p_user_id, p_total, p_items, p_promo_code, p_discount_amount | Crea pedido + reduce stock atómicamente |
| `cancel_order_and_restore_stock` | order_uuid | Cancela pedido + restaura stock atómicamente |
| `get_product_review_stats` | p_product_id | Stats de reseñas (media, distribución) |
| `get_dashboard_stats` | — | KPIs del dashboard admin |
| `get_order_status_counts` | — | Conteo de pedidos por estado |

---

## 🔐 FLUJO DE AUTENTICACIÓN

```
1. Register: email + password → Supabase Auth signUp → insert users table → auto login
2. Login: email + password → Supabase Auth signInWithPassword → fetch user profile from users table
3. Session: supabase_flutter gestiona JWT automáticamente → onAuthStateChange para detectar expiración
4. Logout: Supabase Auth signOut → clear local state
5. Reset password: sendPasswordResetEmail → no hay pantalla para el callback URI
6. Role check: user.role == 'admin' → acceso a rutas /admin/*
```

---

## 🛒 FLUJO DE CARRITO Y CHECKOUT

```
1. Agregar al carrito → CartNotifier.addToCart() → se guarda en SharedPreferences (local)
2. Modificar cantidad → CartNotifier.updateQuantity() → persiste en SharedPreferences
3. Aplicar descuento → CartNotifier.applyDiscountCode() → valida contra tabla promo_codes
4. Checkout paso 1 → Formulario de envío (nombre, dirección, teléfono)
5. Checkout paso 2 → Resumen del pedido con productos, subtotal, envío, descuento, total
6. Checkout paso 3 → Pago (integración Stripe configurada con publishable key)
7. Crear pedido → OrdersNotifier.createOrder() → RPC create_order_and_reduce_stock
8. Success → checkout_success_screen con número de pedido y fecha estimada de entrega
9. Cancel → checkout_cancel_screen con info de carrito guardado
```

---

## 📁 ESTRUCTURA DE ARCHIVOS POR CAPA

### Core (5 archivos)
- `main.dart` — Entry point, inicialización Supabase, SharedPreferences, image cache
- `core/constants/app_constants.dart` — Constantes, enums, claves API
- `core/theme/app_theme.dart` — Tema Material3, colores, gradientes
- `core/utils/typedef.dart` — ResultFuture<T>, ResultVoid
- `core/utils/failure.dart` — Jerarquía de Failure (Server, Cache, Auth, Network, Validation, Unknown)

### Data (4 archivos)
- `data/models/models.dart` — 11 modelos con serialización JSON
- `data/datasources/supabase_data_source.dart` — Datasource Supabase (CRUD completo)
- `data/datasources/mock_data_source.dart` — Datos mock estáticos (18 productos)
- `data/repositories/repositories_impl.dart` — Implementaciones mock de repositorios
- `data/repositories/supabase_repositories_impl.dart` — Implementaciones Supabase

### Domain (2 archivos)
- `domain/entities/entities.dart` — 16 entidades con Equatable
- `domain/repositories/repositories.dart` — 8 interfaces de repositorio

### Presentation — Providers (8 archivos)
- `providers/providers.dart` — Barrel exports
- `providers/auth_provider.dart` — AuthNotifier
- `providers/cart_provider.dart` — CartNotifier
- `providers/favorites_provider.dart` — FavoritesNotifier
- `providers/order_provider.dart` — OrdersNotifier
- `providers/product_provider.dart` — ProductsNotifier, SearchNotifier, filtros
- `providers/review_provider.dart` — ReviewsStore, ReviewsActions
- `providers/repository_providers.dart` — Factory de repositorios (mock/Supabase)
- `providers/admin_provider.dart` — Notifiers de admin (dashboard, orders, products, etc.)

### Presentation — Screens (30 archivos)
- Home (1), Products (4), Cart (4), Auth (3), Profile (1), Orders (2), Ofertas (1), Favorites (1), Blog (2), Info (3), Legal (3), Admin (9+)

### Presentation — Widgets (9 archivos)
- `widgets/common/common_widgets.dart` — PrimaryButton, GradientButton, EmptyState, ErrorState, LoadingIndicator, CustomSnackBar, CountBadge, SectionHeader
- `widgets/common/cookie_consent_banner.dart` — Banner GDPR
- `widgets/common/newsletter_widgets.dart` — NewsletterPopup, NewsletterBanner
- `widgets/product/product_card.dart` — ProductCard con favoritos, descuento, add-to-cart
- `widgets/product/product_filters.dart` — ProductFilterBar, FiltersBottomSheet
- `widgets/product/review_widgets.dart` — StarRating, StarRatingInput, ReviewDistributionBar, ReviewsList, ReviewCard, CreateReviewForm
- `widgets/cart/cart_widgets.dart` — CartItemCard, QuantitySelector
- `widgets/order/order_widgets.dart` — OrderCard, OrderStatusBadge, OrderTimeline
- `widgets/search/search_widgets.dart` — SearchResultItem, ProductSearchDelegate

---

## ✅ ASPECTOS POSITIVOS

1. **Clean Architecture bien estructurada** — Separación clara entre data/domain/presentation
2. **Either pattern con dartz** — Manejo funcional de errores con `ResultFuture<T>`
3. **Riverpod bien implementado** — Notifiers con states, providers autodispose
4. **UI consistente** — Diseño coherente con gradientes, shadows, border radius
5. **Responsive design** — Muchas pantallas adaptan columnas según screenWidth
6. **GoRouter con ShellRoute** — Navegación robusta con bottom nav persistente
7. **RepaintBoundary en listas** — Optimización de rendering en grids de productos
8. **CachedNetworkImage mayoritariamente** — Buen uso de cache de imágenes
9. **Cookie consent GDPR** — Banner de cookies con opciones granulares
10. **DisposeMixin correcto** — TextEditingControllers se disponen en todos los StatefulWidgets
11. **Supabase RPCs atómicas** — Operaciones de pedido/stock en transacciones del servidor
12. **Feature flags** — `useMockData` para desarrollo sin backend

---

*Fin del informe de auditoría*
