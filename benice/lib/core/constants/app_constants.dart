// Constantes de la aplicación Venice Pet Shop
import 'package:flutter/material.dart';

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Stripe Configuration (publishable key - safe for client)
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  // Data Source Mode: set to false to use live Supabase data
  static const bool useMockData = false;

  // App Info
  static const String appName = 'Venice Pet Shop';
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
  static const double freeShippingMinAmount = 49.0;
  static const double shippingCost = 4.99;

  // Devoluciones
  static const String warehouseAddress =
      'Calle Mascotas, 123\n28001 Madrid, España';
  static const String returnDaysInfo = '5-7 días hábiles para el reembolso';
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
