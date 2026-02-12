import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProductsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: productsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsState.products.isEmpty
          ? const Center(child: Text('No hay productos'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productsState.products.length,
              itemBuilder: (context, index) {
                final product = productsState.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image),
                            ),
                    ),
                    title: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '${product.finalPrice.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: product.hasDiscount
                                ? AppTheme.errorColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                        if (product.hasDiscount)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${product.price.toStringAsFixed(2)}€',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 5
                                ? AppTheme.successColor.withValues(alpha: 0.1)
                                : product.stock > 0
                                ? AppTheme.warningColor.withValues(alpha: 0.1)
                                : AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: product.stock > 5
                                  ? AppTheme.successColor
                                  : product.stock > 0
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/admin/products/${product.id}');
                        } else if (value == 'delete') {
                          _confirmDelete(
                            context,
                            ref,
                            product.id,
                            product.name,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminProductsProvider.notifier).deleteProduct(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
