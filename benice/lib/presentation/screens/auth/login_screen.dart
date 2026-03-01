import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success;

    if (_isLogin) {
      success = await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authNotifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    }

    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Escuchar errores (defer clearError para evitar cambios de estado re-entrantes)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackBar.showError(context, next.errorMessage!);
        Future.microtask(() => ref.read(authProvider.notifier).clearError());
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.pets, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 24),
                // Título
                Text(
                  _isLogin ? 'Bienvenido de nuevo' : 'Crear cuenta',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Inicia sesión para continuar'
                      : 'Regístrate para empezar a comprar',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person_outline),
                            counterText: '',
                          ),
                          textCapitalization: TextCapitalization.words,
                          maxLength: Validators.maxName,
                          inputFormatters: [Validators.lettersAndSpaces()],
                          validator: (value) {
                            if (!_isLogin) return Validators.name(value);
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        maxLength: Validators.maxEmail,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        maxLength: Validators.maxPassword,
                        validator: Validators.password,
                      ),
                      if (_isLogin) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPasswordDialog(),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Botón principal
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                          onPressed: _submit,
                          isLoading: authState.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Cambiar entre login y registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _isLogin = !_isLogin);
                      },
                      child: Text(_isLogin ? 'Regístrate' : 'Inicia sesión'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Continuar sin cuenta
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Continuar sin cuenta',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        ),
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                counterText: '',
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: Validators.maxEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (Validators.email(email) != null) {
                CustomSnackBar.showError(context, Validators.email(email)!);
                return;
              }

              final navigator = Navigator.of(context);

              final success = await ref
                  .read(authProvider.notifier)
                  .resetPassword(email: email);

              if (!context.mounted) return;
              navigator.pop();
              if (success) {
                CustomSnackBar.showSuccess(
                  context,
                  'Se ha enviado un email para restablecer tu contraseña',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              ),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
