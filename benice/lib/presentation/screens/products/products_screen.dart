import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_filters.dart';
import '../../widgets/search/search_widgets.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final filters = ref.watch(productFiltersProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(),
          ),
          CountBadge(
            count: cartItemCount,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push('/cart'),
            ),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: filters.hasActiveFilters,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => _showFiltersSheet(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Barra de filtros rápidos
            SliverToBoxAdapter(
              child: ProductFilterBar(
                filters: filters,
                onFiltersChanged: (newFilters) {
                  ref
                      .read(productFiltersProvider.notifier)
                      .updateFilters(newFilters);
                },
                onClearFilters: () {
                  ref.read(productFiltersProvider.notifier).clearFilters();
                },
              ),
            ),
            // Contador de resultados
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${productsState.products.length} productos',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (filters.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(productFiltersProvider.notifier)
                              .clearFilters();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpiar filtros'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Lista de productos
            if (productsState.isLoading && productsState.products.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const ProductCardShimmer(),
                    childCount: 6,
                  ),
                ),
              )
            else if (productsState.products.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontraron productos',
                  message: 'Prueba con otros filtros',
                  actionLabel: 'Limpiar filtros',
                  onAction: () {
                    ref.read(productFiltersProvider.notifier).clearFilters();
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= productsState.products.length) {
                        return const ProductCardShimmer();
                      }
                      final product = productsState.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          CustomSnackBar.showSuccess(
                            context,
                            '${product.name} añadido al carrito',
                          );
                        },
                      );
                    },
                    childCount:
                        productsState.products.length +
                        (productsState.isLoading ? 2 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openSearch() async {
    final product = await showSearch<ProductEntity?>(
      context: context,
      delegate: ProductSearchDelegate(
        onSearch: (query) async {
          final result = await ref
              .read(productRepositoryProvider)
              .searchProducts(query);
          return result.fold((failure) => [], (products) => products);
        },
        onProductSelected: (product) {
          context.push('/product/${product.id}');
        },
      ),
    );

    if (product != null && mounted) {
      context.push('/product/${product.id}');
    }
  }

  void _showFiltersSheet() {
    FiltersBottomSheet.show(
      context,
      initialFilters: ref.read(productFiltersProvider),
      onApply: (filters) {
        ref.read(productFiltersProvider.notifier).updateFilters(filters);
      },
    );
  }
}
