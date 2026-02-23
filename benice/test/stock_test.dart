import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:benice/domain/services/stock_service.dart';
import 'package:benice/presentation/providers/stock_provider.dart';
import 'package:benice/data/models/models.dart';

import 'stock_test.mocks.dart';

@GenerateMocks([StockService])
void main() {
  group('StockProvider Tests', () {
    late ProviderContainer container;
    late MockStockService mockStockService;

    setUp(() {
      mockStockService = MockStockService();
      
      // Override del stock service provider
      container = ProviderContainer(
        overrides: [
          stockServiceProvider.overrideWithValue(mockStockService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('debe verificar stock de un producto correctamente', () async {
      // Arrange
      const productId = 'test-product-id';
      const quantity = 5;
      when(mockStockService.checkStockAvailability(productId, quantity))
          .thenAnswer((_) async => true);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.checkProductStock(productId, quantity);

      // Assert
      expect(result, isTrue);
      expect(container.read(stockProvider).stockAvailability[productId], isTrue);
      expect(container.read(stockProvider).isLoading, isFalse);
      verify(mockStockService.checkStockAvailability(productId, quantity)).called(1);
    });

    test('debe manejar error al verificar stock', () async {
      // Arrange
      const productId = 'test-product-id';
      const quantity = 5;
      when(mockStockService.checkStockAvailability(productId, quantity))
          .thenThrow(StockException('Error verificando stock'));

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.checkProductStock(productId, quantity);

      // Assert
      expect(result, isFalse);
      expect(container.read(stockProvider).error, isNotNull);
      expect(container.read(stockProvider).isLoading, isFalse);
    });

    test('debe verificar stock de múltiples productos', () async {
      // Arrange
      final productsQuantities = {
        'product-1': 2,
        'product-2': 3,
      };
      final availability = {
        'product-1': true,
        'product-2': false,
      };
      
      when(mockStockService.checkMultipleStockAvailability(productsQuantities))
          .thenAnswer((_) async => availability);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.checkMultipleProductsStock(productsQuantities);

      // Assert
      expect(result, equals(availability));
      expect(container.read(stockProvider).stockAvailability, equals(availability));
      verify(mockStockService.checkMultipleStockAvailability(productsQuantities)).called(1);
    });

    test('debe obtener stock actual de un producto', () async {
      // Arrange
      const productId = 'test-product-id';
      const stock = 15;
      when(mockStockService.getProductStock(productId))
          .thenAnswer((_) async => stock);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.getProductStock(productId);

      // Assert
      expect(result, equals(stock));
      expect(container.read(stockProvider).productStocks[productId], equals(stock));
      verify(mockStockService.getProductStock(productId)).called(1);
    });

    test('debe validar carrito para checkout', () async {
      // Arrange
      final cartItems = [
        CartItemModel(
          id: 'item-1',
          product: ProductModel(
            id: 'product-1',
            name: 'Test Product',
            description: 'Test Description',
            price: 10.0,
            images: [],
            animalType: AnimalType.perro,
            animalSize: AnimalSize.mediano,
            category: ProductCategory.alimentacion,
            animalAge: AnimalAge.adulto,
            stock: 10,
            createdAt: DateTime.now(),
          ),
          quantity: 2,
        ),
      ];
      
      final validation = CartStockValidation(
        isValid: true,
        unavailableProductIds: [],
        message: 'Carrito válido para checkout',
      );
      
      when(mockStockService.validateCartForCheckout(cartItems))
          .thenAnswer((_) async => validation);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.validateCartForCheckout(cartItems);

      // Assert
      expect(result, isTrue);
      expect(container.read(stockProvider).error, isNull);
      verify(mockStockService.validateCartForCheckout(cartItems)).called(1);
    });

    test('debe rechazar carrito con productos sin stock', () async {
      // Arrange
      final cartItems = [
        CartItemModel(
          id: 'item-1',
          product: ProductModel(
            id: 'product-1',
            name: 'Test Product',
            description: 'Test Description',
            price: 10.0,
            images: [],
            animalType: AnimalType.perro,
            animalSize: AnimalSize.mediano,
            category: ProductCategory.alimentacion,
            animalAge: AnimalAge.adulto,
            stock: 0, // Sin stock
            createdAt: DateTime.now(),
          ),
          quantity: 2,
        ),
      ];
      
      final validation = CartStockValidation(
        isValid: false,
        unavailableProductIds: ['product-1'],
        message: 'Hay productos sin stock suficiente',
      );
      
      when(mockStockService.validateCartForCheckout(cartItems))
          .thenAnswer((_) async => validation);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      final result = await stockNotifier.validateCartForCheckout(cartItems);

      // Assert
      expect(result, isFalse);
      expect(container.read(stockProvider).error, equals('Hay productos sin stock suficiente'));
      verify(mockStockService.validateCartForCheckout(cartItems)).called(1);
    });

    test('debe limpiar errores correctamente', () {
      // Arrange
      final stockNotifier = container.read(stockProvider.notifier);
      
      // Simular error previo
      stockNotifier.state = stockNotifier.state.copyWith(error: 'Error anterior');

      // Act
      stockNotifier.clearError();

      // Assert
      expect(container.read(stockProvider).error, isNull);
    });

    test('debe refrescar stocks de múltiples productos', () async {
      // Arrange
      final productIds = ['product-1', 'product-2'];
      
      when(mockStockService.getProductStock('product-1'))
          .thenAnswer((_) async => 10);
      when(mockStockService.getProductStock('product-2'))
          .thenAnswer((_) async => 5);

      // Act
      final stockNotifier = container.read(stockProvider.notifier);
      await stockNotifier.refreshStocks(productIds);

      // Assert
      expect(container.read(stockProvider).productStocks['product-1'], equals(10));
      expect(container.read(stockProvider).productStocks['product-2'], equals(5));
      expect(container.read(stockProvider).isLoading, isFalse);
      
      verify(mockStockService.getProductStock('product-1')).called(1);
      verify(mockStockService.getProductStock('product-2')).called(1);
    });
  });

  group('StockService Tests', () {
    late MockSupabaseClient mockSupabaseClient;
    late StockService stockService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      stockService = StockService(mockSupabaseClient);
    });

    test('debe lanzar StockException cuando hay error', () async {
      // Arrange
      const productId = 'test-product-id';
      const quantity = 5;
      
      when(mockSupabaseClient.from('products'))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => stockService.checkStockAvailability(productId, quantity),
        throwsA(isA<StockException>()),
      );
    });
  });
}

// Mock classes para testing
class MockSupabaseClient extends Mock implements SupabaseClient {}
