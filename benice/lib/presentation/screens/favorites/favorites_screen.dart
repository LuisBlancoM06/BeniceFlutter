import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/product/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);
    final productsState = ref.watch(productsProvider);
    final favoriteProducts = productsState.products
        .where((p) => favState.favoriteIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Favoritos (${favoriteProducts.length})',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          if (favoriteProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpiar favoritos',
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes favoritos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explora productos y añade tus favoritos',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/products'),
                    icon: const Icon(Icons.storefront),
                    label: const Text('Ver Productos'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: favoriteProducts[index]),
            ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar favoritos'),
        content: const Text('¿Eliminar todos los productos de favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
