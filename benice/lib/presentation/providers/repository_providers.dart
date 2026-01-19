import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/repositories_impl.dart';
import '../../domain/repositories/repositories.dart';

/// Provider de SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(prefs);
});

/// Provider del repositorio de productos
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

/// Provider del repositorio del carrito
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CartRepositoryImpl(prefs);
});

/// Provider del repositorio de pedidos
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

/// Provider del repositorio de descuentos
final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  return DiscountRepositoryImpl();
});
