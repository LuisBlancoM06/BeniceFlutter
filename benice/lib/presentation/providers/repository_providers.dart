import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/supabase_data_source.dart';
import '../../data/repositories/repositories_impl.dart';
import '../../data/repositories/supabase_repositories_impl.dart';
import '../../domain/repositories/repositories.dart';

/// Provider de SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// Provider del cliente Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider del datasource Supabase
final supabaseDataSourceProvider = Provider<SupabaseDataSource>((ref) {
  return SupabaseDataSource(ref.watch(supabaseClientProvider));
});

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConstants.useMockData) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AuthRepositoryImpl(prefs);
  }
  return SupabaseAuthRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

/// Provider del repositorio de productos
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppConstants.useMockData) {
    return ProductRepositoryImpl();
  }
  return SupabaseProductRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

/// Provider del repositorio del carrito
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // El carrito siempre usa SharedPreferences (local)
  return CartRepositoryImpl(prefs);
});

/// Provider del repositorio de pedidos
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  if (AppConstants.useMockData) {
    return OrderRepositoryImpl();
  }
  return SupabaseOrderRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

/// Provider del repositorio de descuentos
final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  if (AppConstants.useMockData) {
    return DiscountRepositoryImpl();
  }
  return SupabaseDiscountRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

/// Provider del repositorio de reviews
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  if (AppConstants.useMockData) {
    // Reviews mock no existe aún como clase — usa Supabase si disponible
    return SupabaseReviewRepositoryImpl(ref.watch(supabaseDataSourceProvider));
  }
  return SupabaseReviewRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

/// Provider del repositorio de admin
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  if (AppConstants.useMockData) {
    // Admin mock no existe como clase — usa Supabase si disponible
    return SupabaseAdminRepositoryImpl(ref.watch(supabaseDataSourceProvider));
  }
  return SupabaseAdminRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});
