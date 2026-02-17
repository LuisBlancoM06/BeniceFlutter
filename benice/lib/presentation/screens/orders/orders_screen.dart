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
    final ordersState = ref.watch(orderProvider);
    final totalOrders = ordersState.orders.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7E22CE), Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Pedidos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          totalOrders == 0
                              ? 'Aún no tienes pedidos'
                              : '$totalOrders pedido${totalOrders != 1 ? 's' : ''} realizados',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tabs: [
                    const Tab(text: 'Todos'),
                    ...OrderStatus.values.map(
                      (status) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(status.label),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _statusFilters.map((status) {
            return _OrdersList(statusFilter: status);
          }).toList(),
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final OrderStatus? statusFilter;

  const _OrdersList({this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(orderProvider);

    if (ordersState.isLoading) {
      return const LoadingIndicator();
    }

    if (ordersState.errorMessage != null) {
      return ErrorState(
        message: 'Error al cargar los pedidos',
        onRetry: () => ref.read(orderProvider.notifier).refresh(),
      );
    }

    final orders = ordersState.orders;

    // Filtrar por estado si es necesario
    final filteredOrders = statusFilter == null
        ? orders
        : orders.where((o) => o.status == statusFilter).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusFilter == null
                      ? Icons.shopping_bag_outlined
                      : Icons.inbox_outlined,
                  size: 56,
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                statusFilter == null
                    ? 'No tienes pedidos'
                    : 'Sin pedidos ${statusFilter!.label.toLowerCase()}s',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusFilter == null
                    ? 'Cuando realices una compra, aparecerá aquí'
                    : 'Los pedidos con este estado aparecerán aquí',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (statusFilter == null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/products'),
                  icon: const Icon(Icons.storefront, size: 20),
                  label: const Text('Explorar Tienda'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OrderCard(
            order: order,
            onTap: () => context.push('/orders/${order.id}'),
          ),
        );
      },
    );
  }
}
