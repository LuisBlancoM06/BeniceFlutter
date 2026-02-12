import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(adminOrdersProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Pedidos'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) {
              final statuses = [
                null,
                'pendiente',
                'pagado',
                'enviado',
                'entregado',
                'cancelado',
              ];
              ref
                  .read(adminOrdersProvider.notifier)
                  .filterByStatus(statuses[index]);
            },
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: '⏳ Pendiente'),
              Tab(text: '💳 Pagado'),
              Tab(text: '📦 Enviado'),
              Tab(text: '✅ Entregado'),
              Tab(text: '❌ Cancelado'),
            ],
          ),
        ),
        body: ordersState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ordersState.orders.isEmpty
            ? const Center(child: Text('No hay pedidos'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ordersState.orders.length,
                itemBuilder: (context, index) {
                  final order = ordersState.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: order.status.color.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(order.status.emoji),
                      ),
                      title: Text(
                        order.orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.total.toStringAsFixed(2)}€ · ${order.items.length} items',
                          ),
                          Text(
                            order.status.label,
                            style: TextStyle(
                              color: order.status.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Items del pedido
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${item.quantity}x ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(child: Text(item.productName)),
                                      Text(
                                        '${item.totalPrice.toStringAsFixed(2)}€',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${order.total.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dirección: ${order.shippingAddress}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (order.notes != null)
                                Text(
                                  'Notas: ${order.notes}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Botones de acción
                              Wrap(
                                spacing: 8,
                                children: _buildActionButtons(
                                  context,
                                  ref,
                                  order,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic order,
  ) {
    final buttons = <Widget>[];
    final notifier = ref.read(adminOrdersProvider.notifier);

    if (order.status == OrderStatus.pendiente) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Marcar Pagado'),
          onPressed: () => notifier.updateOrderStatus(order.id, 'pagado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
          ),
        ),
      );
    }
    if (order.status == OrderStatus.pagado) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.local_shipping, size: 16),
          label: const Text('Marcar Enviado'),
          onPressed: () => notifier.updateOrderStatus(order.id, 'enviado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7E57C2),
          ),
        ),
      );
    }
    if (order.status == OrderStatus.enviado) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Marcar Entregado'),
          onPressed: () => notifier.updateOrderStatus(order.id, 'entregado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
          ),
        ),
      );
    }
    return buttons;
  }
}
