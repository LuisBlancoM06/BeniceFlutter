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
    String? phone,
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
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? avatarUrl,
  });

  /// Suscribe a newsletter y devuelve el código promo generado
  ResultFuture<String> subscribeToNewsletter({required String email});

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

  ResultFuture<List<ProductEntity>> getProductsByIds(List<String> ids);

  ResultFuture<List<ProductEntity>> getOfertasFlash();
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
    String? notes,
  });

  /// El cliente solicita cancelación (crea cancellation_request, NO cancela directamente)
  ResultFuture<CancellationRequestEntity> requestCancellation(
    String orderId, {
    required String reason,
  });

  ResultFuture<OrderEntity> requestReturn(String orderId, {String? reason});
}

/// Repositorio de Códigos de Descuento
abstract class DiscountRepository {
  ResultFuture<DiscountCodeEntity> validateDiscountCode(
    String code,
    double subtotal,
  );
}

/// Repositorio de Reviews
abstract class ReviewRepository {
  ResultFuture<List<ReviewEntity>> getProductReviews(String productId);

  ResultFuture<ReviewStats> getReviewStats(String productId);

  ResultFuture<ReviewEntity> createReview({
    required String productId,
    required int rating,
    String? comment,
  });

  ResultVoid deleteReview(String reviewId);

  ResultVoid voteHelpful(String reviewId);
}

/// Repositorio de Favoritos
abstract class FavoritesRepository {
  ResultFuture<List<String>> getFavoriteIds();

  ResultVoid toggleFavorite(String productId);

  ResultFuture<bool> isFavorite(String productId);
}

/// Repositorio de Admin
abstract class AdminRepository {
  // Productos
  ResultFuture<ProductEntity> createProduct(Map<String, dynamic> data);
  ResultFuture<ProductEntity> updateProduct(
    String id,
    Map<String, dynamic> data,
  );
  ResultVoid deleteProduct(String id);

  // Pedidos
  ResultFuture<List<OrderEntity>> getAllOrders({String? status});
  ResultVoid updateOrderStatus(String orderId, String status);

  // Dashboard
  ResultFuture<DashboardStats> getDashboardStats();

  // Newsletter
  ResultFuture<List<NewsletterSubscriber>> getNewsletterSubscribers();
  ResultVoid deleteNewsletterSubscriber(String email);

  // Facturas
  ResultFuture<List<InvoiceEntity>> getInvoices();

  // Devoluciones
  ResultFuture<List<ReturnEntity>> getReturns();
  ResultVoid updateReturnStatus(
    String returnId,
    String status, {
    String? adminNotes,
  });

  // Solicitudes de Cancelación
  ResultFuture<List<CancellationRequestEntity>> getCancellationRequests({
    String? status,
  });
  ResultVoid approveCancellation(
    String requestId,
    String orderId, {
    String? adminNotes,
  });
  ResultVoid rejectCancellation(String requestId, {String? adminNotes});

  // Promo Codes
  ResultFuture<List<DiscountCodeEntity>> getPromoCodes();
  ResultVoid createPromoCode(Map<String, dynamic> data);
  ResultVoid deletePromoCode(String code);

  // Site Settings
  ResultFuture<bool> getOfertasFlashActive();
  ResultVoid setOfertasFlashActive(bool active);

  // Users
  ResultFuture<List<UserEntity>> getAllUsers();
}
