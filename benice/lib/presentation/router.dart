import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
            const AnimalProductsScreen(animalType: AnimalType.otro),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Inicio',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront,
                  label: 'Tienda',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go('/products'),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart,
                  label: 'Carrito',
                  isSelected: selectedIndex == 2,
                  badgeCount: cartItemCount,
                  onTap: () => context.go('/cart'),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Pedidos',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go('/orders'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              label: badgeCount > 0
                  ? Text('$badgeCount', style: const TextStyle(fontSize: 10))
                  : null,
              isLabelVisible: badgeCount > 0,
              backgroundColor: AppTheme.secondaryColor,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
