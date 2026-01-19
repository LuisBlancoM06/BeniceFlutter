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
      appBar: AppBar(title: const Text('Detalle del Pedido')),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con número de pedido y estado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMd,
                    ),
                    boxShadow: [AppTheme.shadowSm],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Número de pedido',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const Divider(height: 24),
                      // Fecha
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'd MMMM yyyy, HH:mm',
                              'es',
                            ).format(order.createdAt),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    image: item.productImage.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              item.productImage,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: item.productImage.isEmpty
                                      ? const Icon(
                                          Icons.pets,
                                          color: Colors.grey,
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
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Cantidad: ${item.quantity}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
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
                  title: 'Resumen',
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
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${order.total.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Dirección de envío
                _SectionCard(
                  title: 'Dirección de Envío',
                  icon: Icons.location_on_outlined,
                  child: Text(
                    order.shippingAddress,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
                if (order.notes != null) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Notas',
                    icon: Icons.note_outlined,
                    child: Text(
                      order.notes!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.5,
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
        // Botón de cancelar (solo si está pendiente o preparando)
        if (order.status == OrderStatus.pendiente ||
            order.status == OrderStatus.preparando)
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
      OrderStatus.pendiente,
      OrderStatus.preparando,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final status = statuses[index];
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? status.color : Colors.grey[200],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              status.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                    ),
                  ),
                  if (index < statuses.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: isCompleted && index < currentIndex
                          ? status.color
                          : Colors.grey[200],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.label,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCompleted
                              ? AppTheme.textPrimary
                              : AppTheme.textLight,
                        ),
                      ),
                      if (isCurrent)
                        const Text(
                          'Estado actual',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
