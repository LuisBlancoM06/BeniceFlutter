import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';

/// Servicio de gestión de stock con validación en tiempo real
/// Basado en las funciones de PostgreSQL de BeniceAstro
class StockService {
  final SupabaseClient _supabase;
  static const String _productsTable = 'products';

  StockService(this._supabase);

  /// Verifica si hay stock suficiente para un producto
  Future<bool> checkStockAvailability(String productId, int quantity) async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select('stock')
          .eq('id', productId)
          .single();

      final int availableStock = response['stock'] as int;
      return availableStock >= quantity;
    } catch (e) {
      throw StockException('Error verificando stock: $e');
    }
  }

  /// Verifica stock para múltiples productos (carrito completo)
  Future<Map<String, bool>> checkMultipleStockAvailability(
      Map<String, int> productsQuantities) async {
    final Map<String, bool> results = {};
    
    try {
      // Obtener todos los productos en una sola consulta
      final productIds = productsQuantities.keys.toList();
      final response = await _supabase
          .from(_productsTable)
          .select('id, stock')
          .inFilter('id', productIds);

      for (final product in response) {
        final productId = product['id'] as String;
        final availableStock = product['stock'] as int;
        final requestedQuantity = productsQuantities[productId] ?? 0;
        results[productId] = availableStock >= requestedQuantity;
      }

      return results;
    } catch (e) {
      throw StockException('Error verificando stock múltiple: $e');
    }
  }

  /// Reduce stock al crear un pedido (usando función atómica de PostgreSQL)
  Future<void> reduceStockForOrder(String orderId) async {
    try {
      // Usar la función atómica de PostgreSQL que ya verifica stock y reduce en una operación
      await _supabase.rpc('create_order_and_reduce_stock_flutter', params: {
        'p_user_id': _supabase.auth.currentUser?.id,
        'p_total': 0.0, // Este valor debería venir del pedido
        'p_items': [], // Estos datos deberían venir del pedido
      });
    } catch (e) {
      throw StockException('Error reduciendo stock: $e');
    }
  }

  /// Restaura stock al cancelar un pedido (usando función atómica de PostgreSQL)
  Future<void> restoreStockForOrder(String orderId) async {
    try {
      // Usar la función atómica de PostgreSQL que restaura stock y actualiza estado
      await _supabase.rpc('cancel_order_and_restore_stock_flutter', params: {
        'p_order_id': orderId,
      });
    } catch (e) {
      throw StockException('Error restaurando stock: $e');
    }
  }

  /// Obtiene productos con bajo stock
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select('*')
          .lt('stock', AppConstants.lowStockThreshold)
          .gt('stock', AppConstants.outOfStockThreshold)
          .order('stock', ascending: true);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw StockException('Error obteniendo productos con bajo stock: $e');
    }
  }

  /// Obtiene productos sin stock
  Future<List<ProductModel>> getOutOfStockProducts() async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select('*')
          .eq('stock', AppConstants.outOfStockThreshold)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw StockException('Error obteniendo productos sin stock: $e');
    }
  }

  /// Actualiza stock de un producto (solo para admin)
  Future<void> updateProductStock(String productId, int newStock) async {
    if (newStock < 0) {
      throw StockException('El stock no puede ser negativo');
    }

    try {
      await _supabase
          .from(_productsTable)
          .update({'stock': newStock})
          .eq('id', productId);
    } catch (e) {
      throw StockException('Error actualizando stock: $e');
    }
  }

  /// Obtiene el stock actual de un producto
  Future<int> getProductStock(String productId) async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select('stock')
          .eq('id', productId)
          .single();

      return response['stock'] as int;
    } catch (e) {
      throw StockException('Error obteniendo stock del producto: $e');
    }
  }

  /// Verifica si un carrito es válido para checkout
  Future<CartStockValidation> validateCartForCheckout(
      List<CartItemModel> cartItems) async {
    final Map<String, int> productsQuantities = {};
    final List<String> unavailableProducts = [];

    // Construir mapa de productos y cantidades
    for (final item in cartItems) {
      productsQuantities[item.product.id] = item.quantity;
    }

    // Verificar disponibilidad
    final stockResults = await checkMultipleStockAvailability(productsQuantities);

    for (final entry in stockResults.entries) {
      if (!entry.value) {
        unavailableProducts.add(entry.key);
      }
    }

    return CartStockValidation(
      isValid: unavailableProducts.isEmpty,
      unavailableProductIds: unavailableProducts,
      message: unavailableProducts.isEmpty
          ? 'Carrito válido para checkout'
          : 'Hay productos sin stock suficiente',
    );
  }
}

/// Resultado de validación de stock del carrito
class CartStockValidation {
  final bool isValid;
  final List<String> unavailableProductIds;
  final String message;

  CartStockValidation({
    required this.isValid,
    required this.unavailableProductIds,
    required this.message,
  });
}

/// Excepción personalizada para operaciones de stock
class StockException implements Exception {
  final String message;
  StockException(this.message);

  @override
  String toString() => 'StockException: $message';
}
