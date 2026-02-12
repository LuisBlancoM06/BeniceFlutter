import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/order/order_widgets.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus?> _statusFilters = [
    null, // Todos
    OrderStatus.pendiente,
    OrderStatus.pagado,
    OrderStatus.enviado,
    OrderStatus.entregado,
    OrderStatus.cancelado,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(text: 'Todos'),
            ...OrderStatus.values.map(
              (status) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(status.emoji),
                    const SizedBox(width: 4),
                    Text(status.label),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusFilters.map((status) {
          return _OrdersList(statusFilter: status);
        }).toList(),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final OrderStatus? statusFilter;

  const _OrdersList({this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) {
        // Filtrar por estado si es necesario
        final filteredOrders = statusFilter == null
            ? orders
            : orders.where((o) => o.status == statusFilter).toList();

        if (filteredOrders.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: statusFilter == null
                ? 'No tienes pedidos'
                : 'No hay pedidos ${statusFilter!.label.toLowerCase()}s',
            message: statusFilter == null
                ? 'Cuando realices una compra, aparecerá aquí.'
                : 'Los pedidos con este estado aparecerán aquí.',
            actionLabel: statusFilter == null ? 'Ir a la Tienda' : null,
            onAction: statusFilter == null
                ? () => context.go('/products')
                : null,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCard(
                order: order,
                onTap: () => context.push('/orders/${order.id}'),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorState(
        message: 'Error al cargar los pedidos',
        onRetry: () => ref.invalidate(ordersProvider),
      ),
    );
  }
}
