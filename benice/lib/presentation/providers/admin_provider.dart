import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

// ==================== ADMIN STATE ====================

class AdminDashboardState {
  final DashboardStats stats;
  final bool isLoading;
  final String? error;

  const AdminDashboardState({
    this.stats = const DashboardStats(),
    this.isLoading = false,
    this.error,
  });
}

class AdminOrdersState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? error;
  final String? filterStatus;

  const AdminOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });
}

class AdminProductsState {
  final List<ProductEntity> products;
  final bool isLoading;
  final String? error;

  const AdminProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });
}

class AdminNewsletterState {
  final List<NewsletterSubscriber> subscribers;
  final bool isLoading;

  const AdminNewsletterState({
    this.subscribers = const [],
    this.isLoading = false,
  });
}

class AdminReturnsState {
  final List<ReturnEntity> returns;
  final bool isLoading;

  const AdminReturnsState({this.returns = const [], this.isLoading = false});
}

class AdminPromoCodesState {
  final List<DiscountCodeEntity> codes;
  final bool isLoading;

  const AdminPromoCodesState({this.codes = const [], this.isLoading = false});
}

// ==================== DASHBOARD NOTIFIER ====================

class AdminDashboardNotifier extends Notifier<AdminDashboardState> {
  @override
  AdminDashboardState build() {
    Future.microtask(() => _loadStats());
    return const AdminDashboardState(isLoading: true);
  }

  Future<void> _loadStats() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getDashboardStats();
      result.fold(
        (failure) => state = AdminDashboardState(error: failure.message),
        (stats) => state = AdminDashboardState(stats: stats),
      );
    } catch (e) {
      state = AdminDashboardState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AdminDashboardState(isLoading: true);
    await _loadStats();
  }
}

// ==================== ADMIN ORDERS NOTIFIER ====================

class AdminOrdersNotifier extends Notifier<AdminOrdersState> {
  @override
  AdminOrdersState build() {
    Future.microtask(() => _loadOrders());
    return const AdminOrdersState(isLoading: true);
  }

  Future<void> _loadOrders() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getAllOrders();
      result.fold(
        (failure) => state = AdminOrdersState(error: failure.message),
        (orders) => state = AdminOrdersState(orders: orders),
      );
    } catch (e) {
      state = AdminOrdersState(error: e.toString());
    }
  }

  Future<void> filterByStatus(String? status) async {
    state = const AdminOrdersState(isLoading: true);
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getAllOrders(status: status);
      result.fold(
        (failure) => state = AdminOrdersState(error: failure.message),
        (orders) =>
            state = AdminOrdersState(orders: orders, filterStatus: status),
      );
    } catch (e) {
      state = AdminOrdersState(error: e.toString());
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    final result = await adminRepo.updateOrderStatus(orderId, newStatus);
    result.fold(
      (failure) {
        // Don't update local state on failure
        state = AdminOrdersState(
          orders: state.orders,
          filterStatus: state.filterStatus,
          error: failure.message,
        );
      },
      (_) {
        // Update local state only on success
        final updated = state.orders.map((o) {
          if (o.id == orderId) {
            return o.copyWith(
              status: OrderStatus.values.firstWhere(
                (s) => s.name == newStatus,
                orElse: () => o.status,
              ),
              updatedAt: DateTime.now(),
            );
          }
          return o;
        }).toList();
        state = AdminOrdersState(
          orders: updated,
          filterStatus: state.filterStatus,
        );
      },
    );
  }
}

// ==================== ADMIN PRODUCTS NOTIFIER ====================

class AdminProductsNotifier extends Notifier<AdminProductsState> {
  @override
  AdminProductsState build() {
    Future.microtask(() => _loadProducts());
    return const AdminProductsState(isLoading: true);
  }

  Future<void> _loadProducts() async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final result = await productRepo.getProducts(page: 1, limit: 50);
      result.fold(
        (failure) => state = AdminProductsState(error: failure.message),
        (products) => state = AdminProductsState(products: products),
      );
    } catch (e) {
      state = AdminProductsState(error: e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    await adminRepo.deleteProduct(id);
    await _loadProducts();
  }

  Future<void> refresh() async {
    state = const AdminProductsState(isLoading: true);
    await _loadProducts();
  }
}

// ==================== ADMIN NEWSLETTER NOTIFIER ====================

class AdminNewsletterNotifier extends Notifier<AdminNewsletterState> {
  @override
  AdminNewsletterState build() {
    Future.microtask(() => _load());
    return const AdminNewsletterState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getNewsletterSubscribers();
      result.fold(
        (failure) => state = const AdminNewsletterState(),
        (subscribers) => state = AdminNewsletterState(subscribers: subscribers),
      );
    } catch (e) {
      state = const AdminNewsletterState();
    }
  }

  Future<void> deleteSubscriber(String email) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    await adminRepo.deleteNewsletterSubscriber(email);
    await _load();
  }
}

// ==================== ADMIN RETURNS NOTIFIER ====================

class AdminReturnsNotifier extends Notifier<AdminReturnsState> {
  @override
  AdminReturnsState build() {
    Future.microtask(() => _load());
    return const AdminReturnsState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getReturns();
      result.fold(
        (failure) => state = const AdminReturnsState(),
        (returns) => state = AdminReturnsState(returns: returns),
      );
    } catch (e) {
      state = const AdminReturnsState();
    }
  }

  Future<void> updateStatus(
    String returnId,
    String status, {
    String? notes,
  }) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    await adminRepo.updateReturnStatus(returnId, status, adminNotes: notes);
    await _load();
  }
}

// ==================== ADMIN PROMO CODES NOTIFIER ====================

class AdminPromoCodesNotifier extends Notifier<AdminPromoCodesState> {
  @override
  AdminPromoCodesState build() {
    Future.microtask(() => _load());
    return const AdminPromoCodesState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getPromoCodes();
      result.fold(
        (failure) => state = const AdminPromoCodesState(),
        (codes) => state = AdminPromoCodesState(codes: codes),
      );
    } catch (e) {
      state = const AdminPromoCodesState();
    }
  }

  Future<void> createCode(
    String code,
    double percent, {
    DateTime? expiresAt,
  }) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    await adminRepo.createPromoCode({
      'code': code.toUpperCase(),
      'discount_percentage': percent.round(),
      'active': true,
      'expires_at': expiresAt?.toIso8601String(),
    });
    await _load();
  }

  Future<void> deleteCode(String code) async {
    final adminRepo = ref.read(adminRepositoryProvider);
    await adminRepo.deletePromoCode(code);
    await _load();
  }
}

// ==================== OFERTAS FLASH ====================

class OfertasFlashState {
  final bool isActive;
  final bool isLoading;

  const OfertasFlashState({this.isActive = false, this.isLoading = false});
}

class OfertasFlashNotifier extends Notifier<OfertasFlashState> {
  @override
  OfertasFlashState build() {
    return const OfertasFlashState(isActive: true);
  }

  Future<void> toggle() async {
    final newValue = !state.isActive;
    state = OfertasFlashState(isActive: newValue, isLoading: true);
    final adminRepo = ref.read(adminRepositoryProvider);
    final result = await adminRepo.setOfertasFlashActive(newValue);
    result.fold(
      (failure) {
        // Revert on failure
        state = OfertasFlashState(isActive: !newValue);
      },
      (_) {
        state = OfertasFlashState(isActive: newValue);
      },
    );
  }
}

// ==================== PROVIDERS ====================

final adminDashboardProvider =
    NotifierProvider.autoDispose<AdminDashboardNotifier, AdminDashboardState>(
      AdminDashboardNotifier.new,
    );

final adminOrdersProvider =
    NotifierProvider.autoDispose<AdminOrdersNotifier, AdminOrdersState>(
      AdminOrdersNotifier.new,
    );

final adminProductsProvider =
    NotifierProvider.autoDispose<AdminProductsNotifier, AdminProductsState>(
      AdminProductsNotifier.new,
    );

final adminNewsletterProvider =
    NotifierProvider.autoDispose<AdminNewsletterNotifier, AdminNewsletterState>(
      AdminNewsletterNotifier.new,
    );

final adminReturnsProvider =
    NotifierProvider.autoDispose<AdminReturnsNotifier, AdminReturnsState>(
      AdminReturnsNotifier.new,
    );

final adminPromoCodesProvider =
    NotifierProvider.autoDispose<AdminPromoCodesNotifier, AdminPromoCodesState>(
      AdminPromoCodesNotifier.new,
    );

final ofertasFlashProvider =
    NotifierProvider.autoDispose<OfertasFlashNotifier, OfertasFlashState>(
      OfertasFlashNotifier.new,
    );
