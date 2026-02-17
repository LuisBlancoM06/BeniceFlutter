import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Popup de Newsletter
class NewsletterPopup extends StatefulWidget {
  final Future<bool> Function(String email) onSubscribe;

  const NewsletterPopup({super.key, required this.onSubscribe});

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function(String email) onSubscribe,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => NewsletterPopup(onSubscribe: onSubscribe),
    );
  }

  @override
  State<NewsletterPopup> createState() => _NewsletterPopupState();
}

class _NewsletterPopupState extends State<NewsletterPopup> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubscribed = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Introduce un email válido');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await widget.onSubscribe(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSubscribed = success;
        if (!success) _error = 'Error al suscribirse';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: _isSubscribed ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cerrar
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: AppTheme.textSecondary),
          ),
        ),
        // Icono
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mail_outline, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        // Título
        const Text(
          '¡Únete a nuestra Newsletter!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtítulo
        Text(
          'Suscríbete y obtén un ${AppConstants.newsletterDiscountPercent}% de descuento en tu primera compra',
          style: const TextStyle(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Email input
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Tu email',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),
        // Botón
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _subscribe,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Suscribirme'),
          ),
        ),
        const SizedBox(height: 12),
        // Términos
        const Text(
          'Al suscribirte aceptas recibir comunicaciones promocionales',
          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de éxito
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.successColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        // Título
        const Text(
          '¡Gracias por suscribirte!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Código
        const Text(
          'Tu código de descuento es:',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Text(
            AppConstants.newsletterPromoCode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${AppConstants.newsletterDiscountPercent}% de descuento en tu primera compra',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Empezar a comprar!'),
          ),
        ),
      ],
    );
  }
}

/// Banner de Newsletter para la home
class NewsletterBanner extends StatelessWidget {
  final VoidCallback onSubscribe;

  const NewsletterBanner({super.key, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '${AppConstants.newsletterDiscountPercent}% de descuento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suscríbete a nuestra newsletter',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('Suscribirme'),
                ),
              ],
            ),
          ),
          const Icon(Icons.email, size: 48, color: Colors.white),
        ],
      ),
    );
  }
}
