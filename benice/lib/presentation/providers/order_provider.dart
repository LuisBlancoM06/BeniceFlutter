import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

/// Estado de pedidos
class OrdersState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrdersState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para pedidos
class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    Future.microtask(() => _loadOrders());
    return const OrdersState(isLoading: true);
  }

  Future<void> _loadOrders() async {
    state = state.copyWith(isLoading: true);

    final result = await ref.read(orderRepositoryProvider).getOrders();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(orders: orders, isLoading: false),
    );
  }

  Future<void> refresh() async {
    await _loadOrders();
  }

  Future<Either<Failure, OrderEntity>> createOrder({
    required CartEntity cart,
    required String shippingAddress,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(orderRepositoryProvider)
        .createOrder(cart: cart, shippingAddress: shippingAddress);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (order) {
        state = state.copyWith(
          orders: [order, ...state.orders],
          isLoading: false,
        );
      },
    );

    return result;
  }

  Future<Either<Failure, OrderEntity>> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true);

    final result = await ref.read(orderRepositoryProvider).cancelOrder(orderId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (cancelledOrder) {
        final updatedOrders = state.orders.map((order) {
          if (order.id == orderId) {
            return cancelledOrder;
          }
          return order;
        }).toList();

        state = state.copyWith(orders: updatedOrders, isLoading: false);
      },
    );

    return result;
  }

  Future<Either<Failure, OrderEntity>> requestReturn(String orderId) async {
    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(orderRepositoryProvider)
        .requestReturn(orderId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (returnedOrder) {
        final updatedOrders = state.orders.map((order) {
          if (order.id == orderId) {
            return returnedOrder;
          }
          return order;
        }).toList();

        state = state.copyWith(orders: updatedOrders, isLoading: false);
      },
    );

    return result;
  }
}

/// Provider de pedidos
final orderProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

/// Provider para detalle de pedido
final orderDetailProvider = FutureProvider.autoDispose
    .family<OrderEntity?, String>((ref, orderId) async {
      final result = await ref
          .read(orderRepositoryProvider)
          .getOrderById(orderId);
      return result.fold((failure) => null, (order) => order);
    });
