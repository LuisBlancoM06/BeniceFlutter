import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/stock_service.dart';
import '../../data/models/models.dart';

/// Provider para el servicio de stock
final stockServiceProvider = Provider<StockService>((ref) {
  final supabase = Supabase.instance.client;
  return StockService(supabase);
});

/// Provider para el estado de stock en tiempo real
final stockProvider = NotifierProvider<StockNotifier, StockState>(StockNotifier.new);

/// Estado del stock
class StockState {
  final Map<String, int> productStocks;
  final Map<String, bool> stockAvailability;
  final bool isLoading;
  final String? error;

  StockState({
    this.productStocks = const {},
    this.stockAvailability = const {},
    this.isLoading = false,
    this.error,
  });

  StockState copyWith({
    Map<String, int>? productStocks,
    Map<String, bool>? stockAvailability,
    bool? isLoading,
    String? error,
  }) {
    return StockState(
      productStocks: productStocks ?? this.productStocks,
      stockAvailability: stockAvailability ?? this.stockAvailability,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado del stock
class StockNotifier extends Notifier<StockState> {
  @override
  StockState build() {
    return StockState();
  }

  /// Verifica stock para un producto específico
  Future<bool> checkProductStock(String productId, int quantity) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stockService = ref.read(stockServiceProvider);
      final isAvailable = await stockService.checkStockAvailability(productId, quantity);
      
      state = state.copyWith(
        isLoading: false,
        stockAvailability: {...state.stockAvailability, productId: isAvailable},
      );
      
      return isAvailable;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verifica stock para múltiples productos
  Future<Map<String, bool>> checkMultipleProductsStock(Map<String, int> productsQuantities) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stockService = ref.read(stockServiceProvider);
      final availability = await stockService.checkMultipleStockAvailability(productsQuantities);
      
      state = state.copyWith(
        isLoading: false,
        stockAvailability: {...state.stockAvailability, ...availability},
      );
      
      return availability;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return {};
    }
  }

  /// Obtiene stock actual de un producto
  Future<int> getProductStock(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stockService = ref.read(stockServiceProvider);
      final stock = await stockService.getProductStock(productId);
      
      state = state.copyWith(
        isLoading: false,
        productStocks: {...state.productStocks, productId: stock},
      );
      
      return stock;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return 0;
    }
  }

  /// Valida el carrito completo para checkout
  Future<bool> validateCartForCheckout(List<CartItemModel> cartItems) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stockService = ref.read(stockServiceProvider);
      final validation = await stockService.validateCartForCheckout(cartItems);
      
      if (!validation.isValid) {
        state = state.copyWith(
          isLoading: false,
          error: validation.message,
        );
        return false;
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresca el stock de múltiples productos
  Future<void> refreshStocks(List<String> productIds) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stockService = ref.read(stockServiceProvider);
      final Map<String, int> updatedStocks = {};
      
      for (final productId in productIds) {
        try {
          final stock = await stockService.getProductStock(productId);
          updatedStocks[productId] = stock;
        } catch (e) {
          // Continuar con otros productos si uno falla
          print('Error obteniendo stock de $productId: $e');
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        productStocks: {...state.productStocks, ...updatedStocks},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
