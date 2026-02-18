import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _promoController = TextEditingController();
  bool _isProcessing = false;
  int _currentStep = 0;
  bool _hasInitializedFromUser = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.cart;
    final authState = ref.watch(authProvider);

    if (authState.user != null && !_hasInitializedFromUser) {
      _hasInitializedFromUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameController.text = authState.user!.name ?? '';
        _phoneController.text = authState.user!.phone ?? '';
        if (authState.user!.address != null) {
          _addressController.text = authState.user!.address!;
        }
        if (authState.user!.city != null) {
          _cityController.text = authState.user!.city!;
        }
        if (authState.user!.postalCode != null) {
          _postalCodeController.text = authState.user!.postalCode!;
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Finalizar Compra',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: cart.items.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Carrito vacío',
              message: 'Añade productos antes de continuar',
            )
          : Column(
              children: [
                // Step indicator
                _buildStepIndicator(),
                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentStep == 0) ...[
                            _buildShippingForm(),
                          ] else if (_currentStep == 1) ...[
                            _buildOrderReview(cart, cartState),
                          ] else ...[
                            _buildPaymentSection(cart, cartState),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom bar
                _buildBottomBar(cart, cartState),
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Envio', 'Revision', 'Pago'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                GestureDetector(
                  onTap: index < _currentStep
                      ? () => setState(() => _currentStep = index)
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      border: isCurrent
                          ? Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: index < _currentStep
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.local_shipping_outlined,
          title: 'Datos de Envio',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Nombre completo',
          icon: Icons.person_outline,
          validator: (value) =>
              value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _phoneController,
          label: 'Telefono',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingresa tu telefono';
            if (value.length < 9) return 'Numero invalido';
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _addressController,
          label: 'Direccion',
          icon: Icons.home_outlined,
          validator: (value) =>
              value == null || value.isEmpty ? 'Ingresa tu direccion' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _cityController,
                label: 'Ciudad',
                icon: Icons.location_city_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'C.P.',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _notesController,
          label: 'Notas del pedido (opcional)',
          icon: Icons.note_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildOrderReview(CartEntity cart, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.receipt_long_outlined,
          title: 'Resumen del Pedido',
        ),
        const SizedBox(height: 16),
        // Items
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              ...cart.items.map((item) => _buildCartItem(item)),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Subtotal',
                value: '${cart.subtotal.toStringAsFixed(2)}\u20AC',
              ),
              if (cartState.discount > 0)
                _SummaryRow(
                  label: 'Descuento (${cartState.discountCode?.code})',
                  value: '-${cartState.discount.toStringAsFixed(2)}\u20AC',
                  valueColor: AppTheme.successColor,
                ),
              _SummaryRow(
                label: 'Envio',
                value: cart.subtotal >= AppConstants.freeShippingMinAmount
                    ? 'Gratis'
                    : '${AppConstants.shippingCost.toStringAsFixed(2)}\u20AC',
                valueColor: cart.subtotal >= AppConstants.freeShippingMinAmount
                    ? AppTheme.successColor
                    : null,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_calculateTotal(cart, cartState).toStringAsFixed(2)}\u20AC',
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
        ),
        // Free shipping progress
        if (cart.subtotal < AppConstants.freeShippingMinAmount) ...[
          const SizedBox(height: 12),
          _buildFreeShippingProgress(cart.subtotal),
        ],
        const SizedBox(height: 24),
        // Promo code
        const _SectionTitle(
          icon: Icons.local_offer_outlined,
          title: 'Codigo Promocional',
        ),
        const SizedBox(height: 12),
        _buildPromoCodeSection(cartState),
        const SizedBox(height: 24),
        // Shipping info summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Direccion de envio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _nameController.text,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              Text(
                _phoneController.text,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              Text(
                '${_addressController.text}, ${_cityController.text} ${_postalCodeController.text}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(CartEntity cart, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.payment, title: 'Pago Seguro'),
        const SizedBox(height: 16),
        // Total to pay
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_calculateTotal(cart, cartState).toStringAsFixed(2)}\u20AC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Trust badges
        _buildTrustBadges(),
        const SizedBox(height: 24),
        // Payment methods
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.credit_card, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Métodos de pago aceptados',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PaymentMethodChip(label: 'Visa', icon: Icons.credit_card),
                  _PaymentMethodChip(
                    label: 'Mastercard',
                    icon: Icons.credit_card,
                  ),
                  _PaymentMethodChip(
                    label: 'Apple Pay',
                    icon: Icons.phone_iphone,
                  ),
                  _PaymentMethodChip(label: 'Google', icon: Icons.g_mobiledata),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Stripe button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processOrder,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock, color: Colors.white),
            label: Text(
              _isProcessing ? 'Procesando...' : 'Pagar con Stripe',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF635BFF), // Stripe purple
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: AppTheme.textSecondary),
            SizedBox(width: 6),
            Text(
              'Pago seguro con encriptacion SSL 256-bit',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Powered by Stripe',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      children: [
        Expanded(
          child: _TrustBadge(
            icon: Icons.verified_user,
            label: 'SSL 256-bit',
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TrustBadge(
            icon: Icons.replay_30,
            label: '14 días devolución',
            color: AppTheme.infoColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TrustBadge(
            icon: Icons.support_agent,
            label: 'Soporte 24/7',
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeShippingProgress(double subtotal) {
    final remaining = AppConstants.freeShippingMinAmount - subtotal;
    final progress = subtotal / AppConstants.freeShippingMinAmount;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 16,
                color: AppTheme.infoColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Anade ${remaining.toStringAsFixed(2)}\u20AC mas para envio gratis',
                style: const TextStyle(
                  color: AppTheme.infoColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.infoColor.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.infoColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(CartState cartState) {
    if (cartState.discountCode != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Codigo "${cartState.discountCode!.code}" aplicado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${cartState.discountCode!.discountPercent.toInt()}% de descuento',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () =>
                  ref.read(cartProvider.notifier).removeDiscountCode(),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _promoController,
            decoration: InputDecoration(
              hintText: 'Introduce tu codigo',
              prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: cartState.isApplyingDiscount
              ? null
              : () {
                  if (_promoController.text.isNotEmpty) {
                    ref
                        .read(cartProvider.notifier)
                        .applyDiscountCode(_promoController.text.trim());
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: cartState.isApplyingDiscount
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Aplicar'),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: item.product.images.isNotEmpty
                  ? DecorationImage(
                      image: ResizeImage(
                        CachedNetworkImageProvider(item.product.images.first),
                        width: 100,
                        height: 100,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.product.images.isEmpty
                ? const Icon(Icons.pets, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'x${item.quantity}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(2)}\u20AC',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartEntity cart, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _currentStep = _currentStep - 1),
                  child: const Text('Atras'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            if (_currentStep < 2)
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _currentStep = 1);
                      }
                    } else {
                      setState(() => _currentStep = 2);
                    }
                  },
                  child: Text(
                    _currentStep == 0 ? 'Revisar pedido' : 'Ir al pago',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        ),
      ),
    );
  }

  double _calculateTotal(CartEntity cart, CartState cartState) {
    double total = cart.subtotal - cartState.discount;
    if (cart.subtotal < AppConstants.freeShippingMinAmount) {
      total += AppConstants.shippingCost;
    }
    return total;
  }

  Future<void> _processOrder() async {
    setState(() => _isProcessing = true);

    try {
      final cartState = ref.read(cartProvider);
      final cart = cartState.cart;

      // Create order
      final result = await ref
          .read(orderProvider.notifier)
          .createOrder(
            cart: cart,
            shippingAddress:
                '${_addressController.text}, ${_cityController.text} ${_postalCodeController.text}',
          );

      result.fold(
        (failure) {
          CustomSnackBar.showError(context, failure.message);
        },
        (order) {
          ref.read(cartProvider.notifier).clearCart();
          context.go('/checkout/success?orderId=${order.id}');
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PaymentMethodChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
