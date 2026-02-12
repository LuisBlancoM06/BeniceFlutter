import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final promoState = ref.watch(adminPromoCodesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info de la tienda
            _buildSection(
              title: 'Información de la Tienda',
              icon: Icons.store,
              children: [
                _buildInfoRow('Nombre', 'BeniceAstro'),
                _buildInfoRow('Email', 'info@benice.com'),
                _buildInfoRow('Teléfono', '+34 600 000 000'),
                _buildInfoRow('Envío gratis', 'Pedidos > 49€'),
                _buildInfoRow('Coste envío', '4.99€'),
              ],
            ),
            const SizedBox(height: 24),

            // Códigos promocionales
            _buildSection(
              title: 'Códigos Promocionales',
              icon: Icons.confirmation_number,
              trailing: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _showCreatePromoDialog(context),
              ),
              children: [
                if (promoState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (promoState.codes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No hay códigos',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                else
                  ...promoState.codes.map(
                    (code) => ListTile(
                      dense: true,
                      title: Text(
                        code.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Text(
                        '${code.discountPercent.toStringAsFixed(0)}% descuento${code.isValid ? '' : ' (inactivo)'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            code.isValid ? Icons.check_circle : Icons.cancel,
                            color: code.isValid
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppTheme.errorColor,
                            ),
                            onPressed: () => ref
                                .read(adminPromoCodesProvider.notifier)
                                .deleteCode(code.code),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Zona peligrosa
            _buildSection(
              title: '⚠️ Zona Peligrosa',
              icon: Icons.warning,
              iconColor: AppTheme.errorColor,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.cached,
                    color: AppTheme.warningColor,
                  ),
                  title: const Text('Limpiar caché'),
                  subtitle: const Text('Limpia datos locales de la app'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Caché limpiado')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showCreatePromoDialog(BuildContext context) {
    final codeController = TextEditingController();
    final percentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Código Promo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Código'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: percentController,
              decoration: const InputDecoration(labelText: '% Descuento'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              final percent = double.tryParse(percentController.text) ?? 0;
              if (code.isNotEmpty && percent > 0) {
                ref
                    .read(adminPromoCodesProvider.notifier)
                    .createCode(code, percent);
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
