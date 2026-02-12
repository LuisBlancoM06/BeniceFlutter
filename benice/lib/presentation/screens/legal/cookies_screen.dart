import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CookiesScreen extends StatelessWidget {
  const CookiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Cookies')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Política de Cookies', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Última actualización: Enero 2026', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 20),

            _LegalSection(
              title: '1. ¿Qué son las Cookies?',
              content: 'Las cookies son pequeños archivos de texto que se almacenan en tu '
                  'dispositivo cuando visitas una aplicación o sitio web. Sirven para '
                  'recordar tus preferencias y mejorar tu experiencia de navegación.',
            ),
            _LegalSection(
              title: '2. Cookies que Utilizamos',
              content: '• Cookies técnicas (esenciales): Necesarias para el funcionamiento '
                  'de la app (sesión, carrito de compra)\n\n'
                  '• Cookies de preferencias: Recuerdan tus opciones como idioma o '
                  'configuraciones de visualización\n\n'
                  '• Cookies analíticas: Nos ayudan a entender cómo usas la app para '
                  'mejorarla (anónimas)\n\n'
                  '• Cookies de marketing: Utilizadas para mostrarte contenido relevante '
                  '(solo con tu consentimiento)',
            ),
            _LegalSection(
              title: '3. Cookies de Terceros',
              content: 'Utilizamos servicios de terceros que pueden establecer sus propias cookies:\n\n'
                  '• Supabase: Autenticación y sesión de usuario\n'
                  '• Stripe: Procesamiento seguro de pagos\n'
                  '• Servicios de análisis: Estadísticas de uso anónimas',
            ),
            _LegalSection(
              title: '4. Duración',
              content: '• Cookies de sesión: Se eliminan al cerrar la app\n'
                  '• Cookies persistentes: Se mantienen entre 30 días y 2 años según su finalidad\n'
                  '• Token de autenticación: Se mantiene mientras la sesión está activa',
            ),
            _LegalSection(
              title: '5. Gestión de Cookies',
              content: 'Puedes gestionar las cookies desde la configuración de tu dispositivo:\n\n'
                  '• Android: Ajustes > Apps > BeniceAstro > Almacenamiento > Borrar datos\n'
                  '• iOS: Ajustes > General > Almacenamiento > BeniceAstro\n\n'
                  'Ten en cuenta que desactivar ciertas cookies puede afectar al funcionamiento '
                  'correcto de la aplicación.',
            ),
            _LegalSection(
              title: '6. Consentimiento',
              content: 'Al utilizar nuestra aplicación, aceptas el uso de cookies técnicas '
                  'esenciales. Para las cookies no esenciales, te pediremos tu consentimiento '
                  'explícito. Puedes modificar tus preferencias en cualquier momento desde '
                  'la configuración de la app.',
            ),
            _LegalSection(
              title: '7. Contacto',
              content: 'Si tienes preguntas sobre nuestra política de cookies, contacta con '
                  'nosotros en info@benice.com',
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
