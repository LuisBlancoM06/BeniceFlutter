import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/favorites_provider.dart';

/// Tarjeta de producto - estilo web con rounded-2xl y shadow-sm
class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.id));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadiusLg),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: product.mainImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Badge de descuento
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusFull,
                          ),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite
                              ? AppTheme.errorColor
                              : AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                  // Animal type badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusFull,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.animalType.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.animalType.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría
                    Text(
                      product.category.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Nombre
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Precio y botón
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                '${product.price.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppTheme.textLight,
                                ),
                              ),
                            Text(
                              '${product.finalPrice.toStringAsFixed(2)}€',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: product.hasDiscount
                                    ? AppTheme.errorColor
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (onAddToCart != null && product.inStock)
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    Color(0xFF9333EA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        if (!product.inStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Agotado',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer para carga de productos
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.borderRadiusLg),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 50, height: 8, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 12, color: Colors.white),
                    const Spacer(),
                    Container(width: 50, height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid de productos con shimmer
class ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final bool isLoading;
  final void Function(ProductEntity) onProductTap;
  final void Function(ProductEntity)? onAddToCart;
  final int shimmerCount;

  const ProductsGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onAddToCart,
    this.isLoading = false,
    this.shimmerCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: shimmerCount,
        itemBuilder: (context, index) => const ProductCardShimmer(),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba con otros filtros o categorías',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length + (isLoading ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const ProductCardShimmer();
        }
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap(product),
          onAddToCart: onAddToCart != null ? () => onAddToCart!(product) : null,
        );
      },
    );
  }
}
