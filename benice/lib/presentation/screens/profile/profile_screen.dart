import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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

    final isSubscribed = user.isSubscribedNewsletter;

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
                        ? CachedNetworkImageProvider(user.avatarUrl!)
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
                    onTap: () => context.go('/orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.favorite_border,
                    label: 'Favoritos',
                    onTap: () => context.push('/favorites'),
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
                  title: 'Dirección de Envío',
                  subtitle: user.address ?? 'Sin dirección configurada',
                  onTap: () => _showEditAddressDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Preferencias',
              children: [
                _ProfileOption(
                  icon: Icons.email_outlined,
                  title: 'Newsletter',
                  subtitle: 'Ofertas y novedades',
                  trailing: Switch(
                    value: isSubscribed,
                    onChanged: (value) async {
                      if (value) {
                        final promoCode = await ref
                            .read(authProvider.notifier)
                            .subscribeToNewsletter(email: user.email);
                        if (context.mounted) {
                          CustomSnackBar.showSuccess(
                            context,
                            promoCode != null
                                ? 'Suscrito a la newsletter. Tu código: $promoCode'
                                : 'Error al suscribirse',
                          );
                        }
                      } else {
                        if (context.mounted) {
                          CustomSnackBar.showInfo(
                            context,
                            'Para darte de baja, contacta con soporte',
                          );
                        }
                      }
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
                  title: 'Preguntas Frecuentes',
                  onTap: () => context.push('/faq'),
                ),
                _ProfileOption(
                  icon: Icons.chat_bubble_outline,
                  title: 'Contactar Soporte',
                  onTap: () => context.push('/contact'),
                ),
                _ProfileOption(
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  onTap: () => context.push('/terms'),
                ),
                _ProfileOption(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de Privacidad',
                  onTap: () => context.push('/privacy'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Admin panel (solo si es admin)
            if (user.isAdmin) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Panel de Administración'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
    final fullNameController = TextEditingController(text: user.fullName ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person_outline),
                    counterText: '',
                  ),
                  maxLength: Validators.maxName,
                  inputFormatters: [Validators.lettersAndSpaces()],
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.badge_outlined),
                    counterText: '',
                  ),
                  maxLength: Validators.maxFullName,
                  inputFormatters: [Validators.lettersAndSpaces()],
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: Validators.maxPhone,
                  inputFormatters: [Validators.phoneChars()],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);
                      // Use the repository to update profile
                      final result = await ref
                          .read(authRepositoryProvider)
                          .updateProfile(
                            name: nameController.text.isNotEmpty
                                ? nameController.text
                                : null,
                            fullName: fullNameController.text.isNotEmpty
                                ? fullNameController.text
                                : null,
                            phone: phoneController.text.isNotEmpty
                                ? phoneController.text
                                : null,
                          );
                      result.fold(
                        (failure) {
                          if (context.mounted) {
                            CustomSnackBar.showError(context, failure.message);
                          }
                        },
                        (updatedUser) {
                          // Refresh auth state by re-checking current user
                          ref.read(authProvider.notifier).refreshUser();
                          if (context.mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              'Perfil actualizado correctamente',
                            );
                          }
                        },
                      );
                      setDialogState(() => isSaving = false);
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusFull,
                  ),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context) {
    final user = ref.read(authProvider).user!;
    final addressController = TextEditingController(text: user.address ?? '');
    final cityController = TextEditingController(text: user.city ?? '');
    final postalCodeController = TextEditingController(
      text: user.postalCode ?? '',
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Dirección de Envío'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'Calle, número, piso...',
                    counterText: '',
                  ),
                  maxLines: 2,
                  maxLength: Validators.maxAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad *',
                    prefixIcon: Icon(Icons.location_city),
                    counterText: '',
                  ),
                  maxLength: Validators.maxCity,
                  inputFormatters: [Validators.lettersAndSpaces()],
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Código Postal *',
                    prefixIcon: Icon(Icons.pin_drop),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: Validators.maxPostalCode,
                  inputFormatters: [Validators.digitsOnly()],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (addressController.text.isEmpty ||
                          cityController.text.isEmpty ||
                          postalCodeController.text.isEmpty) {
                        CustomSnackBar.showError(
                          context,
                          'Completa todos los campos',
                        );
                        return;
                      }
                      final cpError = Validators.postalCode(
                        postalCodeController.text,
                      );
                      if (cpError != null) {
                        CustomSnackBar.showError(context, cpError);
                        return;
                      }
                      final cityError = Validators.city(cityController.text);
                      if (cityError != null) {
                        CustomSnackBar.showError(context, cityError);
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      final result = await ref
                          .read(authRepositoryProvider)
                          .updateProfile(
                            address: addressController.text,
                            city: cityController.text,
                            postalCode: postalCodeController.text,
                          );
                      result.fold(
                        (failure) {
                          if (context.mounted) {
                            CustomSnackBar.showError(context, failure.message);
                          }
                        },
                        (_) {
                          if (context.mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              'Dirección actualizada',
                            );
                          }
                        },
                      );
                      setDialogState(() => isSaving = false);
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusFull,
                  ),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  maxLength: Validators.maxPassword,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: Icon(Icons.lock_outline),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  maxLength: Validators.maxPassword,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    helperText: 'Mínimo 6 caracteres',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  maxLength: Validators.maxPassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (currentPassCtrl.text.isEmpty ||
                          newPassCtrl.text.isEmpty) {
                        CustomSnackBar.showError(
                          context,
                          'Completa todos los campos',
                        );
                        return;
                      }
                      final passError = Validators.password(newPassCtrl.text);
                      if (passError != null) {
                        CustomSnackBar.showError(context, passError);
                        return;
                      }
                      final confirmError = Validators.passwordConfirm(
                        confirmPassCtrl.text,
                        newPassCtrl.text,
                      );
                      if (confirmError != null) {
                        CustomSnackBar.showError(context, confirmError);
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      final result = await ref
                          .read(authRepositoryProvider)
                          .updatePassword(
                            currentPassword: currentPassCtrl.text,
                            newPassword: newPassCtrl.text,
                          );
                      result.fold(
                        (failure) {
                          if (context.mounted) {
                            CustomSnackBar.showError(context, failure.message);
                          }
                        },
                        (_) {
                          if (context.mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              'Contraseña actualizada correctamente',
                            );
                          }
                        },
                      );
                      setDialogState(() => isSaving = false);
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusFull,
                  ),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Cambiar'),
            ),
          ],
        ),
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
