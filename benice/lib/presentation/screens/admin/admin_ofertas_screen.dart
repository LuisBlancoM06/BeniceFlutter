import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminOfertasScreen extends ConsumerWidget {
  const AdminOfertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ofertasState = ref.watch(ofertasFlashProvider);
    final productsState = ref.watch(adminProductsProvider);

    final ofertaProducts = productsState.products
        .where((p) => p.hasDiscount)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas Flash')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle ofertas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: ofertasState.isActive
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                      )
                    : null,
                color: ofertasState.isActive ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    ofertasState.isActive
                        ? Icons.local_fire_department
                        : Icons.local_fire_department_outlined,
                    color: ofertasState.isActive ? Colors.white : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ofertas Flash',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ofertasState.isActive
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          ofertasState.isActive
                              ? 'Activas - visibles en la tienda'
                              : 'Desactivadas',
                          style: TextStyle(
                            color: ofertasState.isActive
                                ? Colors.white70
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ofertasState.isActive,
                    onChanged: (_) =>
                        ref.read(ofertasFlashProvider.notifier).toggle(),
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                    activeThumbColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Productos en oferta
            Text(
              'Productos en Oferta (${ofertaProducts.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (ofertaProducts.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay productos en oferta',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    Text(
                      'Edita un producto y asigna un precio de oferta',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...ofertaProducts.map(
                (product) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.price.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
