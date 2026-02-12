import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSubscribedToNewsletter = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Mi Perfil',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
        body: EmptyState(
          icon: Icons.person_outline,
          title: 'Inicia Sesión',
          message: 'Accede a tu cuenta para ver tu perfil y pedidos.',
          actionLabel: 'Iniciar Sesión',
          onAction: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar y nombre
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            (user.name ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        if (user.phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phone!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Acciones rápidas
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Mis Pedidos',
                    onTap: () => context.push('/orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Mi Carrito',
                    onTap: () => context.push('/cart'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Opciones del perfil
            _ProfileSection(
              title: 'Cuenta',
              children: [
                _ProfileOption(
                  icon: Icons.person_outline,
                  title: 'Datos Personales',
                  subtitle: 'Nombre, email, teléfono',
                  onTap: () => _showEditProfileDialog(context),
                ),
                _ProfileOption(
                  icon: Icons.lock_outline,
                  title: 'Cambiar Contraseña',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _ProfileOption(
                  icon: Icons.location_on_outlined,
                  title: 'Direcciones de Envío',
                  onTap: () {
                    CustomSnackBar.showInfo(
                      context,
                      'Funcionalidad próximamente',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Preferencias',
              children: [
                _ProfileOption(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeTrackColor: AppTheme.primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    activeThumbColor: AppTheme.primaryColor,
                  ),
                ),
                _ProfileOption(
                  icon: Icons.email_outlined,
                  title: 'Newsletter',
                  subtitle: 'Ofertas y novedades',
                  trailing: Switch(
                    value: _isSubscribedToNewsletter,
                    onChanged: (value) {
                      setState(() => _isSubscribedToNewsletter = value);
                      CustomSnackBar.showSuccess(
                        context,
                        value
                            ? 'Suscrito a la newsletter'
                            : 'Dado de baja de la newsletter',
                      );
                    },
                    activeTrackColor: AppTheme.primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    activeThumbColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Soporte',
              children: [
                _ProfileOption(
                  icon: Icons.help_outline,
                  title: 'Centro de Ayuda',
                  onTap: () {
                    CustomSnackBar.showInfo(
                      context,
                      'Visita: ayuda.beniceastro.com',
                    );
                  },
                ),
                _ProfileOption(
                  icon: Icons.chat_bubble_outline,
                  title: 'Contactar Soporte',
                  onTap: () {
                    CustomSnackBar.showInfo(
                      context,
                      'Email: soporte@beniceastro.com',
                    );
                  },
                ),
                _ProfileOption(
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  onTap: () {},
                ),
                _ProfileOption(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de Privacidad',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Versión
            const Text(
              'BeniceAstro v1.0.0',
              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = ref.read(authProvider).user!;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simular actualización
              CustomSnackBar.showSuccess(context, 'Perfil actualizado');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              CustomSnackBar.showSuccess(context, 'Contraseña actualizada');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              ),
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            boxShadow: [AppTheme.shadowSm],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppTheme.textLight)
              : null),
      onTap: onTap,
    );
  }
}
