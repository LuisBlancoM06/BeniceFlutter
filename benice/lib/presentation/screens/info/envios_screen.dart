import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class EnviosScreen extends StatelessWidget {
  const EnviosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Envíos y Devoluciones',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner envío gratis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Envío GRATIS!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'En pedidos superiores a ${AppConstants.freeShippingMinAmount.toStringAsFixed(0)}€',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Información de Envío'),
            _infoCard([
              _infoRow('Coste estándar', '${AppConstants.shippingCost}€'),
              _infoRow(
                'Envío gratis',
                'Pedidos > ${AppConstants.freeShippingMinAmount.toStringAsFixed(0)}€',
              ),
              _infoRow('Península', '24-48 horas laborables'),
              _infoRow('Islas y Portugal', '3-5 días laborables'),
              _infoRow('Transportista', 'SEUR / GLS'),
            ]),
            const SizedBox(height: 20),

            _sectionTitle('Seguimiento'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Una vez enviado tu pedido, recibirás un email con el número de seguimiento. '
                      'También puedes consultar el estado desde "Mis Pedidos".',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Devoluciones'),
            _infoCard([
              _infoRow('Plazo', '14 días desde la recepción'),
              _infoRow('Condición', 'Producto sin usar y en embalaje original'),
              _infoRow('Proceso', 'Solicitar desde "Mis Pedidos"'),
              _infoRow('Reembolso', AppConstants.returnDaysInfo),
            ]),
            const SizedBox(height: 20),

            _sectionTitle('Dirección de Devolución'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warehouse_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppConstants.warehouseAddress,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Excepciones'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Productos de alimentación abiertos no admiten devolución\n'
                      '• Productos personalizados no admiten devolución\n'
                      '• Medicamentos y productos de salud precintados solo si el precinto está intacto\n'
                      '• Los gastos de envío de devolución corren a cargo del cliente salvo producto defectuoso',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: rows),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
