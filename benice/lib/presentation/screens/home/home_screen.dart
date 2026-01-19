import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/newsletter_widgets.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/search/search_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final featuredProducts = ref.watch(featuredProductsProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'BeniceAstro',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              // Búsqueda
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _openSearch(),
              ),
              // Carrito
              CountBadge(
                count: cartItemCount,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.push('/cart'),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner
                _HeroBanner(onViewProducts: () => context.push('/products')),
                const SizedBox(height: 24),
                // Categorías por tipo de animal
                const SectionHeader(title: 'Compra por Categoría'),
                _AnimalTypeSelector(
                  onSelected: (type) {
                    ref
                        .read(productFiltersProvider.notifier)
                        .updateFilters(ProductFilters(animalType: type));
                    context.push('/products');
                  },
                ),
                const SizedBox(height: 24),
                // Productos destacados
                const SectionHeader(
                  title: 'Productos Destacados',
                  actionText: 'Ver todos',
                ),
              ],
            ),
          ),
          // Grid de productos destacados
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: featuredProducts.when(
              data: (products) => SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
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
                }, childCount: products.length.clamp(0, 6)),
              ),
              loading: () => SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ProductCardShimmer(),
                  childCount: 4,
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: ErrorState(
                  message: 'Error al cargar productos',
                  onRetry: () => ref.invalidate(featuredProductsProvider),
                ),
              ),
            ),
          ),
          // Newsletter Banner
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                NewsletterBanner(
                  onSubscribe: () {
                    NewsletterPopup.show(
                      context,
                      onSubscribe: (email) async {
                        return await ref
                            .read(authProvider.notifier)
                            .subscribeToNewsletter(email: email);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Info footer
                _InfoSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onViewProducts;

  const _HeroBanner({required this.onViewProducts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenido a BeniceAstro 🐾',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onViewProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
            ),
            child: const Text('Ver Productos'),
          ),
        ],
      ),
    );
  }
}

class _AnimalTypeSelector extends StatelessWidget {
  final ValueChanged<AnimalType> onSelected;

  const _AnimalTypeSelector({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: AnimalType.values.map((type) {
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(type),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      type.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(type),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getSubtitle(AnimalType type) {
    switch (type) {
      case AnimalType.perro:
        return 'Productos para tu mejor amigo';
      case AnimalType.gato:
        return 'Todo para tu felino';
      case AnimalType.otro:
        return 'Conejos, aves y más';
    }
  }
}

class _InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: '🚚',
              title: 'Envío Gratis',
              subtitle:
                  'En pedidos superiores a ${AppConstants.freeShippingMinAmount.toInt()}€',
            ),
          ),
          Expanded(
            child: _InfoItem(
              icon: '💳',
              title: 'Pago Seguro',
              subtitle: 'Métodos de pago protegidos',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
