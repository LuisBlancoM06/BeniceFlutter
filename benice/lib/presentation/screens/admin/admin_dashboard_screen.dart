import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: dashState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminDashboardProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards
                    _buildKPIGrid(dashState.stats),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Pedidos por estado
                    const Text(
                      'Pedidos por Estado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOrderStatusCards(dashState.stats.ordersByStatus),
                    const SizedBox(height: 24),

                    // Ventas por mes
                    const Text(
                      'Ventas por Mes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSalesChart(dashState.stats.salesByMonth),
                    const SizedBox(height: 24),

                    // Pedidos recientes
                    const Text(
                      'Pedidos Recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashState.stats.recentOrders.map(
                      (order) => _buildRecentOrderTile(context, order),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKPIGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _KPICard(
          title: 'Ventas Totales',
          value: '${stats.totalSales.toStringAsFixed(2)}€',
          icon: Icons.euro,
          color: AppTheme.successColor,
        ),
        _KPICard(
          title: 'Pedidos',
          value: stats.totalOrders.toString(),
          icon: Icons.shopping_bag,
          color: AppTheme.primaryColor,
        ),
        _KPICard(
          title: 'Productos',
          value: stats.totalProducts.toString(),
          icon: Icons.inventory_2,
          color: AppTheme.secondaryColor,
        ),
        _KPICard(
          title: 'Stock Bajo',
          value: stats.lowStockProducts.toString(),
          icon: Icons.warning_amber,
          color: stats.lowStockProducts > 0
              ? AppTheme.errorColor
              : AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        'Productos',
        Icons.inventory,
        '/admin/products',
        AppTheme.primaryColor,
      ),
      _QuickAction(
        'Pedidos',
        Icons.receipt_long,
        '/admin/orders',
        AppTheme.secondaryColor,
      ),
      _QuickAction(
        'Ofertas',
        Icons.local_offer,
        '/admin/ofertas',
        const Color(0xFFF59E0B),
      ),
      _QuickAction(
        'Newsletter',
        Icons.email,
        '/admin/newsletter',
        AppTheme.secondaryColor,
      ),
      _QuickAction(
        'Devoluciones',
        Icons.assignment_return,
        '/admin/returns',
        AppTheme.errorColor,
      ),
      _QuickAction(
        'Ajustes',
        Icons.settings,
        '/admin/settings',
        AppTheme.textSecondary,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: actions.map((a) => _buildActionCard(context, a)).toList(),
    );
  }

  Widget _buildActionCard(BuildContext context, _QuickAction action) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          border: Border.all(color: action.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 28),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCards(Map<String, int> statuses) {
    final statusColors = {
      'pendiente': const Color(0xFFFFA726),
      'pagado': const Color(0xFF42A5F5),
      'enviado': const Color(0xFF7E57C2),
      'entregado': const Color(0xFF66BB6A),
      'cancelado': const Color(0xFFEF5350),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.entries
          .map(
            (e) => Chip(
              avatar: CircleAvatar(
                backgroundColor: statusColors[e.key] ?? Colors.grey,
                radius: 12,
                child: Text(
                  '${e.value}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              label: Text(e.key[0].toUpperCase() + e.key.substring(1)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSalesChart(Map<String, double> salesByMonth) {
    if (salesByMonth.isEmpty) return const SizedBox.shrink();
    final maxSales = salesByMonth.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: salesByMonth.entries.map((e) {
          final percentage = maxSales > 0 ? e.value / maxSales : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(e.key, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primaryColor,
                      minHeight: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${e.value.toStringAsFixed(0)}€',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentOrderTile(BuildContext context, dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order.status.color.withValues(alpha: 0.2),
          child: Text(order.status.emoji, style: const TextStyle(fontSize: 16)),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${order.total.toStringAsFixed(2)}€ · ${order.status.label}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/admin/orders'),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: color, size: 24)],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _QuickAction(this.label, this.icon, this.route, this.color);
}
