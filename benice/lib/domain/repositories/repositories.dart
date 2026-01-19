import '../../core/constants/app_constants.dart';
import '../../core/utils/typedef.dart';
import '../entities/entities.dart';

/// Repositorio de Autenticación
abstract class AuthRepository {
  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  });

  ResultFuture<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  });

  ResultVoid signOut();

  ResultFuture<UserEntity?> getCurrentUser();

  ResultVoid resetPassword({required String email});

  ResultVoid updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  ResultFuture<UserEntity> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  });

  ResultVoid subscribeToNewsletter({required String email});

  Stream<UserEntity?> get authStateChanges;
}

/// Repositorio de Productos
abstract class ProductRepository {
  ResultFuture<List<ProductEntity>> getProducts({
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  });

  ResultFuture<ProductEntity> getProductById(String id);

  ResultFuture<List<ProductEntity>> searchProducts(String query);

  ResultFuture<List<ProductEntity>> getFeaturedProducts();

  ResultFuture<List<ProductEntity>> getProductsByCategory(
    ProductCategory category,
  );

  ResultFuture<List<ProductEntity>> getProductsByAnimalType(AnimalType type);

  ResultFuture<List<ProductEntity>> getRelatedProducts(String productId);
}

/// Repositorio del Carrito
abstract class CartRepository {
  ResultFuture<CartEntity> getCart();

  ResultFuture<CartEntity> addToCart({
    required ProductEntity product,
    int quantity = 1,
  });

  ResultFuture<CartEntity> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  });

  ResultFuture<CartEntity> removeFromCart(String itemId);

  ResultFuture<CartEntity> clearCart();

  ResultFuture<CartEntity> applyDiscountCode(String code);

  ResultFuture<CartEntity> removeDiscountCode();

  ResultVoid saveCartLocally(CartEntity cart);

  ResultFuture<CartEntity?> getLocalCart();
}

/// Repositorio de Pedidos
abstract class OrderRepository {
  ResultFuture<List<OrderEntity>> getOrders();

  ResultFuture<OrderEntity> getOrderById(String id);

  ResultFuture<OrderEntity> createOrder({
    required CartEntity cart,
    required String shippingAddress,
  });

  ResultFuture<OrderEntity> cancelOrder(String orderId);

  ResultFuture<OrderEntity> requestReturn(String orderId);
}

/// Repositorio de Códigos de Descuento
abstract class DiscountRepository {
  ResultFuture<DiscountCodeEntity> validateDiscountCode(
    String code,
    double subtotal,
  );
}
