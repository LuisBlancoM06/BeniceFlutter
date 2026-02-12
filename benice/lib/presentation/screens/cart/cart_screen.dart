import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/cart/cart_widgets.dart';
import '../../widgets/common/common_widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Carrito',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vaciar Carrito'),
                    content: const Text(
                      '¿Estás seguro de que deseas eliminar todos los productos del carrito?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Vaciar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
              ),
              label: const Text(
                'Vaciar',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Tu carrito está vacío',
              message: 'Añade productos a tu carrito para empezar a comprar.',
              actionLabel: 'Ver Productos',
              onAction: () => context.go('/products'),
            )
          : Column(
              children: [
                // Lista de productos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemCard(
                          item: item,
                          onQuantityChanged: (quantity) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.product.id, quantity);
                          },
                          onRemove: () {
                            ref
                                .read(cartProvider.notifier)
                                .removeFromCart(item.product.id);
                            CustomSnackBar.showInfo(
                              context,
                              '${item.product.name} eliminado del carrito',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Código de descuento y resumen
                Container(
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Código de descuento
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: DiscountCodeInput(
                            currentCode: cartState.discountCode,
                            isLoading: cartState.isApplyingDiscount,
                            error: cartState.discountError,
                            onApply: (code) {
                              ref
                                  .read(cartProvider.notifier)
                                  .applyDiscountCode(code);
                            },
                            onRemove: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .removeDiscountCode();
                            },
                          ),
                        ),
                        // Resumen
                        CartSummary(
                          subtotal: cart.subtotal,
                          discount: cartState.discount,
                          discountCode: cartState.discountCode?.code,
                          total: cart.subtotal - cartState.discount,
                        ),
                        // Botón checkout
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: PrimaryButton(
                            label: 'Continuar con la Compra',
                            icon: Icons.arrow_forward,
                            onPressed: () => context.push('/checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
