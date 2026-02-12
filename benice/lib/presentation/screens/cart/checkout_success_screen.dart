import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  final String? orderId;
  const CheckoutSuccessScreen({super.key, this.orderId});

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Estimated delivery date
    final deliveryDate = DateTime.now().add(const Duration(days: 3));
    final deliveryStr =
        '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 32),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      '¡Pedido Confirmado!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gracias por tu compra. Tu pedido ha sido procesado correctamente.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.orderId != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, color: Colors.purple[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Nº Pedido: ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              widget.orderId!.substring(0, 8).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Info cards
                    _InfoCard(
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.blue,
                      title: 'Entrega estimada',
                      subtitle: deliveryStr,
                      description:
                          'Recibirás un email con el número de seguimiento',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.email_outlined,
                      iconColor: Colors.green,
                      title: 'Email de confirmación',
                      subtitle: 'Enviado a tu correo',
                      description:
                          'Revisa tu bandeja de entrada con los detalles del pedido',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.support_agent,
                      iconColor: Colors.orange,
                      title: '¿Necesitas ayuda?',
                      subtitle: 'Estamos aquí para ti',
                      description:
                          'Contacta con nosotros en info@beniceastro.com',
                    ),

                    const SizedBox(height: 40),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/orders'),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Ver Mis Pedidos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.storefront),
                        label: const Text('Seguir Comprando'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
