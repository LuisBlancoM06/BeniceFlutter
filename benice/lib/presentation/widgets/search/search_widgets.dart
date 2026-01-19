import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';

/// Item del resultado de búsqueda
class SearchResultItem extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const SearchResultItem({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: product.mainImage,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(width: 50, height: 50, color: Colors.grey[200]),
          errorWidget: (context, url, error) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: const Icon(Icons.pets, color: Colors.grey),
          ),
        ),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${product.category.label} • ${product.animalType.label}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (product.hasDiscount) ...[
            Text(
              '${product.price.toStringAsFixed(2)}€',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textLight,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
          Text(
            '${product.finalPrice.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: product.hasDiscount
                  ? AppTheme.errorColor
                  : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delegate para el buscador en AppBar
class ProductSearchDelegate extends SearchDelegate<ProductEntity?> {
  final Future<List<ProductEntity>> Function(String query) onSearch;
  final void Function(ProductEntity product) onProductSelected;

  ProductSearchDelegate({
    required this.onSearch,
    required this.onProductSelected,
  });

  @override
  String get searchFieldLabel => 'Buscar productos...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppTheme.textLight),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Busca productos para tu mascota',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<ProductEntity>>(
      future: onSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Error al buscar productos'),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron resultados para "$query"',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: products.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final product = products[index];
            return SearchResultItem(
              product: product,
              onTap: () {
                onProductSelected(product);
                close(context, product);
              },
            );
          },
        );
      },
    );
  }
}

/// Barra de búsqueda inline
class InlineSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;

  const InlineSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'Buscar productos...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textLight),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
