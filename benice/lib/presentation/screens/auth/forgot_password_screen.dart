import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce un email válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(email: email);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 40),

                if (_emailSent) _buildSuccessView() else _buildFormView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset, size: 48, color: Colors.purple[700]),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recuperar Contraseña',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'tu@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Enviar Enlace de Recuperación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            'Volver a Iniciar Sesión',
            style: TextStyle(
              color: Colors.purple[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 16),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Email Enviado!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Hemos enviado un enlace de recuperación a ${_emailController.text}. Revisa tu bandeja de entrada.',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Si no recibes el email, revisa tu carpeta de spam o intenta de nuevo.',
                  style: TextStyle(color: Colors.amber[800], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() {
              _emailSent = false;
              _emailController.clear();
            }),
            child: const Text('Intentar con otro email'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Volver a Iniciar Sesión'),
          ),
        ),
      ],
    );
  }
}
