import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Preguntas Frecuentes',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCategory('Compras', [
              _FAQ(
                '¿Cómo hago un pedido?',
                'Navega por nuestra tienda, añade productos al carrito y sigue el proceso de checkout. Te enviaremos un email de confirmación.',
              ),
              _FAQ(
                '¿Puedo modificar mi pedido?',
                'Puedes cancelar tu pedido mientras esté en estado "Pagado". Una vez preparado, no se puede modificar.',
              ),
              _FAQ(
                '¿Aceptáis devoluciones?',
                'Sí, tienes 14 días desde la recepción para solicitar una devolución desde "Mis Pedidos".',
              ),
            ]),
            _buildCategory('Envíos', [
              _FAQ(
                '¿Cuánto cuesta el envío?',
                'El envío estándar cuesta 4.99€. ¡Envío GRATIS en pedidos superiores a 49€!',
              ),
              _FAQ(
                '¿Cuánto tarda el envío?',
                'Los envíos se realizan en 24-48 horas laborables en península. Islas y Portugal 3-5 días.',
              ),
              _FAQ(
                '¿Hacéis envíos internacionales?',
                'Actualmente enviamos a toda España y Portugal. Consulta para otros países.',
              ),
            ]),
            _buildCategory('Pagos', [
              _FAQ(
                '¿Qué métodos de pago aceptáis?',
                'Aceptamos tarjetas de crédito/débito (Visa, Mastercard) a través de Stripe, el procesador de pagos más seguro.',
              ),
              _FAQ(
                '¿Es seguro pagar aquí?',
                'Absolutamente. Usamos SSL y Stripe para procesar los pagos de forma 100% segura.',
              ),
              _FAQ(
                '¿Puedo usar un código de descuento?',
                'Sí, introduce tu código en el carrito antes de proceder al pago.',
              ),
            ]),
            _buildCategory('Productos', [
              _FAQ(
                '¿Los productos son de calidad?',
                'Trabajamos solo con marcas premium y verificamos la calidad de cada producto.',
              ),
              _FAQ(
                '¿Tenéis productos para todas las mascotas?',
                'Tenemos productos para perros, gatos, roedores, aves y peces.',
              ),
              _FAQ(
                '¿Cómo sé qué producto es mejor para mi mascota?',
                'Usa nuestros filtros por tipo de animal, tamaño y edad para encontrar los productos ideales.',
              ),
            ]),
            _buildCategory('Cuenta', [
              _FAQ(
                '¿Necesito una cuenta para comprar?',
                'Sí, crear una cuenta es gratuito y te permite hacer seguimiento de tus pedidos.',
              ),
              _FAQ(
                '¿Cómo recupero mi contraseña?',
                'En la pantalla de login, pulsa "¿Olvidaste tu contraseña?" y recibirás un email para restablecerla.',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<_FAQ> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...faqs.map(
          (faq) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                faq.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq.answer,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ(this.question, this.answer);
}
