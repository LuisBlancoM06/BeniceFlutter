import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SobreNosotrosScreen extends StatelessWidget {
  const SobreNosotrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sobre Nosotros',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner
            Container(
              height: 200,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 56, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'BeniceAstro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tu tienda de mascotas de confianza',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Nuestra Historia'),
                  const Text(
                    'BeniceAstro nació de la pasión por los animales y la necesidad de ofrecer productos '
                    'de calidad premium a precios accesibles. Desde nuestros inicios, hemos trabajado '
                    'incansablemente para convertirnos en la tienda online de referencia para los amantes '
                    'de las mascotas en España.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('Nuestra Misión'),
                  const Text(
                    'Proporcionar a cada mascota los mejores productos para su bienestar, garantizando '
                    'la máxima calidad y un servicio excepcional. Creemos que cada animal merece lo mejor, '
                    'y trabajamos para que eso sea accesible para todos.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Valores
                  _sectionTitle('Nuestros Valores'),
                  const SizedBox(height: 8),
                  ...[
                    _ValueItem(
                      icon: Icons.verified,
                      color: AppTheme.successColor,
                      title: 'Calidad Premium',
                      description:
                          'Solo trabajamos con las mejores marcas del mercado',
                    ),
                    _ValueItem(
                      icon: Icons.favorite,
                      color: AppTheme.errorColor,
                      title: 'Pasión Animal',
                      description: 'Amamos a los animales tanto como tú',
                    ),
                    _ValueItem(
                      icon: Icons.local_shipping,
                      color: AppTheme.primaryColor,
                      title: 'Envío Rápido',
                      description: 'Tus pedidos en 24-48 horas',
                    ),
                    _ValueItem(
                      icon: Icons.support_agent,
                      color: AppTheme.secondaryColor,
                      title: 'Atención Personalizada',
                      description: 'Estamos aquí para ayudarte siempre',
                    ),
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.color.withValues(alpha: 0.1),
                            child: Icon(item.icon, color: item.color),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(item.description),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cifras
                  _sectionTitle('BeniceAstro en Cifras'),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _statCard('500+', 'Productos', AppTheme.primaryColor),
                      _statCard(
                        '10K+',
                        'Clientes felices',
                        AppTheme.successColor,
                      ),
                      _statCard('24h', 'Envío rápido', AppTheme.secondaryColor),
                      _statCard('100%', 'Satisfacción', AppTheme.warningColor),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueItem {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _ValueItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
