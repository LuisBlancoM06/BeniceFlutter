import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benice/core/constants/app_constants.dart';
import 'package:benice/data/models/models.dart';
import 'package:benice/presentation/providers/cart_provider.dart';

void main() {
  group('Cart Stock Validation Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('debe validar producto con stock suficiente', () {
      // Arrange
      final product = ProductModel(
        id: 'product-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 10, // Stock suficiente
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act
      cartNotifier.addToCart(product, quantity: 5);

      // Assert
      expect(container.read(cartProvider).cart.items.length, equals(1));
      expect(container.read(cartProvider).discountError, isNull);
    });

    test('debe rechazar producto sin stock', () {
      // Arrange
      final product = ProductModel(
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
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act
      cartNotifier.addToCart(product, quantity: 1);

      // Assert
      expect(container.read(cartProvider).cart.items.length, equals(0));
      expect(container.read(cartProvider).discountError, contains('No hay stock suficiente'));
    });

    test('debe rechazar cantidad mayor al stock disponible', () {
      // Arrange
      final product = ProductModel(
        id: 'product-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 3, // Solo 3 unidades disponibles
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act
      cartNotifier.addToCart(product, quantity: 5); // Intentar agregar 5

      // Assert
      expect(container.read(cartProvider).cart.items.length, equals(0));
      expect(container.read(cartProvider).discountError, contains('Stock disponible: 3'));
    });

    test('debe rechazar actualización que excede el stock', () {
      // Arrange
      final product = ProductModel(
        id: 'product-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 5,
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act - Agregar cantidad válida primero
      cartNotifier.addToCart(product, quantity: 2);
      expect(container.read(cartProvider).cart.items.length, equals(1));

      // Intentar actualizar a cantidad que excede stock
      cartNotifier.updateQuantity(product.id, 10);

      // Assert
      expect(container.read(cartProvider).cart.items.first.quantity, equals(2)); // No cambia
      expect(container.read(cartProvider).discountError, contains('Stock disponible: 5'));
    });

    test('debe validar carrito completo para checkout', () async {
      // Arrange
      final product1 = ProductModel(
        id: 'product-1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 5,
        createdAt: DateTime.now(),
      );

      final product2 = ProductModel(
        id: 'product-2',
        name: 'Product 2',
        description: 'Description 2',
        price: 20.0,
        images: [],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mini,
        category: ProductCategory.higiene,
        animalAge: AnimalAge.cachorro,
        stock: 3,
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act - Agregar productos con stock válido
      cartNotifier.addToCart(product1, quantity: 2);
      cartNotifier.addToCart(product2, quantity: 1);

      // Validar para checkout
      final isValid = await cartNotifier.validateCartForCheckout();

      // Assert
      expect(isValid, isTrue);
      expect(container.read(cartProvider).discountError, isNull);
    });

    test('debe rechazar checkout con carrito vacío', () async {
      // Arrange
      final cartNotifier = container.read(cartProvider.notifier);

      // Act
      final isValid = await cartNotifier.validateCartForCheckout();

      // Assert
      expect(isValid, isFalse);
      expect(container.read(cartProvider).discountError, equals('El carrito está vacío'));
    });

    test('debe rechazar checkout con producto agotado', () async {
      // Arrange
      final product = ProductModel(
        id: 'product-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 5,
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Agregar producto al carrito
      cartNotifier.addToCart(product, quantity: 2);

      // Simular que el producto se agotó (modificando el stock)
      // En una app real, esto vendría de una actualización de la BD
      final cartItem = container.read(cartProvider).cart.items.first;
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        animalType: product.animalType,
        animalSize: product.animalSize,
        category: product.category,
        animalAge: product.animalAge,
        stock: 0, // Producto agotado
        createdAt: product.createdAt,
      );

      // Actualizar el carrito con el producto agotado
      final updatedItem = CartItemModel(
        id: cartItem.id,
        product: updatedProduct,
        quantity: cartItem.quantity,
      );

      // Forzar el estado del carrito manualmente para simular la actualización
      final currentCartState = container.read(cartProvider);
      container.read(cartProvider.notifier).state = currentCartState.copyWith(
        cart: currentCartState.cart.copyWith(
          items: [updatedItem],
        ),
      );

      // Act
      final isValid = await cartNotifier.validateCartForCheckout();

      // Assert
      expect(isValid, isFalse);
      expect(container.read(cartProvider).discountError, contains('está agotado'));
    });

    test('debe limpiar errores al agregar producto válido', () {
      // Arrange
      final productWithoutStock = ProductModel(
        id: 'product-1',
        name: 'No Stock Product',
        description: 'No stock',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 0,
        createdAt: DateTime.now(),
      );

      final productWithStock = ProductModel(
        id: 'product-2',
        name: 'Stock Product',
        description: 'Has stock',
        price: 20.0,
        images: [],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mini,
        category: ProductCategory.higiene,
        animalAge: AnimalAge.cachorro,
        stock: 10,
        createdAt: DateTime.now(),
      );

      final cartNotifier = container.read(cartProvider.notifier);

      // Act - Intentar agregar producto sin stock (genera error)
      cartNotifier.addToCart(productWithoutStock, quantity: 1);
      expect(container.read(cartProvider).discountError, isNotNull);

      // Agregar producto válido (debe limpiar el error)
      cartNotifier.addToCart(productWithStock, quantity: 2);

      // Assert
      expect(container.read(cartProvider).cart.items.length, equals(1));
      expect(container.read(cartProvider).discountError, isNull); // Error limpiado
    });
  });

  group('Stock Constants Tests', () {
    test('debe tener configuradas las constantes de stock', () {
      expect(AppConstants.lowStockThreshold, equals(10));
      expect(AppConstants.outOfStockThreshold, equals(0));
      expect(AppConstants.maxQuantityPerProduct, equals(10));
    });
  });

  group('Product Stock Logic Tests', () {
    test('debe calcular correctamente el estado de stock', () {
      // Arrange
      final productInStock = ProductModel(
        id: 'product-1',
        name: 'In Stock',
        description: 'Has stock',
        price: 10.0,
        images: [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 5,
        createdAt: DateTime.now(),
      );

      final productOutOfStock = ProductModel(
        id: 'product-2',
        name: 'Out of Stock',
        description: 'No stock',
        price: 20.0,
        images: [],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mini,
        category: ProductCategory.higiene,
        animalAge: AnimalAge.cachorro,
        stock: 0,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(productInStock.inStock, isTrue);
      expect(productOutOfStock.inStock, isFalse);
    });
  });
}
