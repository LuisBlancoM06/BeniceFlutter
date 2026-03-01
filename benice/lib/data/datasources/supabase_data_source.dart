import 'dart:typed_data';
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

  /// Columnas necesarias para listados de productos (evita descargar description, images, etc.)
  static const _productListColumns =
      'id,name,slug,price,sale_price,on_sale,image_url,category,animal_type,stock,rating,reviews_count,brand,size,age_range,created_at';

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
    var query = _client.from('products').select(_productListColumns);

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
        final escapedQuery = filters.searchQuery!
            .replaceAll('%', '\\%')
            .replaceAll('_', '\\_');
        query = query.ilike('name', '%$escapedQuery%');
      }
    }

    final from = (page - 1) * limit;
    final to = from + limit - 1;
    final data = await query
        .range(from, to)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final data = await _client.from('products').select().eq('id', id).single();
    return ProductModel.fromJson(data);
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final data = await _client.from('products').select().inFilter('id', ids);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, products(name, image_url))')
        .eq('id', orderId)
        .single();
    return OrderModel.fromJson(data);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select(_productListColumns)
        .ilike('name', '%$query%')
        .limit(10);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    // DB has no is_featured column; show on_sale products as featured
    final data = await _client
        .from('products')
        .select(_productListColumns)
        .eq('on_sale', true)
        .gt('stock', 0)
        .limit(8);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getOfertasFlash() async {
    final data = await _client
        .from('products')
        .select(_productListColumns)
        .eq('on_sale', true)
        .gt('stock', 0)
        .order('created_at', ascending: false)
        .limit(20);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getRelatedProducts(String productId) async {
    final product = await getProductById(productId);
    final data = await _client
        .from('products')
        .select(_productListColumns)
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
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List).map((order) {
      return OrderModel.fromJson(order);
    }).toList();
  }

  Future<String> createOrderRpc({
    required String userId,
    required double total,
    required List<Map<String, dynamic>> items,
    String? promoCode,
    double? discountAmount,
    required String shippingAddress,
    String? shippingName,
    String? shippingPhone,
    double? shippingCost,
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
        'p_shipping_address': shippingAddress,
        if (shippingCost != null) 'p_shipping_cost': shippingCost,
        if (notes != null && notes.isNotEmpty) 'p_notes': notes,
        if (shippingName != null) 'p_shipping_name': shippingName,
        if (shippingPhone != null) 'p_shipping_phone': shippingPhone,
      },
    );
    // RPC devuelve UUID directamente como string
    return result.toString();
  }

  /// Crear factura para un pedido (consistente con webhook de Astro)
  Future<void> createInvoice({
    required String orderId,
    required String userId,
    required double total,
  }) async {
    // Generar número de factura: FAC-{año}-{secuencia}
    final year = DateTime.now().year;
    final prefix = 'FAC';

    final data = await _client
        .from('invoices')
        .select('invoice_number')
        .like('invoice_number', '$prefix-$year-%')
        .order('invoice_number', ascending: false)
        .limit(1);

    int sequence = 1;
    if (data.isNotEmpty) {
      final lastNumber = data[0]['invoice_number'] as String;
      final match = RegExp(r'(\d+)$').firstMatch(lastNumber);
      if (match != null) {
        sequence = int.parse(match.group(1)!) + 1;
      }
    }

    final invoiceNumber =
        '$prefix-$year-${sequence.toString().padLeft(6, '0')}';

    await _client.from('invoices').insert({
      'order_id': orderId,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'invoice_type': 'factura',
      'subtotal': (total / 1.21 * 100).round() / 100, // Sin IVA 21%
      'tax_amount': ((total - total / 1.21) * 100).round() / 100,
      'total': total,
    });
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
    final data = await query.order('created_at', ascending: false).limit(100);
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
        .order('created_at', ascending: false)
        .limit(50);
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
    if (result is List) {
      if (result.isEmpty) return {};
      return Map<String, dynamic>.from(result.first as Map);
    }
    return Map<String, dynamic>.from(result as Map);
  }

  // ==================== DESCUENTOS ====================

  /// Valida código promo (consistente con Astro validate-promo.ts):
  /// Verifica: activo + no expirado + usos < max_uses
  Future<DiscountCodeModel> validateDiscountCode(String code) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .eq('active', true)
        .single();

    final model = DiscountCodeModel.fromJson(data);

    // Verificar expiración (como Astro)
    if (model.expiresAt != null && model.expiresAt!.isBefore(DateTime.now())) {
      throw Exception('El código ha expirado');
    }

    // Verificar usos máximos (como Astro)
    if (model.maxUses != null && model.currentUses >= model.maxUses!) {
      throw Exception('El código ha alcanzado su límite de usos');
    }

    return model;
  }

  // ==================== NEWSLETTER ====================

  /// Genera un código promo único para newsletter (igual que Astro: BIENVENIDO + 6 chars random)
  String _generatePromoCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    var code = AppConstants.newsletterPromoCodePrefix;
    for (var i = 0; i < 6; i++) {
      code += chars[((random >> (i * 5)) + i * 7) % chars.length];
    }
    return code;
  }

  /// Suscribe a newsletter y genera código promo único (consistente con Astro)
  Future<String> subscribeNewsletter(String email, {String? name}) async {
    // Verificar si ya está suscrito
    final existing = await _client
        .from('newsletters')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Email ya suscrito');
    }

    final promoCode = _generatePromoCode();

    // Crear código promo en promo_codes (como Astro: 10%, 1 uso, 30 días)
    await _client.from('promo_codes').insert({
      'code': promoCode,
      'discount_percentage': AppConstants.newsletterDiscountPercent,
      'active': true,
      'max_uses': AppConstants.newsletterPromoMaxUses,
      'current_uses': 0,
      'expires_at': DateTime.now()
          .add(Duration(days: AppConstants.newsletterPromoDaysValid))
          .toIso8601String(),
    });

    // Insertar suscripción con código único
    await _client.from('newsletters').insert({
      'email': email,
      'promo_code': promoCode,
      'source': 'app',
    });

    return promoCode;
  }

  Future<List<NewsletterSubscriberModel>> getNewsletterSubscribers() async {
    final data = await _client
        .from('newsletters')
        .select()
        .order('created_at', ascending: false)
        .limit(200);
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
        .order('created_at', ascending: false)
        .limit(100);
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
    final data = await query.order('created_at', ascending: false).limit(100);
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

  // ==================== SOLICITUDES DE CANCELACIÓN ====================

  Future<CancellationRequestModel> createCancellationRequest(
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('cancellation_requests')
        .insert(data)
        .select()
        .single();
    return CancellationRequestModel.fromJson(result);
  }

  Future<List<CancellationRequestModel>> getCancellationRequests({
    String? userId,
    String? status,
  }) async {
    var query = _client.from('cancellation_requests').select();
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (status != null) {
      query = query.eq('status', status);
    }
    final data = await query.order('created_at', ascending: false).limit(100);
    return (data as List)
        .map((e) => CancellationRequestModel.fromJson(e))
        .toList();
  }

  Future<void> updateCancellationRequestStatus(
    String requestId,
    String status, {
    String? adminNotes,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (adminNotes != null) updateData['admin_notes'] = adminNotes;
    await _client
        .from('cancellation_requests')
        .update(updateData)
        .eq('id', requestId);
  }

  Future<List<CancellationRequestModel>> getCancellationRequestsForOrder(
    String orderId,
  ) async {
    final data = await _client
        .from('cancellation_requests')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => CancellationRequestModel.fromJson(e))
        .toList();
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    // Query tables directly instead of relying on RPC
    // 1. Orders: total sales + count (only non-cancelled)
    final ordersData = await _client
        .from('orders')
        .select('total, status, created_at');

    final allOrders = ordersData as List;
    final activeOrders = allOrders.where((o) => o['status'] != 'cancelado');
    final totalSales = activeOrders.fold<double>(
      0,
      (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0),
    );
    final totalOrders = allOrders.length;

    // 2. Products count + low stock
    final productsData = await _client.from('products').select('stock');
    final allProducts = productsData as List;
    final totalProducts = allProducts.length;
    final lowStockProducts = allProducts
        .where((p) => (p['stock'] as num?) != null && (p['stock'] as num) <= 5)
        .length;

    // 3. Users count
    final usersData = await _client.from('users').select('id').limit(10000);
    final totalUsers = (usersData as List).length;

    // 4. Orders by status
    final ordersByStatus = <String, int>{};
    for (final order in allOrders) {
      final status = order['status']?.toString() ?? 'unknown';
      ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;
    }

    // 5. Sales by month (last 6 months)
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final recentOrders = allOrders.where((o) {
      final created = DateTime.tryParse(o['created_at']?.toString() ?? '');
      return created != null &&
          created.isAfter(sixMonthsAgo) &&
          o['status'] != 'cancelado';
    });
    final salesByMonth = <String, double>{};
    for (final order in recentOrders) {
      final created = DateTime.tryParse(order['created_at']?.toString() ?? '');
      if (created != null) {
        final key =
            '${created.year}-${created.month.toString().padLeft(2, '0')}';
        salesByMonth[key] =
            (salesByMonth[key] ?? 0) +
            ((order['total'] as num?)?.toDouble() ?? 0);
      }
    }

    return {
      'total_sales': totalSales,
      'total_orders': totalOrders,
      'total_users': totalUsers,
      'total_products': totalProducts,
      'low_stock_products': lowStockProducts,
      'orders_by_status': ordersByStatus,
      'sales_by_month': salesByMonth,
    };
  }

  Future<Map<String, dynamic>> getOrderStatusCounts() async {
    final result = await _client.rpc('get_order_status_counts');
    if (result is List) {
      if (result.isEmpty) return {};
      return Map<String, dynamic>.from(result.first as Map);
    }
    return Map<String, dynamic>.from(result as Map);
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
    final bytes = fileBytes is Uint8List
        ? fileBytes
        : Uint8List.fromList(fileBytes);
    await _client.storage.from('products').uploadBinary(path, bytes);
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
        .order('created_at', ascending: false)
        .limit(200);
    return (data as List).map((e) => UserModel.fromJson(e)).toList();
  }
}
