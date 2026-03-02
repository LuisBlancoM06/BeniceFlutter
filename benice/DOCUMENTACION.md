https://github.com/LuisBlancoM06/BeniceFlutter

# 📖 Documentación del Proyecto BeniceAstro (Flutter)

> **BeniceAstro** — Tienda online de mascotas desarrollada con Flutter  
> Versión: 1.0.0 | SDK: Flutter ≥ 3.9.2 | Dart ≥ 3.9.2

---

## Índice

1. [Descripción General](#1-descripción-general)
2. [Arquitectura del Proyecto](#2-arquitectura-del-proyecto)
3. [Estructura de Carpetas](#3-estructura-de-carpetas)
4. [Tecnologías y Dependencias](#4-tecnologías-y-dependencias)
5. [Configuración del Entorno](#5-configuración-del-entorno)
6. [Capa de Dominio](#6-capa-de-dominio)
7. [Capa de Datos](#7-capa-de-datos)
8. [Capa de Presentación](#8-capa-de-presentación)
9. [Navegación y Rutas](#9-navegación-y-rutas)
10. [Gestión de Estado](#10-gestión-de-estado)
11. [Panel de Administración](#11-panel-de-administración)
12. [Tema y Diseño Visual](#12-tema-y-diseño-visual)
13. [Despliegue y Docker](#13-despliegue-y-docker)
14. [Tests](#14-tests)
15. [Variables de Entorno](#15-variables-de-entorno)
16. [Constantes de Negocio](#16-constantes-de-negocio)
17. [Base de Datos (Supabase)](#17-base-de-datos-supabase)
18. [Guía de Desarrollo](#18-guía-de-desarrollo)

---

## 1. Descripción General

**BeniceAstro** es una aplicación multiplataforma (web, Android, iOS, Windows, macOS, Linux) construida con Flutter. Funciona como una tienda online especializada en productos para mascotas (perros, gatos y otros animales).

### Funcionalidades principales:
- **Catálogo de productos** con filtros por animal, categoría, tamaño, edad y precio
- **Carrito de compras** con persistencia local (SharedPreferences)
- **Sistema de pedidos** completo con estados (pendiente → pagado → enviado → entregado)
- **Autenticación** de usuarios (registro, login, recuperación de contraseña)
- **Pagos** integrados con Stripe (checkout sessions)
- **Sistema de reseñas** con valoraciones y votos de utilidad
- **Favoritos** por usuario
- **Códigos de descuento / promociones** con validación
- **Newsletter** con generación automática de códigos promocionales
- **Ofertas flash** activables desde el panel admin
- **Blog** con artículos y detalle por slug
- **Recomendador de productos** para mascotas
- **Panel de administración** completo (dashboard, pedidos, productos, facturas, devoluciones, cancelaciones, newsletter, ajustes)
- **Páginas legales**: privacidad, términos, cookies
- **Páginas informativas**: contacto, FAQ, envíos, sobre nosotros

---

## 2. Arquitectura del Proyecto

El proyecto sigue una **Clean Architecture** con tres capas claramente separadas:

```
┌─────────────────────────────────────────────┐
│              PRESENTACIÓN                   │
│  (Screens, Widgets, Providers, Router)      │
├─────────────────────────────────────────────┤
│                DOMINIO                      │
│  (Entities, Repositories [abstractos],      │
│   Services)                                 │
├─────────────────────────────────────────────┤
│                 DATOS                       │
│  (Models, DataSources, Repositories [impl]) │
└─────────────────────────────────────────────┘
```

### Principios:
- **Separación de responsabilidades**: cada capa tiene un propósito claro
- **Inversión de dependencias**: la capa de dominio define interfaces (repositorios abstractos), y la capa de datos las implementa
- **Inmutabilidad**: las entidades extienden `Equatable` para comparación por valor
- **Manejo de errores funcional**: se utiliza `Either<Failure, T>` del paquete `dartz` para resultados que pueden fallar

---

## 3. Estructura de Carpetas

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── core/                              # Núcleo compartido
│   ├── constants/
│   │   └── app_constants.dart         # Constantes globales y configuración
│   ├── theme/
│   │   └── app_theme.dart             # Tema visual (colores, gradientes, estilos)
│   └── utils/
│       ├── failure.dart               # Clase Failure para errores
│       ├── typedef.dart               # Tipos ResultFuture<T> y ResultVoid
│       └── validators.dart            # Validadores de formularios
│
├── domain/                            # Capa de dominio (reglas de negocio)
│   ├── entities/
│   │   └── entities.dart              # Todas las entidades del dominio
│   ├── repositories/
│   │   └── repositories.dart          # Interfaces de repositorios
│   └── services/
│       ├── stock_service.dart         # Servicio de gestión de stock
│       └── stripe_payment_service.dart # Servicio de pagos Stripe
│
├── data/                              # Capa de datos (implementaciones)
│   ├── datasources/
│   │   ├── supabase_data_source.dart  # Datasource para Supabase (producción)
│   │   └── mock_data_source.dart      # Datasource con datos simulados
│   ├── models/
│   │   └── models.dart                # Modelos de datos (fromJson/toJson)
│   └── repositories/
│       ├── repositories_impl.dart     # Implementación con datos mock
│       └── supabase_repositories_impl.dart # Implementación con Supabase
│
├── presentation/                      # Capa de presentación (UI)
│   ├── router.dart                    # Configuración de GoRouter
│   ├── providers/                     # Providers de Riverpod
│   │   ├── providers.dart             # Barrel file de providers
│   │   ├── repository_providers.dart  # Providers de repositorios
│   │   ├── auth_provider.dart         # Estado de autenticación
│   │   ├── product_provider.dart      # Estado de productos
│   │   ├── cart_provider.dart         # Estado del carrito
│   │   ├── order_provider.dart        # Estado de pedidos
│   │   ├── review_provider.dart       # Estado de reseñas
│   │   ├── favorites_provider.dart    # Estado de favoritos
│   │   ├── admin_provider.dart        # Estado del panel admin
│   │   └── stock_provider.dart        # Estado del stock
│   ├── screens/                       # Pantallas de la app
│   │   ├── screens.dart               # Barrel file de screens
│   │   ├── admin/                     # Pantallas de administración
│   │   ├── auth/                      # Login, registro, recuperar contraseña
│   │   ├── blog/                      # Blog y detalle de artículos
│   │   ├── cart/                      # Carrito, checkout, éxito/cancelación
│   │   ├── favorites/                 # Pantalla de favoritos
│   │   ├── home/                      # Pantalla de inicio
│   │   ├── info/                      # Contacto, FAQ, envíos, sobre nosotros
│   │   ├── legal/                     # Privacidad, términos, cookies
│   │   ├── ofertas/                   # Ofertas flash
│   │   ├── orders/                    # Listado y detalle de pedidos
│   │   ├── products/                  # Catálogo, detalle, recomendador
│   │   └── profile/                   # Perfil del usuario
│   └── widgets/                       # Widgets reutilizables
│       ├── common/                    # Widgets comunes (cookie consent, etc.)
│       ├── cart/                      # Widgets del carrito
│       ├── order/                     # Widgets de pedidos
│       ├── product/                   # Widgets de productos
│       └── search/                    # Widgets de búsqueda
```

---

## 4. Tecnologías y Dependencias

### Paquetes principales:

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter_riverpod` | ^3.1.0 | Gestión de estado reactiva |
| `go_router` | ^17.0.1 | Navegación declarativa con rutas nombradas |
| `supabase_flutter` | ^2.5.9 | Backend (BD, auth, storage) |
| `shared_preferences` | ^2.2.3 | Almacenamiento local (carrito, preferencias) |
| `flutter_dotenv` | ^5.2.1 | Variables de entorno desde `.env` |
| `cached_network_image` | ^3.3.1 | Imágenes con caché |
| `shimmer` | ^3.0.0 | Efecto de carga (skeleton) |
| `http` | ^1.2.1 | Peticiones HTTP (Stripe, Resend) |
| `intl` | any | Internacionalización y formateo de fechas |
| `uuid` | ^4.4.2 | Generación de IDs únicos |
| `equatable` | ^2.0.5 | Comparación de entidades por valor |
| `dartz` | ^0.10.1 | Tipos funcionales (Either, Option) |
| `carousel_slider` | ^5.0.0 | Carrusel de imágenes de productos |

### Dev Dependencies:

| Paquete | Propósito |
|---------|-----------|
| `flutter_test` | Framework de testing |
| `flutter_lints` | Reglas de lint |
| `mockito` | Mocking para tests |
| `build_runner` | Generación de código |

---

## 5. Configuración del Entorno

### Requisitos previos:
- Flutter SDK ≥ 3.9.2
- Dart SDK ≥ 3.9.2
- Cuenta de Supabase (proyecto configurado)
- Cuenta de Stripe (para pagos)

### Instalación:

```bash
# Clonar el repositorio
git clone <repo-url>
cd benice

# Instalar dependencias
flutter pub get

# Crear archivo .env en la raíz del proyecto
cp .env.example .env   # o crear manualmente
```

### Archivo `.env` requerido:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key
STRIPE_SECRET_KEY=sk_...
STRIPE_PUBLISHABLE_KEY=pk_...
STRIPE_WEBHOOK_SECRET=whsec_...
RESEND_API_KEY=re_...
FROM_EMAIL=ventas@tudominio.com
PUBLIC_SITE_URL=https://tudominio.com
CLOUDINARY_CLOUD_NAME=tu-cloud
CLOUDINARY_API_KEY=tu-api-key
CLOUDINARY_API_SECRET=tu-api-secret
GOOGLE_PLACES_API_KEY=tu-google-key
FLUTTER_ENV=development
```

### Ejecutar la aplicación:

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

---

## 6. Capa de Dominio

### Entidades

Todas las entidades se encuentran en `lib/domain/entities/entities.dart` y extienden `Equatable`:

| Entidad | Descripción | Campos clave |
|---------|-------------|--------------|
| `UserEntity` | Usuario de la app | id, email, name, fullName, phone, address, city, postalCode, role, isSubscribedNewsletter |
| `ProductEntity` | Producto del catálogo | id, name, slug, description, price, discountPrice, onSale, imageUrl, images, animalType, animalSize, category, animalAge, stock, brand, rating |
| `CartItemEntity` | Ítem individual del carrito | id, product, quantity |
| `CartEntity` | Carrito completo | items, discountCode, discountPercent |
| `OrderEntity` | Pedido | id, orderNumber, userId, items, subtotal, discount, shippingCost, total, status, shippingAddress, trackingNumber |
| `OrderItemEntity` | Ítem de un pedido | id, productId, productName, productImage, price, quantity |
| `DiscountCodeEntity` | Código de descuento | code, discountPercent, isActive, maxUses, currentUses, expiresAt |
| `ReviewEntity` | Reseña de producto | id, productId, userId, userName, rating, comment, verifiedPurchase, helpfulCount |
| `ReviewStats` | Estadísticas de reseñas | averageRating, totalReviews, distribution |
| `InvoiceEntity` | Factura | id, orderId, invoiceNumber, invoiceType, subtotal, taxAmount, total, pdfUrl |
| `ReturnEntity` | Devolución | id, orderId, userId, reason, status, refundAmount, adminNotes |
| `CancellationRequestEntity` | Solicitud de cancelación | id, orderId, userId, reason, status, adminNotes, stripeRefundId |
| `NewsletterSubscriber` | Suscriptor de newsletter | id, email, promoCode, source |
| `SiteSettingsEntity` | Configuración del sitio | ofertasFlashActive, storeName, storeEmail, storePhone |
| `FavoriteEntity` | Producto favorito | productId, addedAt |
| `DashboardStats` | Estadísticas del dashboard | totalSales, totalOrders, totalUsers, totalProducts, lowStockProducts, recentOrders, salesByMonth, ordersByStatus |
| `ProductFilters` | Filtros de búsqueda | animalType, animalSize, category, animalAge, searchQuery, minPrice, maxPrice, onlyWithDiscount, onlyInStock |

### Enumeraciones

| Enum | Valores |
|------|---------|
| `AnimalType` | perro, gato, otros |
| `AnimalSize` | mini (hasta 5kg), mediano (5-25kg), grande (más de 25kg) |
| `ProductCategory` | alimentacion, higiene, salud, accesorios, juguetes |
| `AnimalAge` | cachorro (0-1 año), adulto (1-7 años), senior (+7 años) |
| `OrderStatus` | pendiente, pagado, enviado, entregado, cancelado |

### Repositorios (interfaces abstractas)

Definidos en `lib/domain/repositories/repositories.dart`:

| Repositorio | Responsabilidad |
|-------------|----------------|
| `AuthRepository` | Login, registro, logout, perfil, newsletter, cambio de contraseña |
| `ProductRepository` | Listado, búsqueda, filtrado, destacados, ofertas, por categoría/animal |
| `CartRepository` | CRUD del carrito, aplicar/quitar descuentos, persistencia local |
| `OrderRepository` | Crear pedidos, listar, solicitar cancelación/devolución |
| `DiscountRepository` | Validar códigos de descuento |
| `ReviewRepository` | Reviews CRUD, estadísticas, votar como útil |
| `FavoritesRepository` | Gestionar favoritos del usuario |
| `AdminRepository` | CRUD de productos, pedidos, dashboard, newsletter, facturas, devoluciones, cancelaciones, promos, ajustes |

### Manejo de errores

Se utiliza el patrón funcional con `Either<Failure, T>`:

```dart
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;
```

Esto permite que cada operación del repositorio devuelva un resultado que puede ser:
- `Right(valor)` → operación exitosa
- `Left(Failure)` → error con mensaje descriptivo

---

## 7. Capa de Datos

### DataSources

| DataSource | Archivo | Descripción |
|------------|---------|-------------|
| `SupabaseDataSource` | `supabase_data_source.dart` | Conexión real con Supabase (producción) |
| `MockDataSource` | `mock_data_source.dart` | Datos simulados para desarrollo sin backend |

La selección del datasource se controla con `AppConstants.useMockData`:
- `true` → usa implementaciones mock
- `false` → usa implementaciones Supabase

### Models

Los modelos (en `models.dart`) extienden las entidades del dominio y añaden:
- `fromJson()` → deserialización desde JSON/Supabase
- `toJson()` → serialización para enviar a Supabase
- `fromEntity()` → conversión desde entidad de dominio

### Implementaciones de Repositorios

| Implementación | Archivo | DataSource |
|----------------|---------|------------|
| `*RepositoryImpl` | `repositories_impl.dart` | Datos mock / SharedPreferences |
| `Supabase*RepositoryImpl` | `supabase_repositories_impl.dart` | SupabaseDataSource |

---

## 8. Capa de Presentación

### Pantallas (Screens)

#### Públicas (usuario):

| Pantalla | Ruta | Archivo |
|----------|------|---------|
| Inicio | `/` | `home/home_screen.dart` |
| Catálogo de productos | `/products` | `products/products_screen.dart` |
| Detalle de producto | `/product/:id` | `products/product_detail_screen.dart` |
| Productos por animal | `/perros`, `/gatos`, `/otros` | `products/animal_products_screen.dart` |
| Recomendador | `/recommender` | `products/recommender_screen.dart` |
| Carrito | `/cart` | `cart/cart_screen.dart` |
| Checkout | `/checkout` | `cart/checkout_screen.dart` |
| Checkout éxito | `/checkout/success` | `cart/checkout_success_screen.dart` |
| Checkout cancelado | `/checkout/cancel` | `cart/checkout_cancel_screen.dart` |
| Pedidos | `/orders` | `orders/orders_screen.dart` |
| Detalle de pedido | `/orders/:id` | `orders/order_detail_screen.dart` |
| Perfil | `/profile` | `profile/profile_screen.dart` |
| Favoritos | `/favorites` | `favorites/favorites_screen.dart` |
| Ofertas flash | `/ofertas` | `ofertas/ofertas_screen.dart` |
| Blog | `/blog` | `blog/blog_screen.dart` |
| Artículo del blog | `/blog/:slug` | `blog/blog_detail_screen.dart` |

#### Autenticación:

| Pantalla | Ruta | Archivo |
|----------|------|---------|
| Login | `/login` | `auth/login_screen.dart` |
| Registro | `/register` | `auth/register_screen.dart` |
| Recuperar contraseña | `/forgot-password` | `auth/forgot_password_screen.dart` |

#### Informativas:

| Pantalla | Ruta | Archivo |
|----------|------|---------|
| Contacto | `/contact` | `info/contact_screen.dart` |
| FAQ | `/faq` | `info/faq_screen.dart` |
| Envíos | `/shipping` | `info/envios_screen.dart` |
| Sobre nosotros | `/about` | `info/sobre_nosotros_screen.dart` |

#### Legales:

| Pantalla | Ruta | Archivo |
|----------|------|---------|
| Privacidad | `/privacy` | `legal/privacidad_screen.dart` |
| Términos | `/terms` | `legal/terminos_screen.dart` |
| Cookies | `/cookies` | `legal/cookies_screen.dart` |

#### Administración (requiere rol admin):

| Pantalla | Ruta | Archivo |
|----------|------|---------|
| Dashboard | `/admin` | `admin/admin_dashboard_screen.dart` |
| Pedidos | `/admin/orders` | `admin/admin_orders_screen.dart` |
| Productos | `/admin/products` | `admin/admin_products_screen.dart` |
| Crear/editar producto | `/admin/products/new` `/admin/products/:id` | `admin/admin_product_form_screen.dart` |
| Ofertas | `/admin/ofertas` | `admin/admin_ofertas_screen.dart` |
| Newsletter | `/admin/newsletter` | `admin/admin_newsletter_screen.dart` |
| Devoluciones | `/admin/returns` | `admin/admin_returns_screen.dart` |
| Cancelaciones | `/admin/cancellations` | `admin/admin_cancellations_screen.dart` |
| Facturas | `/admin/invoices` | `admin/admin_invoices_screen.dart` |
| Visitas | `/admin/visits` | `admin/admin_visits_screen.dart` |
| Ajustes | `/admin/settings` | `admin/admin_settings_screen.dart` |

### Widgets reutilizables

Organizados en subcarpetas dentro de `lib/presentation/widgets/`:

| Carpeta | Contenido |
|---------|-----------|
| `common/` | Widgets compartidos (CookieConsentBanner, etc.) |
| `cart/` | Widgets específicos del carrito |
| `order/` | Widgets de pedidos |
| `product/` | Tarjetas de producto, galerías, etc. |
| `search/` | Barra de búsqueda y resultados |

---

## 9. Navegación y Rutas

La navegación usa **GoRouter** configurado en `lib/presentation/router.dart`.

### Estructura de navegación:

```
ShellRoute (MainShell con BottomNavigationBar)
├── /              → HomeScreen
├── /products      → ProductsScreen
├── /cart          → CartScreen
├── /orders        → OrdersScreen
└── /profile       → ProfileScreen

Rutas independientes (sin shell):
├── /login, /register, /forgot-password
├── /product/:id
├── /checkout, /checkout/success, /checkout/cancel
├── /orders/:id
├── /ofertas, /favorites
├── /blog, /blog/:slug
├── /perros, /gatos, /otros
├── /recommender
├── /contact, /faq, /shipping, /about
├── /privacy, /terms, /cookies
└── /admin/* (todas las rutas de admin)
```

### Protección de rutas admin:

El router implementa un `redirect` que verifica:
1. Si la ruta empieza con `/admin`
2. Si el usuario está autenticado
3. Si el usuario tiene rol `admin`

Si no cumple las condiciones, redirige a `/login` o `/`.

### Bottom Navigation Bar:

La app usa un `MainShell` con 5 tabs:
1. **Inicio** (icono: home)
2. **Tienda** (icono: storefront)
3. **Carrito** (icono: shopping_cart) — con badge de cantidad
4. **Pedidos** (icono: receipt_long)
5. **Perfil** (icono: person)

---

## 10. Gestión de Estado

Se utiliza **Flutter Riverpod** (v3.1.0) como solución de gestión de estado.

### Providers principales:

| Provider | Archivo | Propósito |
|----------|---------|-----------|
| `sharedPreferencesProvider` | `repository_providers.dart` | Instancia de SharedPreferences |
| `supabaseClientProvider` | `repository_providers.dart` | Cliente Supabase |
| `supabaseDataSourceProvider` | `repository_providers.dart` | DataSource de Supabase |
| `authRepositoryProvider` | `repository_providers.dart` | Repositorio de auth |
| `productRepositoryProvider` | `repository_providers.dart` | Repositorio de productos |
| `cartRepositoryProvider` | `repository_providers.dart` | Repositorio del carrito |
| `orderRepositoryProvider` | `repository_providers.dart` | Repositorio de pedidos |
| `discountRepositoryProvider` | `repository_providers.dart` | Repositorio de descuentos |
| `reviewRepositoryProvider` | `repository_providers.dart` | Repositorio de reviews |
| `adminRepositoryProvider` | `repository_providers.dart` | Repositorio de admin |
| `authProvider` | `auth_provider.dart` | Estado de autenticación del usuario |
| `productProvider` | `product_provider.dart` | Estado de productos y filtros |
| `cartProvider` | `cart_provider.dart` | Estado del carrito de compras |
| `orderProvider` | `order_provider.dart` | Estado de pedidos |
| `reviewProvider` | `review_provider.dart` | Estado de reseñas |
| `favoritesProvider` | `favorites_provider.dart` | Estado de favoritos |
| `adminProvider` | `admin_provider.dart` | Estado del panel de administración |
| `stockProvider` | `stock_provider.dart` | Estado de stock de productos |

### Patrón de inyección:

```dart
// En main.dart, se inyecta SharedPreferences
ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  child: const BeniceAstroApp(),
);

// Los repositorios seleccionan automáticamente mock o Supabase
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppConstants.useMockData) {
    return ProductRepositoryImpl();
  }
  return SupabaseProductRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});
```

---

## 11. Panel de Administración

El panel admin está protegido por rol y ofrece las siguientes funcionalidades:

### Dashboard (`/admin`)
- Estadísticas generales: ventas totales, pedidos, usuarios, productos
- Productos con stock bajo
- Pedidos recientes
- Gráficos de ventas por mes y pedidos por estado

### Gestión de Pedidos (`/admin/orders`)
- Listado de todos los pedidos con filtro por estado
- Actualizar estado de pedido

### Gestión de Productos (`/admin/products`)
- Listado completo de productos
- Crear nuevo producto (`/admin/products/new`)
- Editar producto existente (`/admin/products/:id`)
- Eliminar producto

### Ofertas Flash (`/admin/ofertas`)
- Activar/desactivar ofertas flash globalmente

### Newsletter (`/admin/newsletter`)
- Ver todos los suscriptores
- Eliminar suscriptores

### Devoluciones (`/admin/returns`)
- Ver solicitudes de devolución
- Aprobar/rechazar con notas del admin

### Cancelaciones (`/admin/cancellations`)
- Ver solicitudes de cancelación (con filtro por estado)
- Aprobar cancelación (incluye reembolso vía Stripe)
- Rechazar cancelación con notas

### Facturas (`/admin/invoices`)
- Listado de facturas generadas

### Visitas (`/admin/visits`)
- Estadísticas de visitas al sitio

### Ajustes (`/admin/settings`)
- Configuración general del sitio
- Gestión de códigos promocionales (crear/eliminar)

---

## 12. Tema y Diseño Visual

Definido en `lib/core/theme/app_theme.dart`.

### Paleta de colores:

| Color | Hex | Uso |
|-------|-----|-----|
| Primary | `#7E22CE` (purple-700) | Color principal |
| Primary Light | `#A855F7` (purple-500) | Variante clara |
| Primary Dark | `#6B21A8` (purple-800) | Variante oscura |
| Secondary | `#F97316` (orange-500) | Color de acento |
| Text Primary | `#1F2937` (gray-800) | Texto principal |
| Text Secondary | `#6B7280` (gray-500) | Texto secundario |
| Text Light | `#9CA3AF` (gray-400) | Texto ligero |

### Gradientes:
- **Primary Gradient**: purple-700 → purple-600
- **Hero Gradient (perros)**: purple-900 → transparente
- **Hero Gradient (gatos)**: amber-900 → transparente
- **Admin Sidebar**: purple-900 → purple-800

### Características del tema:
- Diseño idéntico a la versión web (Astro)
- Material Design 3
- Bottom Navigation con animaciones
- Shimmer loading effects
- Caché de imágenes con `cached_network_image`
- `TextScaler.noScaling` para mantener tamaños consistentes

---

## 13. Despliegue y Docker

### Build para Web:

```bash
flutter build web --release --base-href="/"
```

### Docker (producción):

El proyecto incluye un `Dockerfile` multi-stage:

**Stage 1 — Build:**
- Imagen base: `ghcr.io/cirruslabs/flutter:3.35.6`
- Genera `.env` desde build arguments
- Ejecuta `flutter build web --release`

**Stage 2 — Serve:**
- Imagen base: `nginx:alpine`
- Copia la build web a Nginx
- Configuración personalizada de Nginx (`nginx.conf`)

### Configuración Nginx:
- Gzip habilitado para assets estáticos
- Caché de 1 año para assets (js, css, imágenes, wasm)
- SPA fallback (`try_files` → `index.html`)
- Headers de seguridad (X-Frame-Options, X-Content-Type-Options, XSS Protection, Referrer-Policy)

### Desplegar con Docker:

```bash
docker build \
  --build-arg PUBLIC_SUPABASE_URL="https://tu-proyecto.supabase.co" \
  --build-arg PUBLIC_SUPABASE_ANON_KEY="tu-anon-key" \
  --build-arg STRIPE_SECRET_KEY="sk_..." \
  --build-arg STRIPE_PUBLISHABLE_KEY="pk_..." \
  -t benice-flutter .

docker run -p 80:80 benice-flutter
```

---

## 14. Tests

Los tests se ubican en la carpeta `test/`:

| Archivo | Descripción |
|---------|-------------|
| `widget_test.dart` | Tests de widgets |
| `product_entity_test.dart` | Tests de la entidad ProductEntity |
| `stock_test.dart` | Tests de gestión de stock |
| `stock_validation_test.dart` | Tests de validación de stock |

### Ejecutar tests:

```bash
# Todos los tests
flutter test

# Un test específico
flutter test test/product_entity_test.dart

# Con cobertura
flutter test --coverage
```

---

## 15. Variables de Entorno

Todas las variables se leen desde `.env` usando `flutter_dotenv` y se acceden vía `AppConstants`:

| Variable | Propiedad | Descripción |
|----------|-----------|-------------|
| `SUPABASE_URL` | `AppConstants.supabaseUrl` | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | `AppConstants.supabaseAnonKey` | Clave anónima de Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | `AppConstants.supabaseServiceRoleKey` | Clave de servicio de Supabase |
| `STRIPE_SECRET_KEY` | `AppConstants.stripeSecretKey` | Clave secreta de Stripe |
| `STRIPE_PUBLISHABLE_KEY` | `AppConstants.stripePublishableKey` | Clave pública de Stripe |
| `STRIPE_WEBHOOK_SECRET` | `AppConstants.stripeWebhookSecret` | Secreto del webhook de Stripe |
| `RESEND_API_KEY` | `AppConstants.resendApiKey` | API key de Resend (email) |
| `FROM_EMAIL` | `AppConstants.fromEmail` | Email remitente |
| `PUBLIC_SITE_URL` | `AppConstants.publicSiteUrl` | URL pública del sitio |
| `CLOUDINARY_CLOUD_NAME` | `AppConstants.cloudinaryCloudName` | Nombre del cloud de Cloudinary |
| `CLOUDINARY_API_KEY` | `AppConstants.cloudinaryApiKey` | API key de Cloudinary |
| `CLOUDINARY_API_SECRET` | `AppConstants.cloudinaryApiSecret` | API secret de Cloudinary |
| `GOOGLE_PLACES_API_KEY` | `AppConstants.googlePlacesApiKey` | API key de Google Places |
| `FLUTTER_ENV` | `AppConstants.flutterEnv` | Entorno (development/production) |

---

## 16. Constantes de Negocio

Definidas en `lib/core/constants/app_constants.dart`:

| Constante | Valor | Descripción |
|-----------|-------|-------------|
| `useMockData` | `false` | Usar datos mock vs Supabase |
| `appName` | `BeniceFlutter` | Nombre de la app |
| `appVersion` | `1.0.0` | Versión |
| `searchDebounceMs` | `500` | Debounce de búsqueda (ms) |
| `productsPerPage` | `20` | Productos por página |
| `maxQuantityPerProduct` | `99` | Cantidad máxima por producto en carrito |
| `freeShippingMinAmount` | `49.0€` | Mínimo para envío gratis |
| `shippingCost` | `4.99€` | Coste de envío estándar |
| `newsletterDiscountPercent` | `10%` | Descuento por suscripción a newsletter |
| `newsletterPromoMaxUses` | `1` | Usos máximos del código newsletter |
| `newsletterPromoDaysValid` | `30` | Días de validez del código |
| `lowStockThreshold` | `10` | Umbral de stock bajo |
| `outOfStockThreshold` | `0` | Umbral de sin stock |

---

## 17. Base de Datos (Supabase)

### Tablas principales:

| Tabla | Campos clave |
|-------|--------------|
| `users` | id, email, full_name, phone, address, address_line1, address_line2, city, postal_code, country, stripe_customer_id, role, is_subscribed_newsletter, created_at |
| `products` | id, name, slug, description, price, sale_price, on_sale, image_url, images, category, animal_type, size, age_range, stock, brand, rating, reviews_count, created_at |
| `orders` | id, order_number, user_id, subtotal, discount_amount, shipping_cost, total, promo_code, status, shipping_address, shipping_name, shipping_phone, stripe_session_id, tracking_number, notes, created_at, updated_at |
| `order_items` | id, order_id, product_id, product_name, product_image, price, quantity |
| `reviews` | id, product_id, user_id, user_name, rating, comment, verified_purchase, helpful_count, created_at |
| `promo_codes` | id, code, discount_percentage, active, max_uses, current_uses, expires_at, created_at |
| `invoices` | id, order_id, user_id, invoice_number, invoice_type, subtotal, tax_amount, total, pdf_url, created_at |
| `returns` | id, order_id, user_id, reason, status, refund_amount, admin_notes, created_at, updated_at |
| `cancellation_requests` | id, order_id, user_id, reason, status, admin_notes, stripe_refund_id, created_at, updated_at |
| `newsletters` | id, email, promo_code, source, created_at |

### Funciones SQL:
Se encuentran en `database/stock_functions.sql` — contienen funciones para gestión de stock.

---

## 18. Guía de Desarrollo

### Añadir una nueva pantalla:

1. Crear el archivo en `lib/presentation/screens/<modulo>/nueva_screen.dart`
2. Exportar en `lib/presentation/screens/screens.dart`
3. Añadir la ruta en `lib/presentation/router.dart`

### Añadir una nueva entidad:

1. Definir la entidad en `lib/domain/entities/entities.dart` (extender `Equatable`)
2. Crear el modelo en `lib/data/models/models.dart` (con `fromJson`/`toJson`)
3. Definir el repositorio abstracto en `lib/domain/repositories/repositories.dart`
4. Implementar en `lib/data/repositories/supabase_repositories_impl.dart`
5. Crear el provider en `lib/presentation/providers/`
6. Registrar el provider del repositorio en `repository_providers.dart`

### Añadir un nuevo provider:

1. Crear archivo en `lib/presentation/providers/nuevo_provider.dart`
2. Exportar en `lib/presentation/providers/providers.dart`

### Cambiar entre mock y Supabase:

En `lib/core/constants/app_constants.dart`:
```dart
static const bool useMockData = false; // true para mock, false para Supabase
```

### Optimización de imágenes:

La app limita la caché de imágenes en memoria:
```dart
PaintingBinding.instance.imageCache.maximumSize = 30;      // máx 30 imágenes
PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
```

### Convenciones de código:

- **Idioma**: el código usa español para nombres de negocio (entidades, constantes) e inglés para patrones técnicos
- **Nombrado de archivos**: snake_case (`admin_orders_screen.dart`)
- **Nombrado de clases**: PascalCase (`AdminOrdersScreen`)
- **Providers**: camelCase terminando en `Provider` (`orderProvider`)
- **Linting**: reglas definidas en `analysis_options.yaml` con `flutter_lints`

---

> Documentación generada automáticamente el 1 de marzo de 2026.  
> Proyecto: BeniceAstro Flutter v1.0.0
