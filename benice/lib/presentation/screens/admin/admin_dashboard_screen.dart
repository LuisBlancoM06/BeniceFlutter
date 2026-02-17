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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente premium
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF1E1B4B),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
                onPressed: () =>
                    ref.read(adminDashboardProvider.notifier).refresh(),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern decorativo
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      bottom: 10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.dashboard_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Panel de Administración',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Gestiona tu tienda Benice',
                                      style: TextStyle(
                                        color: Color(0xFFA5B4FC),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),

          // Contenido
          dashState.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPIs flotantes
                        Transform.translate(
                          offset: const Offset(0, -24),
                          child: _buildKPIGrid(dashState.stats, screenWidth),
                        ),

                        // Acciones Rápidas
                        _sectionTitle('Acciones Rápidas', Icons.bolt_rounded),
                        const SizedBox(height: 12),
                        _buildQuickActions(context, screenWidth),
                        const SizedBox(height: 28),

                        // Pedidos por estado
                        _sectionTitle(
                          'Pedidos por Estado',
                          Icons.pie_chart_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildOrderStatusCards(dashState.stats.ordersByStatus),
                        const SizedBox(height: 28),

                        // Ventas por mes
                        _sectionTitle(
                          'Ventas por Mes',
                          Icons.bar_chart_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildSalesChart(dashState.stats.salesByMonth),
                        const SizedBox(height: 28),

                        // Pedidos recientes
                        _sectionTitle(
                          'Pedidos Recientes',
                          Icons.history_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildRecentOrders(
                          context,
                          dashState.stats.recentOrders,
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid(DashboardStats stats, double screenWidth) {
    final kpis = [
      _KPIData(
        'Ventas Totales',
        '${stats.totalSales.toStringAsFixed(2)}€',
        Icons.euro_rounded,
        const Color(0xFF10B981),
        const Color(0xFFD1FAE5),
      ),
      _KPIData(
        'Pedidos',
        stats.totalOrders.toString(),
        Icons.shopping_bag_rounded,
        const Color(0xFF7C3AED),
        const Color(0xFFEDE9FE),
      ),
      _KPIData(
        'Productos',
        stats.totalProducts.toString(),
        Icons.inventory_2_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      ),
      _KPIData(
        'Stock Bajo',
        stats.lowStockProducts.toString(),
        Icons.warning_amber_rounded,
        stats.lowStockProducts > 0
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        stats.lowStockProducts > 0
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFD1FAE5),
      ),
    ];

    return GridView.count(
      crossAxisCount: screenWidth > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: screenWidth > 600 ? 1.6 : 1.4,
      children: kpis.map((kpi) => _KPICard(data: kpi)).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context, double screenWidth) {
    final actions = [
      _QuickAction(
        'Productos',
        Icons.inventory_2_rounded,
        '/admin/products',
        const Color(0xFF7C3AED),
        const Color(0xFFEDE9FE),
      ),
      _QuickAction(
        'Pedidos',
        Icons.receipt_long_rounded,
        '/admin/orders',
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      ),
      _QuickAction(
        'Ofertas',
        Icons.local_fire_department_rounded,
        '/admin/ofertas',
        const Color(0xFFEF4444),
        const Color(0xFFFEE2E2),
      ),
      _QuickAction(
        'Newsletter',
        Icons.mail_rounded,
        '/admin/newsletter',
        const Color(0xFF3B82F6),
        const Color(0xFFDBEAFE),
      ),
      _QuickAction(
        'Devoluciones',
        Icons.assignment_return_rounded,
        '/admin/returns',
        const Color(0xFFEC4899),
        const Color(0xFFFCE7F3),
      ),
      _QuickAction(
        'Facturas',
        Icons.receipt_rounded,
        '/admin/invoices',
        const Color(0xFF10B981),
        const Color(0xFFD1FAE5),
      ),
      _QuickAction(
        'Visitas',
        Icons.analytics_rounded,
        '/admin/visits',
        const Color(0xFF6366F1),
        const Color(0xFFE0E7FF),
      ),
      _QuickAction(
        'Ajustes',
        Icons.tune_rounded,
        '/admin/settings',
        const Color(0xFF64748B),
        const Color(0xFFF1F5F9),
      ),
    ];

    return GridView.count(
      crossAxisCount: screenWidth > 600 ? 4 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: actions.map((a) => _buildActionCard(context, a)).toList(),
    );
  }

  Widget _buildActionCard(BuildContext context, _QuickAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(action.route),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCards(Map<String, int> statuses) {
    final statusConfig = {
      'pendiente': (const Color(0xFFFFA726), Icons.hourglass_empty_rounded),
      'pagado': (const Color(0xFF42A5F5), Icons.credit_card_rounded),
      'enviado': (const Color(0xFF7E57C2), Icons.local_shipping_rounded),
      'entregado': (const Color(0xFF66BB6A), Icons.check_circle_rounded),
      'cancelado': (const Color(0xFFEF5350), Icons.cancel_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: statuses.entries.map((e) {
          final config = statusConfig[e.key];
          final color = config?.$1 ?? Colors.grey;
          final icon = config?.$2 ?? Icons.circle;
          final total = statuses.values.fold(0, (a, b) => a + b);
          final pct = total > 0 ? e.value / total : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key[0].toUpperCase() + e.key.substring(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${e.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSalesChart(Map<String, double> salesByMonth) {
    if (salesByMonth.isEmpty) return const SizedBox.shrink();
    final maxSales = salesByMonth.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: salesByMonth.entries.map((e) {
            final heightFraction = maxSales > 0 ? e.value / maxSales : 0.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${e.value.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: (170 * heightFraction).clamp(4.0, 170.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<dynamic> orders) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No hay pedidos recientes',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: orders.asMap().entries.map((entry) {
          final order = entry.value;
          final isLast = entry.key == orders.length - 1;

          return InkWell(
            onTap: () => context.push('/admin/orders'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (order.status.color as Color).withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      order.status.icon,
                      size: 18,
                      color: order.status.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: order.status.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KPIData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _KPIData(this.title, this.value, this.icon, this.color, this.bgColor);
}

class _KPICard extends StatelessWidget {
  final _KPIData data;

  const _KPICard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const Spacer(),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: data.color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
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
  final Color bgColor;
  const _QuickAction(
    this.label,
    this.icon,
    this.route,
    this.color,
    this.bgColor,
  );
}
