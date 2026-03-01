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
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dashState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : dashState.error != null
          ? _buildErrorState(dashState.error!, ref)
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: () =>
                  ref.read(adminDashboardProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Header compacto ──
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppTheme.primaryDarker,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/'),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                        onPressed: () =>
                            ref.read(adminDashboardProvider.notifier).refresh(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryDarker,
                              AppTheme.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Panel de Administración',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Resumen de tu tienda',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Contenido ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // KPIs
                        _buildKPIGrid(dashState.stats, isWide),
                        const SizedBox(height: 28),

                        // Acciones rápidas
                        _buildSectionHeader(
                          'Acciones Rápidas',
                          Icons.grid_view_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildQuickActions(context, isWide),
                        const SizedBox(height: 28),

                        // Layout responsive: lado a lado en desktop
                        if (isWide) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      'Estado de Pedidos',
                                      Icons.pie_chart_outline_rounded,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildOrderStatusCards(
                                      dashState.stats.ordersByStatus,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      'Ventas por Mes',
                                      Icons.show_chart_rounded,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSalesChart(
                                      dashState.stats.salesByMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildSectionHeader(
                            'Estado de Pedidos',
                            Icons.pie_chart_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildOrderStatusCards(
                            dashState.stats.ordersByStatus,
                          ),
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            'Ventas por Mes',
                            Icons.show_chart_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildSalesChart(dashState.stats.salesByMonth),
                        ],
                        const SizedBox(height: 28),

                        // Pedidos recientes
                        _buildSectionHeader(
                          'Pedidos Recientes',
                          Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildRecentOrders(
                          context,
                          dashState.stats.recentOrders,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────
  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Error al cargar el dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(adminDashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ─── KPI Grid ─────────────────────────────────────────────────
  Widget _buildKPIGrid(DashboardStats stats, bool isWide) {
    final kpis = [
      _KPIData(
        'Ventas Totales',
        '${stats.totalSales.toStringAsFixed(2)}€',
        Icons.euro_rounded,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
      ),
      _KPIData(
        'Pedidos',
        stats.totalOrders.toString(),
        Icons.shopping_bag_rounded,
        AppTheme.primaryColor,
        const Color(0xFFF3E8FF),
      ),
      _KPIData(
        'Productos',
        stats.totalProducts.toString(),
        Icons.inventory_2_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFFFBEB),
      ),
      _KPIData(
        'Stock Bajo',
        stats.lowStockProducts.toString(),
        Icons.warning_amber_rounded,
        stats.lowStockProducts > 0
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        stats.lowStockProducts > 0
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFECFDF5),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = isWide ? 4 : 2;
        final spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        final cardHeight = isWide ? cardWidth / 1.8 : 100.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: kpis.map((kpi) {
            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _KPICard(data: kpi),
            );
          }).toList(),
        );
      },
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, bool isWide) {
    final actions = [
      _QuickAction(
        'Productos',
        Icons.inventory_2_rounded,
        '/admin/products',
        AppTheme.primaryColor,
      ),
      _QuickAction(
        'Pedidos',
        Icons.receipt_long_rounded,
        '/admin/orders',
        const Color(0xFFF59E0B),
      ),
      _QuickAction(
        'Ofertas',
        Icons.local_offer_rounded,
        '/admin/ofertas',
        const Color(0xFFEF4444),
      ),
      _QuickAction(
        'Newsletter',
        Icons.mail_outline_rounded,
        '/admin/newsletter',
        const Color(0xFF3B82F6),
      ),
      _QuickAction(
        'Devoluciones',
        Icons.assignment_return_rounded,
        '/admin/returns',
        const Color(0xFFEC4899),
      ),
      _QuickAction(
        'Facturas',
        Icons.receipt_outlined,
        '/admin/invoices',
        const Color(0xFF10B981),
      ),
      _QuickAction(
        'Visitas',
        Icons.analytics_outlined,
        '/admin/visits',
        const Color(0xFF6366F1),
      ),
      _QuickAction(
        'Ajustes',
        Icons.settings_outlined,
        '/admin/settings',
        const Color(0xFF64748B),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: isWide ? 4 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isWide ? 2.0 : 1.0,
        children: actions.map((a) => _buildActionChip(context, a)).toList(),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, _QuickAction action) {
    return Material(
      color: action.color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: 22),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: action.color,
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

  // ─── Order Status ─────────────────────────────────────────────
  Widget _buildOrderStatusCards(Map<String, int> statuses) {
    final statusConfig = {
      'pagado': (const Color(0xFF3B82F6), Icons.credit_card_rounded),
      'enviado': (AppTheme.primaryColor, Icons.local_shipping_rounded),
      'entregado': (
        const Color(0xFF10B981),
        Icons.check_circle_outline_rounded,
      ),
      'cancelado': (const Color(0xFFEF4444), Icons.cancel_outlined),
    };

    final total = statuses.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: statuses.isEmpty
          ? _buildEmptyCard('Sin datos de pedidos', Icons.inbox_rounded)
          : Column(
              children: statuses.entries.map((e) {
                final config = statusConfig[e.key];
                final color = config?.$1 ?? Colors.grey;
                final icon = config?.$2 ?? Icons.circle;
                final pct = total > 0 ? e.value / total : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 18, color: color),
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
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
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
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
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

  // ─── Sales Chart ──────────────────────────────────────────────
  Widget _buildSalesChart(Map<String, double> salesByMonth) {
    if (salesByMonth.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildEmptyCard('Sin datos de ventas', Icons.bar_chart_rounded),
      );
    }

    final maxSales = salesByMonth.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: salesByMonth.entries.toList().asMap().entries.map((entry) {
            final e = entry.value;
            final heightFraction = maxSales > 0 ? e.value / maxSales : 0.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Tooltip(
                  message: '${e.key}: ${e.value.toStringAsFixed(2)}€',
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
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: (150 * heightFraction).clamp(6.0, 150.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
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
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Recent Orders ────────────────────────────────────────────
  Widget _buildRecentOrders(BuildContext context, List<dynamic> orders) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildEmptyCard(
          'No hay pedidos recientes',
          Icons.receipt_long_outlined,
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ...orders.asMap().entries.map((entry) {
            final order = entry.value;
            final isLast = entry.key == orders.length - 1;

            return InkWell(
              onTap: () => context.push('/admin/orders'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(
                            color: Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (order.status.color as Color).withValues(
                          alpha: 0.1,
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
                              color: AppTheme.textPrimary,
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
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
          // Ver todos link
          InkWell(
            onTap: () => context.push('/admin/orders'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver todos los pedidos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty placeholder ────────────────────────────────────────
  Widget _buildEmptyCard(String message, IconData icon) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppTheme.textLight),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Data classes
// ═══════════════════════════════════════════════════════════════

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 20,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
  const _QuickAction(this.label, this.icon, this.route, this.color);
}
