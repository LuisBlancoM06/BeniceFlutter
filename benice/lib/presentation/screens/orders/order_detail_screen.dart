import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/order/order_widgets.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Pedido no encontrado',
                message: 'No se pudo cargar la información del pedido',
              ),
            );
          }

          final statusColor = order.status.color;

          return CustomScrollView(
            slivers: [
              // AppBar con gradiente
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
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
                        padding: const EdgeInsets.fromLTRB(56, 12, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido ${order.orderNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'd MMMM yyyy, HH:mm',
                                    'es',
                                  ).format(order.createdAt),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      // Tarjeta de estado flotante
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  order.status.icon,
                                  color: statusColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estado actual',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.status.label,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OrderStatusBadge(status: order.status),
                            ],
                          ),
                        ),
                      ),

                      // Timeline de estado
                      _OrderTimeline(order: order),
                      const SizedBox(height: 16),

                      // Productos
                      _SectionCard(
                        title: 'Productos',
                        icon: Icons.shopping_bag_outlined,
                        child: Column(
                          children: order.items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: item.productImage.isNotEmpty
                                              ? DecorationImage(
                                                  image: ResizeImage(
                                                    CachedNetworkImageProvider(
                                                      item.productImage,
                                                    ),
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: item.productImage.isEmpty
                                            ? const Icon(
                                                Icons.pets,
                                                color: AppTheme.textLight,
                                                size: 24,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'x${item.quantity}',
                                                style: const TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${item.totalPrice.toStringAsFixed(2)}€',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resumen de pago
                      _SectionCard(
                        title: 'Resumen de Pago',
                        icon: Icons.receipt_outlined,
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Subtotal',
                              value: '${order.subtotal.toStringAsFixed(2)}€',
                            ),
                            if (order.discount > 0)
                              _SummaryRow(
                                label:
                                    'Descuento${order.discountCode != null ? ' (${order.discountCode})' : ''}',
                                value: '-${order.discount.toStringAsFixed(2)}€',
                                valueColor: AppTheme.successColor,
                              ),
                            _SummaryRow(
                              label: 'Envío',
                              value: order.shippingCost > 0
                                  ? '${order.shippingCost.toStringAsFixed(2)}€'
                                  : 'Gratis',
                              valueColor: order.shippingCost == 0
                                  ? AppTheme.successColor
                                  : null,
                            ),
                            const Divider(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.06,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${order.total.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dirección de envío
                      _SectionCard(
                        title: 'Dirección de Envío',
                        icon: Icons.location_on_outlined,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.infoColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.home_outlined,
                                size: 18,
                                color: AppTheme.infoColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                order.shippingAddress,
                                style: const TextStyle(
                                  height: 1.6,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.notes != null) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Notas',
                          icon: Icons.note_outlined,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withValues(
                                alpha: 0.06,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.warningColor.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppTheme.warningColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.notes!,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Botones de acción
                      _buildActions(context, ref, order),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorState(
          message: 'Error al cargar el pedido',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, order) {
    return Column(
      children: [
        // Botón de cancelar (solo si está pagado)
        if (order.status == OrderStatus.pagado)
          PrimaryButton(
            label: 'Cancelar Pedido',
            icon: Icons.cancel_outlined,
            backgroundColor: AppTheme.errorColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CancelOrderDialog(
                  orderNumber: order.orderNumber,
                  onConfirm: () async {
                    final result = await ref
                        .read(orderProvider.notifier)
                        .cancelOrder(order.id);
                    result.fold(
                      (failure) {
                        CustomSnackBar.showError(context, failure.message);
                      },
                      (_) {
                        CustomSnackBar.showSuccess(
                          context,
                          'Pedido cancelado correctamente',
                        );
                        ref.invalidate(orderDetailProvider(orderId));
                      },
                    );
                  },
                ),
              );
            },
          ),
        // Botón de devolución (solo si está entregado)
        if (order.status == OrderStatus.entregado) ...[
          PrimaryButton(
            label: 'Solicitar Devolución',
            icon: Icons.assignment_return_outlined,
            backgroundColor: AppTheme.warningColor,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => ReturnInfoBottomSheet(
                  orderNumber: order.orderNumber,
                  onConfirm: () {
                    ref.read(orderProvider.notifier).requestReturn(order.id);
                    Navigator.pop(context);
                    CustomSnackBar.showSuccess(
                      context,
                      'Solicitud de devolución enviada',
                    );
                  },
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 12),
        // Botón de contactar soporte
        OutlinedButton.icon(
          onPressed: () {
            CustomSnackBar.showInfo(
              context,
              'Contacta con soporte: soporte@beniceAstro.com',
            );
          },
          icon: const Icon(Icons.support_agent),
          label: const Text('Contactar Soporte'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final dynamic order;

  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      OrderStatus.pagado,
      OrderStatus.enviado,
      OrderStatus.entregado,
    ];

    // Si está cancelado, mostrar solo el estado de cancelación
    if (order.status == OrderStatus.cancelado) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: order.status.color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido Cancelado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: order.status.color,
                    ),
                  ),
                  if (order.cancelledAt != null)
                    Text(
                      DateFormat(
                        'd MMM yyyy, HH:mm',
                        'es',
                      ).format(order.cancelledAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = statuses.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Seguimiento',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 36 : 28,
                      height: isCurrent ? 36 : 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? status.color
                            : const Color(0xFFE5E7EB),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: status.color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                isCurrent ? status.icon : Icons.check,
                                color: Colors.white,
                                size: isCurrent ? 18 : 14,
                              )
                            : Icon(
                                status.icon,
                                size: 12,
                                color: AppTheme.textLight,
                              ),
                      ),
                    ),
                    if (index < statuses.length - 1)
                      Container(
                        width: 2.5,
                        height: 32,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isCompleted && index < currentIndex
                              ? status.color
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: isCurrent ? 6 : 3,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.label,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: isCurrent ? 15 : 14,
                            color: isCompleted
                                ? AppTheme.textPrimary
                                : AppTheme.textLight,
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Estado actual',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
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
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          child,
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
