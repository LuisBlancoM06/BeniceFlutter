import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';

/// Tarjeta de item del carrito
class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
            child: CachedNetworkImage(
              imageUrl: item.product.mainImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: 80, height: 80, color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.pets),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.animalType.emoji} ${item.product.category.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Selector de cantidad
                    if (onQuantityChanged != null)
                      _QuantitySelector(
                        quantity: item.quantity,
                        onChanged: onQuantityChanged!,
                      )
                    else
                      Text(
                        'Cantidad: ${item.quantity}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    // Precio
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.product.hasDiscount)
                          Text(
                            '${(item.product.price * item.quantity).toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.product.hasDiscount
                                ? AppTheme.errorColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            onTap: quantity < AppConstants.maxQuantityPerProduct
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.grey[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm - 2),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.textPrimary : AppTheme.textLight,
        ),
      ),
    );
  }
}

/// Resumen del carrito
class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final String? discountCode;
  final double total;
  final double shippingCost;

  const CartSummary({
    super.key,
    required this.subtotal,
    this.discount = 0.0,
    this.discountCode,
    required this.total,
    this.shippingCost = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final shipping = subtotal >= 49 ? 0.0 : 4.99;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _SummaryRow(
            label: 'Subtotal',
            value: '${subtotal.toStringAsFixed(2)}€',
          ),
          // Descuento
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: discountCode != null
                  ? 'Descuento ($discountCode)'
                  : 'Descuento',
              value: '-${discount.toStringAsFixed(2)}€',
              valueColor: AppTheme.successColor,
            ),
          ],
          // Envío
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Envío',
            value: shipping == 0 ? 'Gratis' : '${shipping.toStringAsFixed(2)}€',
            valueColor: shipping == 0 ? AppTheme.successColor : null,
          ),
          if (shipping > 0) ...[
            const SizedBox(height: 4),
            const Text(
              'Envío gratis en pedidos superiores a 49€',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
          const Divider(height: 24),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${total.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Widget para aplicar código de descuento
class DiscountCodeInput extends StatefulWidget {
  final DiscountCodeEntity? currentCode;
  final bool isLoading;
  final String? error;
  final Function(String code) onApply;
  final VoidCallback? onRemove;

  const DiscountCodeInput({
    super.key,
    this.currentCode,
    this.isLoading = false,
    this.error,
    required this.onApply,
    this.onRemove,
  });

  @override
  State<DiscountCodeInput> createState() => _DiscountCodeInputState();
}

class _DiscountCodeInputState extends State<DiscountCodeInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    if (_controller.text.isEmpty) return;
    widget.onApply(_controller.text.toUpperCase());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentCode != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código ${widget.currentCode!.code} aplicado',
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.onRemove != null)
              GestureDetector(
                onTap: widget.onRemove,
                child: const Icon(
                  Icons.close,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Código de descuento',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                  errorText: widget.error,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.isLoading ? null : _apply,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Aplicar'),
            ),
          ],
        ),
      ],
    );
  }
}
