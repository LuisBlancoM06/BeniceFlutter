// Constantes de la aplicación BeniceAstro
import 'dart:ui';

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // App Info
  static const String appName = 'BeniceAstro';
  static const String appVersion = '1.0.0';
  static const String appTagline =
      'Todo lo que tu mascota necesita en un solo lugar';

  // Tiempos de debounce
  static const int searchDebounceMs = 500;

  // Paginación
  static const int productsPerPage = 20;

  // Carrito
  static const int maxQuantityPerProduct = 10;

  // Newsletter
  static const String newsletterPromoCode = 'BIENVENIDO10';
  static const int newsletterDiscountPercent = 10;

  // Envío
  static const double freeShippingMinAmount = 50.0;
  static const double shippingCost = 4.99;

  // Devoluciones
  static const String warehouseAddress =
      'Calle Mascotas, 123\n28001 Madrid, España';
  static const String returnDaysInfo = '5-7 días hábiles para el reembolso';
}

// Tipos de animales
enum AnimalType {
  perro('Perros', '🐕'),
  gato('Gatos', '🐈'),
  otro('Otros Animales', '🐹');

  final String label;
  final String emoji;
  const AnimalType(this.label, this.emoji);
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
  alimentacion('Alimentación', '🍖'),
  higiene('Higiene', '🧴'),
  salud('Salud', '💊'),
  accesorios('Accesorios', '🎀'),
  juguetes('Juguetes', '🎾');

  final String label;
  final String emoji;
  const ProductCategory(this.label, this.emoji);
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
  pendiente('Pendiente', '⏳', 0xFFFFA726),
  pagado('Pagado', '💳', 0xFF42A5F5),
  preparando('Preparando', '📋', 0xFF5C6BC0),
  enviado('Enviado', '📦', 0xFF7E57C2),
  entregado('Entregado', '✅', 0xFF66BB6A),
  cancelado('Cancelado', '❌', 0xFFEF5350);

  final String label;
  final String emoji;
  final int colorValue;
  const OrderStatus(this.label, this.emoji, this.colorValue);

  Color get color => Color(colorValue);
}
