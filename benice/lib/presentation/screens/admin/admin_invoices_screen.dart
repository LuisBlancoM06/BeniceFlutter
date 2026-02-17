import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';

// State & Notifier
class AdminInvoicesState {
  final List<InvoiceEntity> invoices;
  final bool isLoading;
  final String? error;

  const AdminInvoicesState({
    this.invoices = const [],
    this.isLoading = false,
    this.error,
  });
}

class AdminInvoicesNotifier extends Notifier<AdminInvoicesState> {
  @override
  AdminInvoicesState build() {
    Future.microtask(() => _load());
    return const AdminInvoicesState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final result = await adminRepo.getInvoices();
      result.fold(
        (failure) => state = AdminInvoicesState(error: failure.message),
        (invoices) => state = AdminInvoicesState(invoices: invoices),
      );
    } catch (e) {
      state = AdminInvoicesState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AdminInvoicesState(isLoading: true);
    await _load();
  }
}

final adminInvoicesProvider =
    NotifierProvider.autoDispose<AdminInvoicesNotifier, AdminInvoicesState>(
      AdminInvoicesNotifier.new,
    );

// Screen
class AdminInvoicesScreen extends ConsumerWidget {
  const AdminInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesState = ref.watch(adminInvoicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF064E3B),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
                onPressed: () =>
                    ref.read(adminInvoicesProvider.notifier).refresh(),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 8, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Facturas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Gestión de facturación',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
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
            ),
          ),

          if (invoicesState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (invoicesState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      invoicesState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(adminInvoicesProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (invoicesState.invoices.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay facturas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Las facturas aparecen al completarse pedidos',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Summary bar flotante
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SummaryBar(invoices: invoicesState.invoices),
                ),
              ),
            ),
            // Lista
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final invoice = invoicesState.invoices[index];
                  return _InvoiceTile(invoice: invoice);
                }, childCount: invoicesState.invoices.length),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  const _SummaryBar({required this.invoices});

  @override
  Widget build(BuildContext context) {
    final totalFacturas = invoices
        .where((i) => i.invoiceType == 'factura')
        .length;
    final totalAbonos = invoices.where((i) => i.invoiceType == 'abono').length;
    final totalAmount = invoices.fold<double>(0, (sum, i) => sum + i.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatPill(
            label: 'Total',
            value: invoices.length.toString(),
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 10),
          _StatPill(
            label: 'Facturas',
            value: totalFacturas.toString(),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 10),
          _StatPill(
            label: 'Abonos',
            value: totalAbonos.toString(),
            color: const Color(0xFFEF4444),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalAmount.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
              const Text(
                'Importe total',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final InvoiceEntity invoice;

  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isAbono = invoice.invoiceType == 'abono';
    final typeColor = isAbono
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final typeIcon = isAbono
        ? Icons.remove_circle_rounded
        : Icons.receipt_rounded;
    final typeBg = isAbono ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isAbono ? 'Abono' : 'Factura'} · Pedido: ${invoice.orderId.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Sub: ${invoice.subtotal.toStringAsFixed(2)}€ · IVA: ${invoice.taxAmount.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isAbono ? '-' : ''}${invoice.total.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: typeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${invoice.createdAt.day}/${invoice.createdAt.month}/${invoice.createdAt.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
