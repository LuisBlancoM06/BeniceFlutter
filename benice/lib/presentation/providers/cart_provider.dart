import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

/// Estado del carrito
class CartState {
  final CartEntity cart;
  final DiscountCodeEntity? discountCode;
  final double discount;
  final bool isApplyingDiscount;
  final String? discountError;

  const CartState({
    this.cart = const CartEntity(items: []),
    this.discountCode,
    this.discount = 0.0,
    this.isApplyingDiscount = false,
    this.discountError,
  });

  CartState copyWith({
    CartEntity? cart,
    DiscountCodeEntity? discountCode,
    bool clearDiscountCode = false,
    double? discount,
    bool? isApplyingDiscount,
    String? discountError,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      discountCode: clearDiscountCode
          ? null
          : (discountCode ?? this.discountCode),
      discount: discount ?? this.discount,
      isApplyingDiscount: isApplyingDiscount ?? this.isApplyingDiscount,
      discountError: discountError,
    );
  }
}

/// Notifier para el carrito
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    Future.microtask(() => _loadCart());
    return const CartState();
  }

  Future<void> _loadCart() async {
    final result = await ref.read(cartRepositoryProvider).getCart();
    result.fold((failure) {}, (cart) => state = state.copyWith(cart: cart));
  }

  void addToCart(ProductEntity product, {int quantity = 1}) {
    final existingIndex = state.cart.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    List<CartItemEntity> newItems;

    if (existingIndex >= 0) {
      newItems = [...state.cart.items];
      final existingItem = newItems[existingIndex];
      newItems[existingIndex] = CartItemEntity(
        id: existingItem.id,
        product: existingItem.product,
        quantity: existingItem.quantity + quantity,
      );
    } else {
      newItems = [
        ...state.cart.items,
        CartItemEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
        ),
      ];
    }

    state = state.copyWith(cart: CartEntity(items: newItems));
    _recalculateDiscount();
    _saveCart();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final newItems = state.cart.items.map((item) {
      if (item.product.id == productId) {
        return CartItemEntity(
          id: item.id,
          product: item.product,
          quantity: quantity,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(cart: CartEntity(items: newItems));
    _recalculateDiscount();
    _saveCart();
  }

  void removeFromCart(String productId) {
    final newItems = state.cart.items
        .where((item) => item.product.id != productId)
        .toList();

    state = state.copyWith(cart: CartEntity(items: newItems));
    _recalculateDiscount();
    _saveCart();
  }

  void clearCart() {
    state = const CartState();
    _saveCart();
  }

  Future<void> applyDiscountCode(String code) async {
    state = state.copyWith(isApplyingDiscount: true, discountError: null);

    final result = await ref
        .read(discountRepositoryProvider)
        .validateDiscountCode(code, state.cart.subtotal);

    result.fold(
      (failure) => state = state.copyWith(
        isApplyingDiscount: false,
        discountError: failure.message,
      ),
      (discountCode) {
        final discount =
            state.cart.subtotal * (discountCode.discountPercent / 100);

        state = state.copyWith(
          isApplyingDiscount: false,
          discountCode: discountCode,
          discount: discount,
        );
      },
    );
  }

  void removeDiscountCode() {
    state = state.copyWith(
      clearDiscountCode: true,
      discount: 0.0,
      discountError: null,
    );
  }

  void _saveCart() {
    ref.read(cartRepositoryProvider).saveCartLocally(state.cart);
  }

  void _recalculateDiscount() {
    if (state.discountCode != null) {
      final discount =
          state.cart.subtotal * (state.discountCode!.discountPercent / 100);
      state = state.copyWith(discount: discount);
    }
  }
}

/// Provider del carrito
final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// Provider del número de items en el carrito
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).cart.itemCount;
});

/// Provider del total del carrito
final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.cart.subtotal - cartState.discount + cartState.cart.shippingCost;
});
