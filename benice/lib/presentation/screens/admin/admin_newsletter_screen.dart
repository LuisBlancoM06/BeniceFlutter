import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminNewsletterScreen extends ConsumerWidget {
  const AdminNewsletterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsletterState = ref.watch(adminNewsletterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportación CSV en desarrollo')),
              );
            },
          ),
        ],
      ),
      body: newsletterState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Total Suscriptores',
                        value: newsletterState.subscribers.length.toString(),
                        icon: Icons.people,
                      ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: newsletterState.subscribers.isEmpty
                      ? const Center(child: Text('No hay suscriptores'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: newsletterState.subscribers.length,
                          itemBuilder: (context, index) {
                            final sub = newsletterState.subscribers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.email,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                title: Text(sub.email),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (sub.promoCode.isNotEmpty)
                                      Text(
                                        'Código: ${sub.promoCode}',
                                        style: const TextStyle(
                                          color: AppTheme.successColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.errorColor,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, sub.email),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar suscriptor'),
        content: Text('¿Eliminar "$email" de la lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(adminNewsletterProvider.notifier)
                  .deleteSubscriber(email);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
