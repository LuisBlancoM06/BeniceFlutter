import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Política de Privacidad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Última actualización: Enero 2026', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 20),

            _LegalSection(
              title: '1. Responsable del Tratamiento',
              content: 'BeniceAstro es responsable del tratamiento de los datos personales '
                  'recogidos a través de esta aplicación. Nos comprometemos a proteger '
                  'tu privacidad y a tratar tus datos conforme al Reglamento General de '
                  'Protección de Datos (RGPD) y la LOPDGDD.',
            ),
            _LegalSection(
              title: '2. Datos que Recopilamos',
              content: '• Datos de registro: nombre, email, teléfono\n'
                  '• Datos de envío: dirección, ciudad, código postal\n'
                  '• Datos de pago: procesados por Stripe (no almacenamos datos de tarjeta)\n'
                  '• Datos de navegación: productos vistos, búsquedas, preferencias\n'
                  '• Datos de pedidos: historial de compras',
            ),
            _LegalSection(
              title: '3. Finalidad del Tratamiento',
              content: '• Gestionar tu cuenta de usuario\n'
                  '• Procesar y entregar tus pedidos\n'
                  '• Enviar comunicaciones comerciales (con tu consentimiento)\n'
                  '• Mejorar nuestros servicios y personalizar tu experiencia\n'
                  '• Cumplir con obligaciones legales y fiscales',
            ),
            _LegalSection(
              title: '4. Base Legal',
              content: 'El tratamiento de tus datos se basa en:\n'
                  '• Ejecución del contrato de compraventa\n'
                  '• Tu consentimiento expreso para comunicaciones comerciales\n'
                  '• Nuestro interés legítimo en mejorar nuestros servicios\n'
                  '• Cumplimiento de obligaciones legales',
            ),
            _LegalSection(
              title: '5. Conservación de los Datos',
              content: 'Conservaremos tus datos mientras mantengas tu cuenta activa. '
                  'Los datos de facturación se conservan durante el tiempo exigido por la '
                  'legislación fiscal (5 años). Puedes solicitar la eliminación de tu cuenta '
                  'en cualquier momento.',
            ),
            _LegalSection(
              title: '6. Tus Derechos',
              content: 'Tienes derecho a:\n'
                  '• Acceder a tus datos personales\n'
                  '• Rectificar datos inexactos\n'
                  '• Solicitar la supresión de tus datos\n'
                  '• Oponerte al tratamiento\n'
                  '• Portabilidad de tus datos\n'
                  '• Revocar tu consentimiento\n\n'
                  'Para ejercer estos derechos, contacta con nosotros en info@benice.com',
            ),
            _LegalSection(
              title: '7. Seguridad',
              content: 'Implementamos medidas de seguridad técnicas y organizativas para '
                  'proteger tus datos, incluyendo cifrado SSL, acceso restringido y '
                  'copias de seguridad regulares.',
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String content;

  const _LegalSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
