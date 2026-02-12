import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminReturnsScreen extends ConsumerWidget {
  const AdminReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsState = ref.watch(adminReturnsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Devoluciones')),
      body: returnsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : returnsState.returns.isEmpty
          ? const Center(child: Text('No hay devoluciones'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: returnsState.returns.length,
              itemBuilder: (context, index) {
                final ret = returnsState.returns[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido: ${ret.orderId.substring(0, 8)}...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _StatusChip(status: ret.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Motivo: ${ret.reason}'),
                        if (ret.refundAmount != null)
                          Text(
                            'Reembolso: ${ret.refundAmount!.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                        if (ret.adminNotes != null)
                          Text(
                            'Notas: ${ret.adminNotes}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (ret.status == 'solicitada')
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => ref
                                    .read(adminReturnsProvider.notifier)
                                    .updateStatus(ret.id, 'aprobada'),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Aprobar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showRejectDialog(context, ref, ret.id),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Rechazar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String returnId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar devolución'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Motivo del rechazo'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(adminReturnsProvider.notifier)
                  .updateStatus(returnId, 'rechazada', notes: controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'solicitada': AppTheme.warningColor,
      'aprobada': AppTheme.successColor,
      'rechazada': AppTheme.errorColor,
      'completada': AppTheme.primaryColor,
    };
    final color = colors[status] ?? AppTheme.textSecondary;
    return Chip(
      label: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
