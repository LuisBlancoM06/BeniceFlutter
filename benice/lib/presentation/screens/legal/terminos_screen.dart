import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TerminosScreen extends StatelessWidget {
  const TerminosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos y Condiciones')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Términos y Condiciones', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Última actualización: Enero 2026', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 20),

            _LegalSection(
              title: '1. Identificación',
              content: 'BeniceAstro es una tienda online de productos para mascotas. '
                  'Al utilizar esta aplicación, aceptas estos términos y condiciones.',
            ),
            _LegalSection(
              title: '2. Productos y Precios',
              content: '• Los precios incluyen IVA (21%)\n'
                  '• Los precios pueden cambiar sin previo aviso\n'
                  '• Las imágenes son orientativas\n'
                  '• La disponibilidad está sujeta a existencias\n'
                  '• Los descuentos no son acumulables salvo indicación expresa',
            ),
            _LegalSection(
              title: '3. Proceso de Compra',
              content: '1. Selecciona los productos y añádelos al carrito\n'
                  '2. Revisa tu pedido y aplica códigos de descuento si los tienes\n'
                  '3. Introduce tu dirección de envío\n'
                  '4. Realiza el pago de forma segura con Stripe\n'
                  '5. Recibirás confirmación por email\n\n'
                  'El contrato de compra se perfecciona en el momento del pago.',
            ),
            _LegalSection(
              title: '4. Envíos',
              content: '• Envío estándar: 4.99€ (GRATIS en pedidos >49€)\n'
                  '• Plazo de entrega: 24-48 horas (península)\n'
                  '• Islas y Portugal: 3-5 días laborables\n'
                  '• No realizamos envíos a Ceuta y Melilla temporalmente',
            ),
            _LegalSection(
              title: '5. Derecho de Desistimiento',
              content: 'Dispones de 14 días naturales desde la recepción del pedido para '
                  'ejercer tu derecho de desistimiento sin necesidad de justificación.\n\n'
                  'El producto debe estar sin usar y en su embalaje original.\n\n'
                  'Quedan excluidos: alimentos abiertos, productos personalizados y '
                  'medicamentos/productos de salud con precinto roto.',
            ),
            _LegalSection(
              title: '6. Garantía',
              content: 'Todos nuestros productos tienen una garantía mínima de 2 años '
                  'conforme a la legislación vigente. Si recibes un producto defectuoso, '
                  'contacta con nosotros en un plazo de 48 horas.',
            ),
            _LegalSection(
              title: '7. Cuenta de Usuario',
              content: '• Eres responsable de mantener la confidencialidad de tu contraseña\n'
                  '• Debes ser mayor de 18 años para crear una cuenta\n'
                  '• Nos reservamos el derecho de suspender cuentas que infrinjan estos términos\n'
                  '• Puedes solicitar la eliminación de tu cuenta en cualquier momento',
            ),
            _LegalSection(
              title: '8. Propiedad Intelectual',
              content: 'Todos los contenidos de esta aplicación (textos, imágenes, logotipos, diseño) '
                  'son propiedad de BeniceAstro o de sus respectivos propietarios y están protegidos '
                  'por las leyes de propiedad intelectual.',
            ),
            _LegalSection(
              title: '9. Limitación de Responsabilidad',
              content: 'BeniceAstro no se hace responsable de:\n'
                  '• Interrupciones temporales del servicio\n'
                  '• Retrasos en la entrega por causas de fuerza mayor\n'
                  '• Uso indebido de los productos',
            ),
            _LegalSection(
              title: '10. Legislación Aplicable',
              content: 'Estos términos se rigen por la legislación española. Para cualquier '
                  'controversia, ambas partes se someten a los juzgados y tribunales del '
                  'domicilio del consumidor, conforme a la normativa vigente.',
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
