import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/mock_data_source.dart';
import '../models/models.dart';

/// Implementación del repositorio de autenticación usando datos mock
class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  UserModel? _currentUser;

  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthRepositoryImpl(this._prefs);

  @override
  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Validación simple para demo
      if (password.length < 6) {
        return const Left(AuthFailure(message: 'Contraseña incorrecta'));
      }

      _currentUser = UserModel(
        id: const Uuid().v4(),
        email: email,
        name: email.split('@').first,
        createdAt: DateTime.now(),
      );

      await _prefs.setString(_userKey, email);
      await _prefs.setBool(_isLoggedInKey, true);

      return Right(_currentUser!);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (password.length < 6) {
        return const Left(
          ValidationFailure(
            message: 'La contraseña debe tener al menos 6 caracteres',
          ),
        );
      }

      _currentUser = UserModel(
        id: const Uuid().v4(),
        email: email,
        name: name ?? email.split('@').first,
        createdAt: DateTime.now(),
      );

      await _prefs.setString(_userKey, email);
      await _prefs.setBool(_isLoggedInKey, true);

      return Right(_currentUser!);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      await _prefs.remove(_userKey);
      await _prefs.setBool(_isLoggedInKey, false);
      _currentUser = null;
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) return const Right(null);

      final email = _prefs.getString(_userKey);
      if (email == null) return const Right(null);

      _currentUser = UserModel(
        id: const Uuid().v4(),
        email: email,
        name: email.split('@').first,
        createdAt: DateTime.now(),
      );

      return Right(_currentUser);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid resetPassword({required String email}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // Simula envío de email
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (newPassword.length < 6) {
        return const Left(
          ValidationFailure(
            message: 'La nueva contraseña debe tener al menos 6 caracteres',
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> updateProfile({
    String? name,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? avatarUrl,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentUser == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }

      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: name ?? _currentUser!.name,
        fullName: fullName ?? _currentUser!.fullName,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
        city: city ?? _currentUser!.city,
        postalCode: postalCode ?? _currentUser!.postalCode,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        isSubscribedNewsletter: _currentUser!.isSubscribedNewsletter,
        createdAt: _currentUser!.createdAt,
      );

      return Right(_currentUser!);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid subscribeToNewsletter({required String email}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          address: _currentUser!.address,
          avatarUrl: _currentUser!.avatarUrl,
          isSubscribedNewsletter: true,
          createdAt: _currentUser!.createdAt,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return Stream.value(_currentUser);
  }
}

/// Implementación del repositorio de productos usando datos mock
class ProductRepositoryImpl implements ProductRepository {
  final List<ProductModel> _products = MockDataSource.getMockProducts();

  @override
  ResultFuture<List<ProductEntity>> getProducts({
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      var result = _products.toList();

      if (filters != null) {
        if (filters.animalType != null) {
          result = result
              .where((p) => p.animalType == filters.animalType)
              .toList();
        }
        if (filters.animalSize != null) {
          result = result
              .where((p) => p.animalSize == filters.animalSize)
              .toList();
        }
        if (filters.category != null) {
          result = result.where((p) => p.category == filters.category).toList();
        }
        if (filters.animalAge != null) {
          result = result
              .where((p) => p.animalAge == filters.animalAge)
              .toList();
        }
        if (filters.searchQuery?.isNotEmpty ?? false) {
          final query = filters.searchQuery!.toLowerCase();
          result = result
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.description.toLowerCase().contains(query) ||
                    p.brand?.toLowerCase().contains(query) == true,
              )
              .toList();
        }
        if (filters.onlyWithDiscount == true) {
          result = result.where((p) => p.hasDiscount).toList();
        }
        if (filters.onlyInStock == true) {
          result = result.where((p) => p.inStock).toList();
        }
      }

      // Paginación
      final start = (page - 1) * limit;
      final end = start + limit;
      if (start < result.length) {
        result = result.sublist(
          start,
          end > result.length ? result.length : end,
        );
      } else {
        result = [];
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<ProductEntity> getProductById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final product = _products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Producto no encontrado'),
      );

      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> searchProducts(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (query.isEmpty) return const Right([]);

      final lowerQuery = query.toLowerCase();
      final results = _products
          .where(
            (p) =>
                p.name.toLowerCase().contains(lowerQuery) ||
                p.description.toLowerCase().contains(lowerQuery) ||
                p.brand?.toLowerCase().contains(lowerQuery) == true ||
                p.category.label.toLowerCase().contains(lowerQuery) ||
                p.animalType.label.toLowerCase().contains(lowerQuery),
          )
          .toList();

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getFeaturedProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final featured = _products.where((p) => p.isFeatured).toList();
      return Right(featured);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByCategory(
    ProductCategory category,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final products = _products.where((p) => p.category == category).toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByAnimalType(
    AnimalType type,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final products = _products.where((p) => p.animalType == type).toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getRelatedProducts(String productId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final product = _products.firstWhere((p) => p.id == productId);
      final related = _products
          .where(
            (p) =>
                p.id != productId &&
                (p.category == product.category ||
                    p.animalType == product.animalType),
          )
          .take(4)
          .toList();

      return Right(related);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getOfertasFlash() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final ofertas = _products.where((p) => p.hasDiscount).toList();
      return Right(ofertas);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByIds(List<String> ids) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final products = _products.where((p) => ids.contains(p.id)).toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

/// Implementación del repositorio de carrito
class CartRepositoryImpl implements CartRepository {
  final SharedPreferences _prefs;
  CartModel _cart = const CartModel();

  static const String _cartKey = 'cart_data';

  CartRepositoryImpl(this._prefs) {
    _loadCart();
  }

  void _loadCart() {
    final cartJson = _prefs.getString(_cartKey);
    if (cartJson != null) {
      try {
        _cart = CartModel.fromJsonString(cartJson);
      } catch (_) {
        _cart = const CartModel();
      }
    }
  }

  Future<void> _saveCart() async {
    await _prefs.setString(_cartKey, _cart.toJsonString());
  }

  @override
  ResultFuture<CartEntity> getCart() async {
    return Right(_cart);
  }

  @override
  ResultFuture<CartEntity> addToCart({
    required ProductEntity product,
    int quantity = 1,
  }) async {
    try {
      final existingIndex = _cart.items.indexWhere(
        (item) => item.product.id == product.id,
      );

      List<CartItemEntity> newItems;

      if (existingIndex >= 0) {
        final existingItem = _cart.items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        newItems = List.from(_cart.items);
        newItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        final newItem = CartItemEntity(
          id: const Uuid().v4(),
          product: product,
          quantity: quantity,
        );
        newItems = [..._cart.items, newItem];
      }

      _cart = CartModel(
        items: newItems,
        discountCode: _cart.discountCode,
        discountPercent: _cart.discountPercent,
      );
      await _saveCart();

      return Right(_cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(itemId);
      }

      final newItems = _cart.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList();

      _cart = CartModel(
        items: newItems,
        discountCode: _cart.discountCode,
        discountPercent: _cart.discountPercent,
      );
      await _saveCart();

      return Right(_cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity> removeFromCart(String itemId) async {
    try {
      final newItems = _cart.items.where((item) => item.id != itemId).toList();
      _cart = CartModel(
        items: newItems,
        discountCode: _cart.discountCode,
        discountPercent: _cart.discountPercent,
      );
      await _saveCart();

      return Right(_cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity> clearCart() async {
    try {
      _cart = const CartModel();
      await _prefs.remove(_cartKey);
      return Right(_cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity> applyDiscountCode(String code) async {
    try {
      final discounts = MockDataSource.getMockDiscountCodes();
      final discount = discounts.firstWhere(
        (d) => d.code.toUpperCase() == code.toUpperCase() && d.isValid,
        orElse: () => throw Exception('Código de descuento inválido'),
      );

      _cart = CartModel(
        items: _cart.items,
        discountCode: discount.code,
        discountPercent: discount.discountPercent,
      );
      await _saveCart();

      return Right(_cart);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity> removeDiscountCode() async {
    try {
      _cart = CartModel(items: _cart.items);
      await _saveCart();
      return Right(_cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid saveCartLocally(CartEntity cart) async {
    try {
      _cart = CartModel.fromEntity(cart);
      await _saveCart();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<CartEntity?> getLocalCart() async {
    try {
      return Right(_cart.isEmpty ? null : _cart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

/// Implementación del repositorio de pedidos
class OrderRepositoryImpl implements OrderRepository {
  List<OrderModel> _orders = [];

  OrderRepositoryImpl() {
    _orders = MockDataSource.getMockOrders('user-001');
  }

  @override
  ResultFuture<List<OrderEntity>> getOrders() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Right(_orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<OrderEntity> getOrderById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final order = _orders.firstWhere(
        (o) => o.id == id,
        orElse: () => throw Exception('Pedido no encontrado'),
      );

      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<OrderEntity> createOrder({
    required CartEntity cart,
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final orderItems = cart.items
          .map((item) => OrderItemModel.fromCartItem(item))
          .toList();

      final orderId = const Uuid().v4().substring(0, 8);
      final orderNumber = 'ORD-${orderId.toUpperCase()}';

      final order = OrderModel(
        id: 'order-$orderId',
        orderNumber: orderNumber,
        userId: 'user-001',
        items: orderItems,
        subtotal: cart.subtotal,
        discount: cart.discount,
        shippingCost: cart.shippingCost,
        total: cart.total,
        discountCode: cart.discountCode,
        status: OrderStatus.pagado,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
      );

      _orders.insert(0, order);

      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<OrderEntity> cancelOrder(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index < 0) {
        return const Left(ServerFailure(message: 'Pedido no encontrado'));
      }

      final order = _orders[index];
      if (!order.canCancel) {
        return const Left(
          ValidationFailure(message: 'Este pedido no puede ser cancelado'),
        );
      }

      final cancelledOrder = OrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        userId: order.userId,
        items: order.items.map((e) => e as OrderItemModel).toList(),
        subtotal: order.subtotal,
        discount: order.discount,
        shippingCost: order.shippingCost,
        total: order.total,
        discountCode: order.discountCode,
        status: OrderStatus.cancelado,
        shippingAddress: order.shippingAddress,
        trackingNumber: order.trackingNumber,
        notes: order.notes,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      _orders[index] = cancelledOrder;

      return Right(cancelledOrder);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<OrderEntity> requestReturn(
    String orderId, {
    String? reason,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final order = _orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Pedido no encontrado'),
      );

      if (!order.canRequestReturn) {
        return const Left(
          ValidationFailure(message: 'Este pedido no puede ser devuelto'),
        );
      }

      // En una implementación real, aquí se crearía una solicitud de devolución
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

/// Implementación del repositorio de descuentos
class DiscountRepositoryImpl implements DiscountRepository {
  @override
  ResultFuture<DiscountCodeEntity> validateDiscountCode(
    String code,
    double subtotal,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final discounts = MockDataSource.getMockDiscountCodes();
      final discount = discounts.firstWhere(
        (d) => d.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Código no encontrado'),
      );

      if (!discount.isValid) {
        return const Left(
          ValidationFailure(message: 'Código expirado o inactivo'),
        );
      }

      return Right(discount);
    } catch (e) {
      return Left(ValidationFailure(message: 'Código de descuento inválido'));
    }
  }
}
