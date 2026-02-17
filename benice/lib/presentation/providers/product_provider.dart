import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

/// Estado de productos
class ProductsState {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? errorMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para productos
class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    // Escuchar cambios en los filtros para recargar productos
    ref.listen<ProductFilters>(productFiltersProvider, (previous, next) {
      if (previous != next) {
        _loadProducts();
      }
    });
    // Iniciar carga después de que build() retorne
    Future.microtask(() => _loadProducts());
    return const ProductsState(isLoading: true);
  }

  Future<void> _loadProducts() async {
    final filters = ref.read(productFiltersProvider);

    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(productRepositoryProvider)
        .getProducts(page: 1, limit: 20, filters: filters);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        products: products,
        isLoading: false,
        page: 1,
        hasMore: products.length >= 20,
      ),
    );
  }

  Future<void> refresh() async {
    await _loadProducts();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    // Limitar la lista a máximo 200 productos para evitar consumo excesivo de memoria
    if (state.products.length >= 200) {
      state = state.copyWith(hasMore: false);
      return;
    }

    final filters = ref.read(productFiltersProvider);
    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(productRepositoryProvider)
        .getProducts(page: state.page + 1, limit: 20, filters: filters);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false),
      (products) => state = state.copyWith(
        products: [...state.products, ...products],
        isLoading: false,
        page: state.page + 1,
        hasMore: products.length >= 20,
      ),
    );
  }
}

/// Notifier para filtros de productos
class ProductFiltersNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void updateFilters(ProductFilters filters) {
    state = filters;
  }

  void clearFilters() {
    state = const ProductFilters();
  }
}

/// Provider de filtros de productos
final productFiltersProvider =
    NotifierProvider<ProductFiltersNotifier, ProductFilters>(
      ProductFiltersNotifier.new,
    );

/// Provider de productos
final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

/// Provider para detalle de producto
final productDetailProvider = FutureProvider.autoDispose
    .family<ProductEntity?, String>((ref, productId) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getProductById(productId);
      return result.fold((failure) => null, (product) => product);
    });

/// Provider para productos relacionados
final relatedProductsProvider = FutureProvider.autoDispose
    .family<List<ProductEntity>, String>((ref, productId) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getRelatedProducts(productId);
      return result.fold((failure) => [], (products) => products);
    });

/// Provider para productos destacados
final featuredProductsProvider =
    FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getFeaturedProducts();
      return result.fold((failure) => [], (products) => products);
    });

/// Estado de búsqueda
class SearchState {
  final String query;
  final List<ProductEntity> results;
  final bool isLoading;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    List<ProductEntity>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier de búsqueda con debounce
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void search(String query) {
    state = state.copyWith(query: query, isLoading: query.isNotEmpty);

    _debounce?.cancel();

    if (query.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await ref
          .read(productRepositoryProvider)
          .searchProducts(query);

      result.fold(
        (failure) => state = state.copyWith(isLoading: false, results: []),
        (products) =>
            state = state.copyWith(isLoading: false, results: products),
      );
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

/// Provider de búsqueda
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

/// Provider de productos por categoría
final productsByCategoryProvider = FutureProvider.autoDispose
    .family<List<ProductEntity>, ProductCategory>((ref, category) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getProductsByCategory(category);
      return result.fold((failure) => [], (products) => products);
    });

/// Provider de productos por tipo de animal
final productsByAnimalTypeProvider = FutureProvider.autoDispose
    .family<List<ProductEntity>, AnimalType>((ref, animalType) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getProductsByAnimalType(animalType);
      return result.fold((failure) => [], (products) => products);
    });

/// Provider de productos filtrados (usado por el recomendador)
final filteredProductsProvider = FutureProvider.autoDispose
    .family<List<ProductEntity>, ProductFilters>((ref, filters) async {
      final result = await ref
          .read(productRepositoryProvider)
          .getProducts(page: 1, limit: 50, filters: filters);
      return result.fold((failure) => [], (products) => products);
    });
