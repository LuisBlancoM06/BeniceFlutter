import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Datasource que conecta con Supabase (BD real)
/// Se activa cuando se configuran las variables de entorno
class SupabaseDataSource {
  final SupabaseClient _client;

  SupabaseDataSource(this._client);

  SupabaseClient get client => _client;

  // ==================== AUTH ====================

  Future<UserModel> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Error al iniciar sesión');
    final userData = await _client
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();
    return UserModel.fromJson(userData);
  }

  Future<UserModel> signUp(
    String email,
    String password, {
    String? name,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Error al registrarse');

    // Crear perfil en tabla users
    final userData = {
      'id': response.user!.id,
      'email': email,
      'full_name': name,
      'phone': phone,
      'role': 'user',
      'created_at': DateTime.now().toIso8601String(),
    };
    await _client.from('users').insert(userData);
    return UserModel.fromJson(userData);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final userData = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    return UserModel.fromJson(userData);
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<UserModel> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _client.from('users').update(data).eq('id', userId);
    final updated = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(updated);
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== PRODUCTOS ====================

  Future<List<ProductModel>> getProducts({
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    var query = _client.from('products').select();

    if (filters != null) {
      if (filters.animalType != null) {
        query = query.eq('animal_type', filters.animalType!.name);
      }
      if (filters.category != null) {
        query = query.eq('category', filters.category!.name);
      }
      if (filters.animalSize != null) {
        query = query.eq('size', filters.animalSize!.name);
      }
      if (filters.animalAge != null) {
        query = query.eq('age_range', filters.animalAge!.name);
      }
      if (filters.onlyWithDiscount == true) {
        query = query.eq('on_sale', true);
      }
      if (filters.onlyInStock == true) {
        query = query.gt('stock', 0);
      }
      if (filters.minPrice != null) {
        query = query.gte('price', filters.minPrice!);
      }
      if (filters.maxPrice != null) {
        query = query.lte('price', filters.maxPrice!);
      }
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        query = query.ilike('name', '%${filters.searchQuery}%');
      }
    }

    final from = (page - 1) * limit;
    final to = from + limit - 1;
    final data = await query
        .range(from, to)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final data = await _client.from('products').select().eq('id', id).single();
    return ProductModel.fromJson(data);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select()
        .ilike('name', '%$query%')
        .limit(10);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    // DB has no is_featured column; show on_sale products as featured
    final data = await _client
        .from('products')
        .select()
        .eq('on_sale', true)
        .gt('stock', 0)
        .limit(8);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getOfertasFlash() async {
    final data = await _client
        .from('products')
        .select()
        .eq('on_sale', true)
        .gt('stock', 0)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getRelatedProducts(String productId) async {
    final product = await getProductById(productId);
    final data = await _client
        .from('products')
        .select()
        .eq('animal_type', product.animalType.name)
        .neq('id', productId)
        .limit(4);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  // ==================== ADMIN PRODUCTOS ====================

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    final data = await _client
        .from('products')
        .insert(productData)
        .select()
        .single();
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    final data = await _client
        .from('products')
        .update(productData)
        .eq('id', id)
        .select()
        .single();
    return ProductModel.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // ==================== PEDIDOS ====================

  Future<List<OrderModel>> getOrders(String userId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, products(name, image_url))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((order) {
      return OrderModel.fromJson(order);
    }).toList();
  }

  Future<Map<String, dynamic>> createOrderRpc({
    required String userId,
    required double total,
    required List<Map<String, dynamic>> items,
    String? promoCode,
    double? discountAmount,
    required String shippingAddress,
    String? notes,
  }) async {
    final result = await _client.rpc(
      'create_order_and_reduce_stock',
      params: {
        'p_user_id': userId,
        'p_total': total,
        'p_items': items,
        'p_promo_code': promoCode,
        'p_discount_amount': discountAmount ?? 0,
      },
    );
    return result as Map<String, dynamic>;
  }

  Future<void> cancelOrderRpc(String orderId) async {
    await _client.rpc(
      'cancel_order_and_restore_stock',
      params: {'order_uuid': orderId},
    );
  }

  // ==================== ADMIN PEDIDOS ====================

  Future<List<OrderModel>> getAllOrders({String? status}) async {
    var query = _client
        .from('orders')
        .select('*, order_items(*, products(name, image_url))');
    if (status != null) {
      query = query.eq('status', status);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((order) {
      return OrderModel.fromJson(order);
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _client.from('orders').update(updateData).eq('id', orderId);
  }

  // ==================== REVIEWS ====================

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final data = await _client
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final data = await _client
        .from('product_reviews')
        .insert(reviewData)
        .select()
        .single();
    return ReviewModel.fromJson(data);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('product_reviews').delete().eq('id', reviewId);
  }

  Future<void> voteHelpful(String reviewId, String userId) async {
    await _client.from('review_helpful_votes').insert({
      'review_id': reviewId,
      'user_id': userId,
    });
  }

  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    final result = await _client.rpc(
      'get_product_review_stats',
      params: {'p_product_id': productId},
    );
    return result as Map<String, dynamic>;
  }

  // ==================== DESCUENTOS ====================

  Future<DiscountCodeModel> validateDiscountCode(String code) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .eq('active', true)
        .single();
    return DiscountCodeModel.fromJson(data);
  }

  // ==================== NEWSLETTER ====================

  Future<void> subscribeNewsletter(String email, {String? name}) async {
    await _client.from('newsletters').insert({
      'email': email,
      'promo_code': AppConstants.newsletterPromoCode,
      'source': 'app',
    });
  }

  Future<List<NewsletterSubscriberModel>> getNewsletterSubscribers() async {
    final data = await _client
        .from('newsletters')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => NewsletterSubscriberModel.fromJson(e))
        .toList();
  }

  Future<void> deleteNewsletterSubscriber(String email) async {
    await _client.from('newsletters').delete().eq('email', email);
  }

  // ==================== FACTURAS ====================

  Future<List<InvoiceModel>> getInvoices() async {
    final data = await _client
        .from('invoices')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => InvoiceModel.fromJson(e)).toList();
  }

  // ==================== DEVOLUCIONES ====================

  Future<ReturnModel> createReturn(Map<String, dynamic> returnData) async {
    final data = await _client
        .from('returns')
        .insert(returnData)
        .select()
        .single();
    return ReturnModel.fromJson(data);
  }

  Future<List<ReturnModel>> getReturns({String? userId}) async {
    var query = _client.from('returns').select();
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => ReturnModel.fromJson(e)).toList();
  }

  Future<void> updateReturnStatus(
    String returnId,
    String status, {
    String? adminNotes,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (adminNotes != null) updateData['admin_notes'] = adminNotes;
    await _client.from('returns').update(updateData).eq('id', returnId);
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    final result = await _client.rpc('get_dashboard_stats');
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrderStatusCounts() async {
    final result = await _client.rpc('get_order_status_counts');
    return result as Map<String, dynamic>;
  }

  // ==================== SITE SETTINGS ====================

  Future<bool> getOfertasFlashActive() async {
    try {
      final data = await _client
          .from('site_settings')
          .select('value')
          .eq('key', 'ofertas_flash_active')
          .single();
      return data['value'] == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setOfertasFlashActive(bool active) async {
    await _client.from('site_settings').upsert({
      'key': 'ofertas_flash_active',
      'value': active.toString(),
    });
  }

  // ==================== STORAGE ====================

  Future<String> uploadProductImage(
    String fileName,
    List<int> fileBytes,
  ) async {
    final path = 'products/$fileName';
    await _client.storage
        .from('products')
        .uploadBinary(path, fileBytes as dynamic);
    return _client.storage.from('products').getPublicUrl(path);
  }

  Future<void> deleteProductImage(String path) async {
    await _client.storage.from('products').remove([path]);
  }

  // ==================== ADMIN PROMO CODES ====================

  Future<List<DiscountCodeModel>> getPromoCodes() async {
    final data = await _client
        .from('promo_codes')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => DiscountCodeModel.fromJson(e)).toList();
  }

  Future<void> createPromoCode(Map<String, dynamic> promoData) async {
    await _client.from('promo_codes').insert(promoData);
  }

  Future<void> deletePromoCode(String code) async {
    await _client.from('promo_codes').delete().eq('code', code);
  }

  // ==================== ADMIN USERS ====================

  Future<List<UserModel>> getAllUsers() async {
    final data = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => UserModel.fromJson(e)).toList();
  }
}
