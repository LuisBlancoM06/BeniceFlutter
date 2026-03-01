// Constantes de la aplicación Venice Pet Shop
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-key';
  static String get supabaseServiceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  // Stripe Configuration
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeWebhookSecret =>
      dotenv.env['STRIPE_WEBHOOK_SECRET'] ?? '';

  // Resend Email Configuration
  static String get resendApiKey => dotenv.env['RESEND_API_KEY'] ?? '';
  static String get fromEmail =>
      dotenv.env['FROM_EMAIL'] ?? 'ventas@beniceflutter.com';

  // Site Configuration
  static String get publicSiteUrl =>
      dotenv.env['PUBLIC_SITE_URL'] ?? 'http://localhost:3000';

  // Cloudinary Configuration
  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get cloudinaryApiSecret =>
      dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  // Google Places API
  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // Flutter Environment
  static String get flutterEnv => dotenv.env['FLUTTER_ENV'] ?? 'development';

  // Data Source Mode: set to false to use live Supabase data
  static const bool useMockData = false;

  // App Info
  static const String appName = 'BeniceFlutter';
  static const String appVersion = '1.0.0';
  static const String appTagline =
      'Todo lo que tu mascota necesita en un solo lugar';

  // Tiempos de debounce
  static const int searchDebounceMs = 500;

  // Paginación
  static const int productsPerPage = 20;

  // Carrito (mismo límite que Astro: 99)
  static const int maxQuantityPerProduct = 99;

  // Newsletter (cada suscriptor recibe un código único)
  static const String newsletterPromoCodePrefix = 'BIENVENIDO';
  static const int newsletterDiscountPercent = 10;
  static const int newsletterPromoMaxUses = 1;
  static const int newsletterPromoDaysValid = 30;

  // Envío (mismos valores que Astro)
  static const double freeShippingMinAmount = 49.0;
  static const double shippingCost = 4.99;

  // Devoluciones
  static const String warehouseAddress =
      'Calle Mascotas, 123\n28001 Madrid, España';
  static const String returnDaysInfo = '5-7 días hábiles para el reembolso';

  // Stock Configuration
  static const int lowStockThreshold = 10;
  static const int outOfStockThreshold = 0;
}

// Tipos de animales
enum AnimalType {
  perro('Perros', Icons.pets),
  gato('Gatos', Icons.pets),
  otros('Otros Animales', Icons.cruelty_free);

  final String label;
  final IconData icon;
  const AnimalType(this.label, this.icon);
}

// Tamaños de animales
enum AnimalSize {
  mini('Mini', 'Hasta 5kg'),
  mediano('Mediano', '5-25kg'),
  grande('Grande', 'Más de 25kg');

  final String label;
  final String description;
  const AnimalSize(this.label, this.description);
}

// Categorías de productos
enum ProductCategory {
  alimentacion('Alimentación', Icons.restaurant),
  higiene('Higiene', Icons.clean_hands),
  salud('Salud', Icons.medication),
  accesorios('Accesorios', Icons.shopping_bag),
  juguetes('Juguetes', Icons.sports_esports);

  final String label;
  final IconData icon;
  const ProductCategory(this.label, this.icon);
}

// Edad del animal
enum AnimalAge {
  cachorro('Cachorro / Joven', '0-1 año'),
  adulto('Adulto', '1-7 años'),
  senior('Senior', '+7 años');

  final String label;
  final String ageRange;
  const AnimalAge(this.label, this.ageRange);
}

// Estados de pedido
enum OrderStatus {
  pendiente('Pendiente', Icons.hourglass_empty, 0xFFFFA726),
  pagado('Pagado', Icons.credit_card, 0xFF42A5F5),
  enviado('Enviado', Icons.local_shipping, 0xFF7E57C2),
  entregado('Entregado', Icons.check_circle, 0xFF66BB6A),
  cancelado('Cancelado', Icons.cancel, 0xFFEF5350);

  final String label;
  final IconData icon;
  final int colorValue;
  const OrderStatus(this.label, this.icon, this.colorValue);

  Color get color => Color(colorValue);
}
