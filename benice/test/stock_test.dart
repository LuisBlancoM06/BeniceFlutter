import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:benice/domain/services/stock_service.dart';
import 'package:benice/presentation/providers/stock_provider.dart';
import 'package:benice/data/models/models.dart';
import 'package:benice/core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Manual null-safe mock for StockService.
//
// Mockito 5.x with null safety requires that every method returning a
// non-nullable type delegates to `super.noSuchMethod` with a `returnValue`.
// This is exactly what @GenerateMocks produces — here we write it by hand
// so the test file is self-contained (no build_runner required).
// ---------------------------------------------------------------------------
class MockStockService extends Mock implements StockService {
  @override
  Future<bool> checkStockAvailability(String productId, int quantity) =>
      super.noSuchMethod(
        Invocation.method(#checkStockAvailability, [productId, quantity]),
        returnValue: Future<bool>.value(false),
      ) as Future<bool>;

  @override
  Future<Map<String, bool>> checkMultipleStockAvailability(
    Map<String, int> productsQuantities,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #checkMultipleStockAvailability,
          [productsQuantities],
        ),
        returnValue: Future<Map<String, bool>>.value(<String, bool>{}),
      ) as Future<Map<String, bool>>;

  @override
  Future<int> getProductStock(String productId) =>
      super.noSuchMethod(
        Invocation.method(#getProductStock, [productId]),
        returnValue: Future<int>.value(0),
      ) as Future<int>;

  @override
  Future<CartStockValidation> validateCartForCheckout(
    List<CartItemModel> cartItems,
  ) =>
      super.noSuchMethod(
        Invocation.method(#validateCartForCheckout, [cartItems]),
        returnValue: Future<CartStockValidation>.value(
          CartStockValidation(
            isValid: false,
            unavailableProductIds: [],
            message: '',
          ),
        ),
      ) as Future<CartStockValidation>;

  @override
  Future<void> reduceStockForOrder(String orderId) =>
      super.noSuchMethod(
        Invocation.method(#reduceStockForOrder, [orderId]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> restoreStockForOrder(String orderId) =>
      super.noSuchMethod(
        Invocation.method(#restoreStockForOrder, [orderId]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<ProductModel>> getLowStockProducts() =>
      super.noSuchMethod(
        Invocation.method(#getLowStockProducts, []),
        returnValue: Future<List<ProductModel>>.value(<ProductModel>[]),
      ) as Future<List<ProductModel>>;

  @override
  Future<List<ProductModel>> getOutOfStockProducts() =>
      super.noSuchMethod(
        Invocation.method(#getOutOfStockProducts, []),
        returnValue: Future<List<ProductModel>>.value(<ProductModel>[]),
      ) as Future<List<ProductModel>>;

  @override
  Future<void> updateProductStock(String productId, int newStock) =>
      super.noSuchMethod(
        Invocation.method(#updateProductStock, [productId, newStock]),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
/// Deterministic date — avoids flaky equality in Equatable props.
final _fixedDate = DateTime(2026, 1, 1);

ProductModel _buildProduct({
  String id = 'product-1',
  String name = 'Test Product',
  double price = 10.0,
  int stock = 10,
}) {
  return ProductModel(
    id: id,
    name: name,
    description: 'Test Description',
    price: price,
    images: const [],
    animalType: AnimalType.perro,
    animalSize: AnimalSize.mediano,
    category: ProductCategory.alimentacion,
    animalAge: AnimalAge.adulto,
    stock: stock,
    createdAt: _fixedDate,
  );
}

CartItemModel _buildCartItem({
  String itemId = 'item-1',
  String productId = 'product-1',
  String productName = 'Test Product',
  int stock = 10,
  int quantity = 2,
}) {
  return CartItemModel(
    id: itemId,
    product: _buildProduct(id: productId, name: productName, stock: stock),
    quantity: quantity,
  );
}

// ===========================================================================
// Tests
// ===========================================================================
void main() {
  // -------------------------------------------------------------------------
  // StockProvider — Notifier behaviour with mocked StockService
  // -------------------------------------------------------------------------
  group('StockProvider', () {
    late ProviderContainer container;
    late MockStockService mockStockService;

    setUp(() {
      mockStockService = MockStockService();
      container = ProviderContainer(
        overrides: [stockServiceProvider.overrideWithValue(mockStockService)],
      );
    });

    tearDown(() => container.dispose());

    // -- checkProductStock ---------------------------------------------------

    test('checkProductStock: true when stock is sufficient', () async {
      const productId = 'test-product-id';
      const quantity = 5;
      when(
        mockStockService.checkStockAvailability(productId, quantity),
      ).thenAnswer((_) async => true);

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.checkProductStock(productId, quantity);

      expect(result, isTrue);
      expect(
        container.read(stockProvider).stockAvailability[productId],
        isTrue,
      );
      expect(container.read(stockProvider).isLoading, isFalse);
      verify(
        mockStockService.checkStockAvailability(productId, quantity),
      ).called(1);
    });

    test('checkProductStock: false when stock is insufficient', () async {
      const productId = 'test-product-id';
      const quantity = 100;
      when(
        mockStockService.checkStockAvailability(productId, quantity),
      ).thenAnswer((_) async => false);

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.checkProductStock(productId, quantity);

      expect(result, isFalse);
      expect(
        container.read(stockProvider).stockAvailability[productId],
        isFalse,
      );
      expect(container.read(stockProvider).error, isNull);
    });

    test(
      'checkProductStock: returns false and sets error on exception',
      () async {
        const productId = 'test-product-id';
        const quantity = 5;
        when(
          mockStockService.checkStockAvailability(productId, quantity),
        ).thenThrow(StockException('Error verificando stock'));

        final notifier = container.read(stockProvider.notifier);
        final result = await notifier.checkProductStock(productId, quantity);

        expect(result, isFalse);
        expect(container.read(stockProvider).error, isNotNull);
        expect(container.read(stockProvider).isLoading, isFalse);
      },
    );

    // -- checkMultipleProductsStock ------------------------------------------

    test('checkMultipleProductsStock: returns availability map', () async {
      final productsQuantities = {'product-1': 2, 'product-2': 3};
      final availability = {'product-1': true, 'product-2': false};

      when(
        mockStockService.checkMultipleStockAvailability(productsQuantities),
      ).thenAnswer((_) async => availability);

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.checkMultipleProductsStock(
        productsQuantities,
      );

      expect(result, equals(availability));
      expect(
        container.read(stockProvider).stockAvailability,
        equals(availability),
      );
      verify(
        mockStockService.checkMultipleStockAvailability(productsQuantities),
      ).called(1);
    });

    test(
      'checkMultipleProductsStock: returns empty map on exception',
      () async {
        final productsQuantities = {'product-1': 2};
        when(
          mockStockService.checkMultipleStockAvailability(productsQuantities),
        ).thenThrow(StockException('DB error'));

        final notifier = container.read(stockProvider.notifier);
        final result = await notifier.checkMultipleProductsStock(
          productsQuantities,
        );

        expect(result, isEmpty);
        expect(container.read(stockProvider).error, isNotNull);
        expect(container.read(stockProvider).isLoading, isFalse);
      },
    );

    // -- getProductStock -----------------------------------------------------

    test('getProductStock: returns stock count and updates state', () async {
      const productId = 'test-product-id';
      const stock = 15;
      when(
        mockStockService.getProductStock(productId),
      ).thenAnswer((_) async => stock);

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.getProductStock(productId);

      expect(result, equals(stock));
      expect(
        container.read(stockProvider).productStocks[productId],
        equals(stock),
      );
      verify(mockStockService.getProductStock(productId)).called(1);
    });

    test('getProductStock: returns 0 and sets error on exception', () async {
      const productId = 'test-product-id';
      when(
        mockStockService.getProductStock(productId),
      ).thenThrow(StockException('Not found'));

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.getProductStock(productId);

      expect(result, equals(0));
      expect(container.read(stockProvider).error, isNotNull);
      expect(container.read(stockProvider).isLoading, isFalse);
    });

    // -- validateCartForCheckout ---------------------------------------------

    test('validateCartForCheckout: true when all items available', () async {
      final cartItems = [_buildCartItem(stock: 10, quantity: 2)];
      final validation = CartStockValidation(
        isValid: true,
        unavailableProductIds: [],
        message: 'Carrito válido para checkout',
      );

      when(
        mockStockService.validateCartForCheckout(cartItems),
      ).thenAnswer((_) async => validation);

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.validateCartForCheckout(cartItems);

      expect(result, isTrue);
      expect(container.read(stockProvider).error, isNull);
      verify(mockStockService.validateCartForCheckout(cartItems)).called(1);
    });

    test(
      'validateCartForCheckout: false and sets message when out of stock',
      () async {
        final cartItems = [_buildCartItem(stock: 0, quantity: 2)];
        final validation = CartStockValidation(
          isValid: false,
          unavailableProductIds: ['product-1'],
          message: 'Hay productos sin stock suficiente',
        );

        when(
          mockStockService.validateCartForCheckout(cartItems),
        ).thenAnswer((_) async => validation);

        final notifier = container.read(stockProvider.notifier);
        final result = await notifier.validateCartForCheckout(cartItems);

        expect(result, isFalse);
        expect(
          container.read(stockProvider).error,
          equals('Hay productos sin stock suficiente'),
        );
        verify(mockStockService.validateCartForCheckout(cartItems)).called(1);
      },
    );

    test('validateCartForCheckout: false on exception', () async {
      final cartItems = [_buildCartItem()];
      when(
        mockStockService.validateCartForCheckout(cartItems),
      ).thenThrow(StockException('Network error'));

      final notifier = container.read(stockProvider.notifier);
      final result = await notifier.validateCartForCheckout(cartItems);

      expect(result, isFalse);
      expect(container.read(stockProvider).error, contains('StockException'));
      expect(container.read(stockProvider).isLoading, isFalse);
    });

    // -- clearError ----------------------------------------------------------

    test('clearError: resets error to null', () {
      final notifier = container.read(stockProvider.notifier);
      notifier.state = notifier.state.copyWith(error: 'Error anterior');
      expect(container.read(stockProvider).error, isNotNull);

      notifier.clearError();

      expect(container.read(stockProvider).error, isNull);
    });

    // -- refreshStocks -------------------------------------------------------

    test('refreshStocks: updates stocks for all products', () async {
      when(
        mockStockService.getProductStock('product-1'),
      ).thenAnswer((_) async => 10);
      when(
        mockStockService.getProductStock('product-2'),
      ).thenAnswer((_) async => 5);

      final notifier = container.read(stockProvider.notifier);
      await notifier.refreshStocks(['product-1', 'product-2']);

      final state = container.read(stockProvider);
      expect(state.productStocks['product-1'], equals(10));
      expect(state.productStocks['product-2'], equals(5));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      verify(mockStockService.getProductStock('product-1')).called(1);
      verify(mockStockService.getProductStock('product-2')).called(1);
    });

    test(
      'refreshStocks: continues when one product fails (partial failure)',
      () async {
        when(
          mockStockService.getProductStock('product-1'),
        ).thenThrow(StockException('Error for product-1'));
        when(
          mockStockService.getProductStock('product-2'),
        ).thenAnswer((_) async => 5);

        final notifier = container.read(stockProvider.notifier);
        await notifier.refreshStocks(['product-1', 'product-2']);

        final state = container.read(stockProvider);
        // product-1 failed → not present in the map
        expect(state.productStocks.containsKey('product-1'), isFalse);
        // product-2 succeeded
        expect(state.productStocks['product-2'], equals(5));
        expect(state.isLoading, isFalse);
        // No global error — individual failures are silently logged
        expect(state.error, isNull);
      },
    );

    test('refreshStocks: merges with existing stocks', () async {
      // Pre-populate existing stock
      when(
        mockStockService.getProductStock('product-1'),
      ).thenAnswer((_) async => 10);
      final notifier = container.read(stockProvider.notifier);
      await notifier.getProductStock('product-1');

      // Now refresh product-2 only
      when(
        mockStockService.getProductStock('product-2'),
      ).thenAnswer((_) async => 3);
      await notifier.refreshStocks(['product-2']);

      final state = container.read(stockProvider);
      expect(state.productStocks['product-1'], equals(10)); // preserved
      expect(state.productStocks['product-2'], equals(3)); // added
    });

    test('refreshStocks: with empty list does not call service', () async {
      final notifier = container.read(stockProvider.notifier);
      await notifier.refreshStocks([]);

      final state = container.read(stockProvider);
      expect(state.isLoading, isFalse);
      expect(state.productStocks, isEmpty);
      verifyZeroInteractions(mockStockService);
    });
  });

  // -------------------------------------------------------------------------
  // StockState — pure unit tests (no provider/mock required)
  // -------------------------------------------------------------------------
  group('StockState', () {
    test('initial state has correct defaults', () {
      final state = StockState();

      expect(state.productStocks, isEmpty);
      expect(state.stockAvailability, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith preserves unmodified values', () {
      final state = StockState(
        productStocks: {'p1': 10},
        stockAvailability: {'p1': true},
        isLoading: false,
        error: null,
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.productStocks, equals({'p1': 10}));
      expect(updated.stockAvailability, equals({'p1': true}));
      expect(updated.isLoading, isTrue);
    });

    test('copyWith always resets error to null when not passed', () {
      // This documents the intentional reset-by-default behaviour
      // in StockState.copyWith — error is cleared unless explicitly
      // provided. This prevents stale errors from persisting across
      // state transitions.
      final state = StockState(error: 'Error anterior');
      final updated = state.copyWith(isLoading: true);

      expect(updated.error, isNull);
    });

    test('copyWith preserves error when passed explicitly', () {
      final state = StockState(error: 'Error original');
      final updated = state.copyWith(error: 'Error nuevo');

      expect(updated.error, equals('Error nuevo'));
    });
  });

  // -------------------------------------------------------------------------
  // CartStockValidation — pure unit tests
  // -------------------------------------------------------------------------
  group('CartStockValidation', () {
    test('valid when unavailableProductIds is empty', () {
      final validation = CartStockValidation(
        isValid: true,
        unavailableProductIds: [],
        message: 'Carrito válido',
      );

      expect(validation.isValid, isTrue);
      expect(validation.unavailableProductIds, isEmpty);
    });

    test('invalid when products are unavailable', () {
      final validation = CartStockValidation(
        isValid: false,
        unavailableProductIds: ['p1', 'p2'],
        message: 'Stock insuficiente',
      );

      expect(validation.isValid, isFalse);
      expect(validation.unavailableProductIds, hasLength(2));
      expect(validation.unavailableProductIds, contains('p1'));
    });
  });

  // -------------------------------------------------------------------------
  // StockException — pure unit tests
  // -------------------------------------------------------------------------
  group('StockException', () {
    test('toString includes message', () {
      final exception = StockException('Stock agotado');

      expect(exception.toString(), equals('StockException: Stock agotado'));
      expect(exception.message, equals('Stock agotado'));
    });

    test('implements Exception interface', () {
      expect(StockException('test'), isA<Exception>());
    });
  });
}