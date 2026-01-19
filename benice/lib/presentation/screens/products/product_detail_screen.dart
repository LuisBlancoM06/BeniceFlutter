import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/product/product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final relatedProducts = ref.watch(
      relatedProductsProvider(widget.productId),
    );

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Producto no encontrado',
                message: 'No se pudo cargar la información del producto',
              ),
            );
          }
          return _buildContent(product, relatedProducts);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorState(
          message: 'Error al cargar el producto',
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => product != null ? _buildBottomBar(product) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildContent(
    ProductEntity product,
    AsyncValue<List<ProductEntity>> relatedProducts,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          backgroundColor: Colors.white,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: CountBadge(
                count: ref.watch(cartItemCountProvider),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.push('/cart'),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _ImageCarousel(
              images: product.images,
              currentIndex: _currentImageIndex,
              onIndexChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              hasDiscount: product.hasDiscount,
              discountPercentage: product.discountPercentage,
            ),
          ),
        ),
        // Contenido
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusLg,
                          ),
                        ),
                        child: Text(
                          '${product.category.emoji} ${product.category.label}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (product.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${product.reviewsCount})',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Nombre
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Marca: ${product.brand}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.hasDiscount) ...[
                        Text(
                          '${product.price.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '${product.finalPrice.toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: product.hasDiscount
                              ? AppTheme.errorColor
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Especificaciones
                  _SpecificationsSection(product: product),
                  const SizedBox(height: 20),
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stock
                  _StockIndicator(stock: product.stock),
                  const SizedBox(height: 24),
                  // Selector de cantidad
                  if (product.inStock) ...[
                    const Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuantitySelector(
                      quantity: _quantity,
                      maxQuantity: product.stock.clamp(1, 10),
                      onChanged: (value) => setState(() => _quantity = value),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Productos relacionados
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Productos Relacionados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              relatedProducts.when(
                data: (products) {
                  if (products.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final relatedProduct = products[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: ProductCard(
                            product: relatedProduct,
                            onTap: () =>
                                context.push('/product/${relatedProduct.id}'),
                            onAddToCart: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(relatedProduct);
                              CustomSnackBar.showSuccess(
                                context,
                                '${relatedProduct.name} añadido al carrito',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Precio total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(product.finalPrice * _quantity).toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Botón añadir
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: product.inStock
                    ? () {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(product, quantity: _quantity);
                        CustomSnackBar.showSuccess(
                          context,
                          '${product.name} añadido al carrito',
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  product.inStock ? 'Añadir al Carrito' : 'Sin Stock',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final bool hasDiscount;
  final int discountPercentage;

  const _ImageCarousel({
    required this.images,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.hasDiscount,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (images.isEmpty)
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.pets, size: 64, color: Colors.grey),
            ),
          )
        else if (images.length == 1)
          CachedNetworkImage(
            imageUrl: images.first,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          )
        else
          CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder: (context, index, realIndex) {
              return CachedNetworkImage(
                imageUrl: images[index],
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) => onIndexChanged(index),
            ),
          ),
        // Indicadores
        if (images.length > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == entry.key
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        // Badge de descuento
        if (hasDiscount)
          Positioned(
            top: 100,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
              ),
              child: Text(
                '-$discountPercentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SpecificationsSection extends StatelessWidget {
  final ProductEntity product;

  const _SpecificationsSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SpecItem(
                  icon: product.animalType.emoji,
                  label: 'Animal',
                  value: product.animalType.label,
                ),
              ),
              Expanded(
                child: _SpecItem(
                  icon: '📏',
                  label: 'Tamaño',
                  value: product.animalSize.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SpecItem(
                  icon: '🎂',
                  label: 'Edad',
                  value: product.animalAge.label,
                ),
              ),
              Expanded(
                child: _SpecItem(
                  icon: product.category.emoji,
                  label: 'Categoría',
                  value: product.category.label,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;

  const _StockIndicator({required this.stock});

  @override
  Widget build(BuildContext context) {
    final inStock = stock > 0;
    final lowStock = stock > 0 && stock <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inStock
            ? (lowStock
                  ? AppTheme.warningColor.withValues(alpha: 0.1)
                  : AppTheme.successColor.withValues(alpha: 0.1))
            : AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: inStock
                ? (lowStock ? AppTheme.warningColor : AppTheme.successColor)
                : AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Text(
            inStock
                ? (lowStock ? '¡Solo quedan $stock!' : 'En stock')
                : 'Sin stock',
            style: TextStyle(
              color: inStock
                  ? (lowStock ? AppTheme.warningColor : AppTheme.successColor)
                  : AppTheme.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
