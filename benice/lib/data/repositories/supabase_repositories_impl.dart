import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/supabase_data_source.dart';

/// Implementación del repositorio de autenticación con Supabase
class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _ds;

  SupabaseAuthRepositoryImpl(this._ds);

  @override
  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _ds.signIn(email, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
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
      final user = await _ds.signUp(email, password, name: name, phone: phone);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      await _ds.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final user = await _ds.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
    }
  }

  @override
  ResultVoid resetPassword({required String email}) async {
    try {
      await _ds.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
    }
  }

  @override
  ResultVoid updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Verify current password by attempting a sign-in first.
      // Supabase's updateUser does not verify the old password on its own.
      final email = _ds.client.auth.currentUser?.email;
      if (email == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }
      await _ds.signIn(email, currentPassword);

      await _ds.updatePassword(newPassword);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
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
      final currentUser = _ds.client.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }

      final data = <String, dynamic>{};
      if (name != null) data['full_name'] = name;
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (postalCode != null) data['postal_code'] = postalCode;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final updated = await _ds.updateProfile(currentUser.id, data);
      return Right(updated);
    } catch (e) {
      return Left(AuthFailure(message: _parseError(e)));
    }
  }

  @override
  ResultVoid subscribeToNewsletter({required String email}) async {
    try {
      await _ds.subscribeNewsletter(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _ds.authStateChanges.asyncMap((authState) async {
      if (authState.session?.user != null) {
        try {
          return await _ds.getCurrentUser();
        } catch (_) {
          return null;
        }
      }
      return null;
    });
  }

  String _parseError(dynamic e) {
    if (e is AuthException) return e.message;
    if (e is PostgrestException) return e.message;
    return e.toString();
  }
}

/// Implementación del repositorio de productos con Supabase
class SupabaseProductRepositoryImpl implements ProductRepository {
  final SupabaseDataSource _ds;

  SupabaseProductRepositoryImpl(this._ds);

  @override
  ResultFuture<List<ProductEntity>> getProducts({
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final products = await _ds.getProducts(
        filters: filters,
        page: page,
        limit: limit,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<ProductEntity> getProductById(String id) async {
    try {
      final product = await _ds.getProductById(id);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> searchProducts(String query) async {
    try {
      final products = await _ds.searchProducts(query);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getFeaturedProducts() async {
    try {
      final products = await _ds.getFeaturedProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByCategory(
    ProductCategory category,
  ) async {
    try {
      final products = await _ds.getProducts(
        filters: ProductFilters(category: category),
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByAnimalType(
    AnimalType type,
  ) async {
    try {
      final products = await _ds.getProducts(
        filters: ProductFilters(animalType: type),
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getRelatedProducts(String productId) async {
    try {
      final products = await _ds.getRelatedProducts(productId);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByIds(List<String> ids) async {
    try {
      final products = await _ds.getProductsByIds(ids);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getOfertasFlash() async {
    try {
      final products = await _ds.getOfertasFlash();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  String _parseError(dynamic e) {
    if (e is PostgrestException) return e.message;
    return e.toString();
  }
}

/// Implementación del repositorio de pedidos con Supabase
class SupabaseOrderRepositoryImpl implements OrderRepository {
  final SupabaseDataSource _ds;

  SupabaseOrderRepositoryImpl(this._ds);

  String? get _userId => _ds.client.auth.currentUser?.id;

  @override
  ResultFuture<List<OrderEntity>> getOrders() async {
    try {
      if (_userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }
      final orders = await _ds.getOrders(_userId!);
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<OrderEntity> getOrderById(String id) async {
    try {
      if (_userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }
      final order = await _ds.getOrderById(id);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<OrderEntity> createOrder({
    required CartEntity cart,
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      if (_userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }

      final items = cart.items
          .map(
            (item) => {
              'product_id': item.product.id,
              'product_name': item.product.name,
              'product_image': item.product.mainImage,
              'price': item.product.finalPrice,
              'quantity': item.quantity,
            },
          )
          .toList();

      final orderId = await _ds.createOrderRpc(
        userId: _userId!,
        total: cart.total,
        items: items,
        promoCode: cart.discountCode,
        discountAmount: cart.discount,
        shippingAddress: shippingAddress,
        notes: notes,
      );

      // Crear factura (consistente con webhook de Astro)
      try {
        await _ds.createInvoice(
          orderId: orderId,
          userId: _userId!,
          total: cart.total,
        );
      } catch (e) {
        // No fallamos el pedido si la factura falla
        debugPrint('Error creando factura: $e');
      }

      // Devolver el pedido recién creado (query directa)
      final order = await _ds.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<OrderEntity> cancelOrder(String orderId) async {
    try {
      await _ds.cancelOrderRpc(orderId);
      final order = await _ds.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  @override
  ResultFuture<OrderEntity> requestReturn(
    String orderId, {
    String? reason,
  }) async {
    try {
      if (_userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }

      await _ds.createReturn({
        'order_id': orderId,
        'user_id': _userId,
        'reason': reason ?? 'Sin motivo especificado',
        'status': 'solicitada',
      });

      final order = await _ds.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: _parseError(e)));
    }
  }

  String _parseError(dynamic e) {
    if (e is PostgrestException) return e.message;
    return e.toString();
  }
}

/// Implementación del repositorio de descuentos con Supabase
class SupabaseDiscountRepositoryImpl implements DiscountRepository {
  final SupabaseDataSource _ds;

  SupabaseDiscountRepositoryImpl(this._ds);

  @override
  ResultFuture<DiscountCodeEntity> validateDiscountCode(
    String code,
    double subtotal,
  ) async {
    try {
      final discount = await _ds.validateDiscountCode(code);

      if (!discount.isValid) {
        return const Left(
          ValidationFailure(message: 'Código expirado o inactivo'),
        );
      }

      return Right(discount);
    } catch (e) {
      return const Left(
        ValidationFailure(message: 'Código de descuento inválido'),
      );
    }
  }
}

/// Implementación del repositorio de reviews con Supabase
class SupabaseReviewRepositoryImpl implements ReviewRepository {
  final SupabaseDataSource _ds;

  SupabaseReviewRepositoryImpl(this._ds);

  @override
  ResultFuture<List<ReviewEntity>> getProductReviews(String productId) async {
    try {
      final reviews = await _ds.getProductReviews(productId);
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<ReviewStats> getReviewStats(String productId) async {
    try {
      final stats = await _ds.getReviewStats(productId);
      return Right(
        ReviewStats(
          averageRating: (stats['average_rating'] as num?)?.toDouble() ?? 0,
          totalReviews: (stats['total_reviews'] as num?)?.toInt() ?? 0,
          distribution: Map<int, int>.from(stats['distribution'] ?? {}),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<ReviewEntity> createReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = _ds.client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }

      final review = await _ds.createReview({
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
      return Right(review);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteReview(String reviewId) async {
    try {
      await _ds.deleteReview(reviewId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid voteHelpful(String reviewId) async {
    try {
      final userId = _ds.client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(AuthFailure(message: 'Usuario no autenticado'));
      }
      await _ds.voteHelpful(reviewId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

/// Implementación del repositorio de admin con Supabase
class SupabaseAdminRepositoryImpl implements AdminRepository {
  final SupabaseDataSource _ds;

  SupabaseAdminRepositoryImpl(this._ds);

  @override
  ResultFuture<ProductEntity> createProduct(Map<String, dynamic> data) async {
    try {
      final product = await _ds.createProduct(data);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<ProductEntity> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final product = await _ds.updateProduct(id, data);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteProduct(String id) async {
    try {
      await _ds.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<OrderEntity>> getAllOrders({String? status}) async {
    try {
      final orders = await _ds.getAllOrders(status: status);
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid updateOrderStatus(String orderId, String status) async {
    try {
      await _ds.updateOrderStatus(orderId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<DashboardStats> getDashboardStats() async {
    try {
      final stats = await _ds.getDashboardStats();
      return Right(
        DashboardStats(
          totalSales: (stats['total_sales'] as num?)?.toDouble() ?? 0,
          totalOrders: (stats['total_orders'] as num?)?.toInt() ?? 0,
          totalUsers: (stats['total_users'] as num?)?.toInt() ?? 0,
          totalProducts: (stats['total_products'] as num?)?.toInt() ?? 0,
          lowStockProducts: (stats['low_stock_products'] as num?)?.toInt() ?? 0,
          recentOrders: [],
          salesByMonth: Map<String, double>.from(stats['sales_by_month'] ?? {}),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<NewsletterSubscriber>> getNewsletterSubscribers() async {
    try {
      final subscribers = await _ds.getNewsletterSubscribers();
      return Right(subscribers);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteNewsletterSubscriber(String email) async {
    try {
      await _ds.deleteNewsletterSubscriber(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<InvoiceEntity>> getInvoices() async {
    try {
      final invoices = await _ds.getInvoices();
      return Right(invoices);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ReturnEntity>> getReturns() async {
    try {
      final returns = await _ds.getReturns();
      return Right(
        returns
            .map(
              (r) => ReturnEntity(
                id: r.id,
                orderId: r.orderId,
                userId: r.userId,
                reason: r.reason,
                status: r.status,
                refundAmount: r.refundAmount,
                adminNotes: r.adminNotes,
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid updateReturnStatus(
    String returnId,
    String status, {
    String? adminNotes,
  }) async {
    try {
      await _ds.updateReturnStatus(returnId, status, adminNotes: adminNotes);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<DiscountCodeEntity>> getPromoCodes() async {
    try {
      final codes = await _ds.getPromoCodes();
      return Right(codes);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid createPromoCode(Map<String, dynamic> data) async {
    try {
      await _ds.createPromoCode(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deletePromoCode(String code) async {
    try {
      await _ds.deletePromoCode(code);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<bool> getOfertasFlashActive() async {
    try {
      final active = await _ds.getOfertasFlashActive();
      return Right(active);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid setOfertasFlashActive(bool active) async {
    try {
      await _ds.setOfertasFlashActive(active);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<UserEntity>> getAllUsers() async {
    try {
      final users = await _ds.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
