import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    // KNOWN LIMITATION: ref.read(authProvider) inside redirect is not reactive.
    // GoRouter's redirect runs only on navigation, not when auth state changes.
    // For truly reactive auth-based redirects, use GoRouter's `refreshListenable`
    // parameter with a ChangeNotifier that listens to auth state changes, or
    // wrap admin screens with a ConsumerWidget that watches authProvider and
    // performs programmatic navigation on auth loss.
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.startsWith('/admin')) {
        final authState = ref.read(authProvider);
        if (!authState.isAuthenticated || authState.user == null) {
          return '/login';
        }
        if (!authState.user!.isAdmin) {
          return '/';
        }
      }
      return null;
    },
    routes: [
      // Shell con bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductsScreen()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      // Rutas sin shell (pantallas completas)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      // Ofertas flash
      GoRoute(
        path: '/ofertas',
        builder: (context, state) => const OfertasScreen(),
      ),
      // Favoritos
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      // Info
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(path: '/faq', builder: (context, state) => const FaqScreen()),
      GoRoute(
        path: '/shipping',
        builder: (context, state) => const EnviosScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const SobreNosotrosScreen(),
      ),
      // Legal
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacidadScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TerminosScreen(),
      ),
      GoRoute(
        path: '/cookies',
        builder: (context, state) => const CookiesScreen(),
      ),
      // Auth
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Blog
      GoRoute(path: '/blog', builder: (context, state) => const BlogScreen()),
      GoRoute(
        path: '/blog/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return BlogDetailScreen(slug: slug);
        },
      ),
      // Productos por animal
      GoRoute(
        path: '/perros',
        builder: (context, state) =>
            const AnimalProductsScreen(animalType: AnimalType.perro),
      ),
      GoRoute(
        path: '/gatos',
        builder: (context, state) =>
            const AnimalProductsScreen(animalType: AnimalType.gato),
      ),
      GoRoute(
        path: '/otros',
        builder: (context, state) =>
            const AnimalProductsScreen(animalType: AnimalType.otros),
      ),
      // Recomendador
      GoRoute(
        path: '/recommender',
        builder: (context, state) => const RecommenderScreen(),
      ),
      // Checkout success
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'];
          return CheckoutSuccessScreen(orderId: orderId);
        },
      ),
      // Checkout cancel
      GoRoute(
        path: '/checkout/cancel',
        builder: (context, state) => const CheckoutCancelScreen(),
      ),
      // Admin
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/new',
        builder: (context, state) => const AdminProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return AdminProductFormScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/admin/ofertas',
        builder: (context, state) => const AdminOfertasScreen(),
      ),
      GoRoute(
        path: '/admin/newsletter',
        builder: (context, state) => const AdminNewsletterScreen(),
      ),
      GoRoute(
        path: '/admin/returns',
        builder: (context, state) => const AdminReturnsScreen(),
      ),
      GoRoute(
        path: '/admin/invoices',
        builder: (context, state) => const AdminInvoicesScreen(),
      ),
      GoRoute(
        path: '/admin/visits',
        builder: (context, state) => const AdminVisitsScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Página no encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    ),
  );
  ref.onDispose(() => router.dispose());
  return router;
});

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront_rounded,
                  label: 'Tienda',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go('/products'),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart_rounded,
                  label: 'Carrito',
                  isSelected: selectedIndex == 2,
                  badgeCount: cartItemCount,
                  onTap: () => context.go('/cart'),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: 'Pedidos',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go('/orders'),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Perfil',
                  isSelected: selectedIndex == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/products') return 1;
    if (location == '/cart') return 2;
    if (location == '/orders') return 3;
    if (location == '/profile') return 4;
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.12),
                      const Color(0xFF9333EA).withValues(alpha: 0.06),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                label: badgeCount > 0
                    ? Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
                isLabelVisible: badgeCount > 0,
                backgroundColor: AppTheme.secondaryColor,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withValues(alpha: 0.7),
                    size: isSelected ? 24 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                child: Text(label),
              ),
              // Indicador en punto debajo del ítem seleccionado
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(top: 3),
                width: isSelected ? 5 : 0,
                height: isSelected ? 5 : 0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF9333EA)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
