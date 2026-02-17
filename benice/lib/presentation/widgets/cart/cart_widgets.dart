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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con borde suave
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CachedNetworkImage(
                imageUrl: item.product.mainImage,
                memCacheWidth: 200,
                memCacheHeight: 200,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 85, height: 85, color: Colors.grey[50]),
                errorWidget: (context, url, error) => Container(
                  width: 85,
                  height: 85,
                  color: Colors.grey[50],
                  child: Icon(
                    Icons.pets,
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppTheme.errorColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.product.category.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
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
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            width: 38,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
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
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.transparent : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.primaryColor : AppTheme.textLight,
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
    final effectiveShipping = subtotal >= AppConstants.freeShippingMinAmount
        ? 0.0
        : AppConstants.shippingCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF5F3FF), Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
        ),
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
            const SizedBox(height: 10),
            _SummaryRow(
              label: discountCode != null
                  ? 'Descuento ($discountCode)'
                  : 'Descuento',
              value: '-${discount.toStringAsFixed(2)}€',
              valueColor: AppTheme.successColor,
              icon: Icons.discount_outlined,
              iconColor: AppTheme.successColor,
            ),
          ],
          // Envío
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Envío',
            value: effectiveShipping == 0
                ? 'GRATIS'
                : '${effectiveShipping.toStringAsFixed(2)}€',
            valueColor: effectiveShipping == 0 ? AppTheme.successColor : null,
            icon: Icons.local_shipping_outlined,
            iconColor: effectiveShipping == 0
                ? AppTheme.successColor
                : AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          // Divider con gradiente
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${total.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
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
  final IconData? icon;
  final Color? iconColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: iconColor ?? AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
          color: AppTheme.successColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código ${widget.currentCode!.code}',
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${widget.currentCode!.discountPercent.toStringAsFixed(0)}% de descuento aplicado',
                    style: TextStyle(
                      color: AppTheme.successColor.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onRemove != null)
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Código de descuento',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(
                Icons.local_offer_outlined,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              errorText: widget.error,
              filled: true,
              fillColor: const Color(0xFFF5F3FF),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
                : const Text(
                    'Aplicar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}
