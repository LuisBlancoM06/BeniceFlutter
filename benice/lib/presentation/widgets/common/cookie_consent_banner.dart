import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/repository_providers.dart';

class CookieConsentBanner extends ConsumerStatefulWidget {
  const CookieConsentBanner({super.key});

  @override
  ConsumerState<CookieConsentBanner> createState() =>
      _CookieConsentBannerState();
}

class _CookieConsentBannerState extends ConsumerState<CookieConsentBanner>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _checkConsent();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _checkConsent() {
    final prefs = ref.read(sharedPreferencesProvider);
    final hasConsented = prefs.getBool('cookie_consent') ?? false;
    if (!hasConsented && mounted) {
      setState(() => _visible = true);
      _animController.forward();
    }
  }

  void _acceptAll() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('cookie_consent', true);
    prefs.setBool('cookie_analytics', true);
    prefs.setBool('cookie_marketing', true);
    _dismiss();
  }

  void _acceptNecessary() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('cookie_consent', true);
    prefs.setBool('cookie_analytics', false);
    prefs.setBool('cookie_marketing', false);
    _dismiss();
  }

  void _dismiss() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    // Calcular padding inferior para no tapar la barra de navegación
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 80.0; // Altura aproximada de la NavBar

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + navBarHeight + bottomPadding,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cookie_outlined, color: AppTheme.secondaryColor),
                SizedBox(width: 8),
                Text(
                  'Cookies',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Utilizamos cookies para mejorar tu experiencia, analizar el tráfico '
              'y personalizar el contenido. Puedes aceptar todas las cookies o '
              'solo las necesarias para el funcionamiento básico.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _acceptNecessary,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMd,
                        ),
                      ),
                    ),
                    child: const Text('Solo necesarias'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMd,
                        ),
                      ),
                    ),
                    child: const Text('Aceptar todas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to cookies policy
                  context.push('/cookies');
                },
                child: const Text(
                  'Política de cookies',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
