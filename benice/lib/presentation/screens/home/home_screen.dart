import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/product/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final featuredProducts = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Contenido principal
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de notificaciones rotativo (como la web)
                const _NotificationBanner(),
                // Hero Carousel
                const _HeroCarousel(),
                const SizedBox(height: 32),

                // Categorías por tipo de animal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.tune, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Compra por Categoría',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _AnimalTypeSelector(
                  onSelected: (type) {
                    ref
                        .read(productFiltersProvider.notifier)
                        .updateFilters(ProductFilters(animalType: type));
                    context.go('/products');
                  },
                ),
                const SizedBox(height: 32),

                // Productos Destacados
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Productos Destacados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/products'),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid de productos destacados
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: featuredProducts.when(
              data: (products) => SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return RepaintBoundary(
                      child: ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          CustomSnackBar.showSuccess(
                            context,
                            '${product.name} añadido al carrito',
                          );
                        },
                      ),
                    );
                  },
                  addAutomaticKeepAlives: false,
                  childCount: products.length.clamp(0, 6),
                ),
              ),
              loading: () => SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ProductCardShimmer(),
                  childCount: 4,
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: ErrorState(
                  message: 'Error al cargar productos',
                  onRetry: () => ref.invalidate(featuredProductsProvider),
                ),
              ),
            ),
          ),

          // Footer sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Beneficios (como el footer de la web)
                const _BenefitsBar(),
                const SizedBox(height: 32),
                // Footer links
                const _AppFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== NOTIFICATION BANNER (purple bar) ====================
class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner();

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_shipping_outlined,
      'text': 'Envío GRATIS en pedidos +49€',
    },
    {
      'icon': Icons.card_giftcard,
      'text': '¡Consigue 5€ de descuento en compras +25€!',
    },
    {'icon': Icons.schedule, 'text': 'Entrega en 24-48h en toda España'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(
          () => _currentIndex = (_currentIndex + 1) % _notifications.length,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Padding(
          key: ValueKey(_currentIndex),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _notifications[_currentIndex]['icon'] as IconData,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _notifications[_currentIndex]['text'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HERO CAROUSEL ====================
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<_HeroSlide> _slides = [
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800&h=300&fit=crop&q=75',
      title: 'Todo para tu Perro',
      subtitle: 'Los mejores productos para el cuidado de tu mejor amigo',
      buttonText: 'Ver productos',
      route: '/products',
      gradient: AppTheme.heroGradientDog,
      buttonColor: AppTheme.primaryColor,
    ),
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&h=300&fit=crop&q=75',
      title: 'Mima a tu Gato',
      subtitle: 'Alimentación premium y accesorios para felinos exigentes',
      buttonText: 'Descubrir',
      route: '/products',
      gradient: AppTheme.heroGradientCat,
      buttonColor: AppTheme.secondaryColor,
    ),
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=800&h=300&fit=crop&q=75',
      title: 'Tus Favoritos',
      subtitle:
          'Guarda los productos que más te gustan y encuéntralos fácilmente',
      buttonText: 'Ver favoritos',
      route: '/favorites',
      gradient: AppTheme.heroGradientFav,
      buttonColor: AppTheme.errorColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  /// Rutas dentro del ShellRoute usan go(), las demás push()
  static const _shellRoutes = {
    '/',
    '/products',
    '/cart',
    '/orders',
    '/profile',
  };

  void _navigateToRoute(BuildContext context, String route) {
    if (_shellRoutes.contains(route)) {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return GestureDetector(
                onTap: () => _navigateToRoute(context, slide.route),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: slide.imageUrl,
                      memCacheWidth: 500,
                      memCacheHeight: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: Colors.grey[200]),
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.pets,
                          size: 48,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(gradient: slide.gradient),
                    ),
                    Positioned(
                      left: 24,
                      top: 0,
                      bottom: 0,
                      right: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _navigateToRoute(context, slide.route),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: slide.buttonColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusFull,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              slide.buttonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Dots indicator
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 12 : 8,
                  height: _currentPage == i ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Navigation arrows
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_left,
                onTap: () {
                  final prev =
                      (_currentPage - 1 + _slides.length) % _slides.length;
                  _pageController.animateToPage(
                    prev,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_right,
                onTap: () {
                  final next = (_currentPage + 1) % _slides.length;
                  _pageController.animateToPage(
                    next,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final String route;
  final LinearGradient gradient;
  final Color buttonColor;

  const _HeroSlide({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.route,
    required this.gradient,
    required this.buttonColor,
  });
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 24),
      ),
    );
  }
}

// ==================== ANIMAL TYPE SELECTOR ====================
class _AnimalTypeSelector extends StatelessWidget {
  final ValueChanged<AnimalType> onSelected;

  const _AnimalTypeSelector({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AnimalType.values.map((type) {
            final colors = _getTypeColors(type);
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(type),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors['bg'],
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMd,
                    ),
                    border: Border.all(color: colors['border']!, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getEmoji(type),
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors['text'],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitle(type),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors['subtext'],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<String, Color> _getTypeColors(AnimalType type) {
    switch (type) {
      case AnimalType.perro:
        return {
          'bg': const Color(0xFFFAF5FF),
          'border': const Color(0xFFE9D5FF),
          'text': AppTheme.primaryColor,
          'subtext': AppTheme.textSecondary,
        };
      case AnimalType.gato:
        return {
          'bg': const Color(0xFFFFF7ED),
          'border': const Color(0xFFFED7AA),
          'text': AppTheme.secondaryColor,
          'subtext': AppTheme.textSecondary,
        };
      case AnimalType.otros:
        return {
          'bg': const Color(0xFFF0FDF4),
          'border': const Color(0xFFBBF7D0),
          'text': AppTheme.successColor,
          'subtext': AppTheme.textSecondary,
        };
    }
  }

  String _getSubtitle(AnimalType type) {
    switch (type) {
      case AnimalType.perro:
        return 'Tu mejor amigo';
      case AnimalType.gato:
        return 'Felinos exigentes';
      case AnimalType.otros:
        return 'Conejos, aves y más';
    }
  }

  String _getEmoji(AnimalType type) {
    switch (type) {
      case AnimalType.perro:
        return '🐶';
      case AnimalType.gato:
        return '🐱';
      case AnimalType.otros:
        return '🐰';
    }
  }
}

// ==================== BENEFITS BAR (footer web) ====================
class _BenefitsBar extends StatelessWidget {
  const _BenefitsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.footerColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          _BenefitItem(
            icon: Icons.local_shipping,
            title: 'Envío Gratis',
            subtitle: 'En pedidos +49€',
          ),
          _BenefitItem(
            icon: Icons.calendar_today,
            title: '30 días',
            subtitle: 'Para devoluciones',
          ),
          _BenefitItem(
            icon: Icons.lock_outline,
            title: 'Pago Seguro',
            subtitle: 'SSL + Stripe',
          ),
          _BenefitItem(
            icon: Icons.headset_mic,
            title: 'Atención 24/7',
            subtitle: 'Siempre disponibles',
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== APP FOOTER ====================
class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.footerColor,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & description
          Row(
            children: [
              Icon(Icons.pets, color: AppTheme.primaryLight, size: 28),
              const SizedBox(width: 8),
              const Text(
                'BeniceAstro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tu tienda de confianza para el cuidado de tus mascotas',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Links sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tienda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tienda',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FooterLink(
                      text: 'Perros',
                      onTap: () => context.go('/products'),
                    ),
                    _FooterLink(
                      text: 'Gatos',
                      onTap: () => context.go('/products'),
                    ),
                    _FooterLink(
                      text: 'Ofertas',
                      onTap: () => context.push('/ofertas'),
                    ),
                    _FooterLink(
                      text: 'Todos los productos',
                      onTap: () => context.go('/products'),
                    ),
                  ],
                ),
              ),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FooterLink(
                      text: 'Sobre nosotros',
                      onTap: () => context.push('/about'),
                    ),
                    _FooterLink(
                      text: 'Contacto',
                      onTap: () => context.push('/contact'),
                    ),
                    _FooterLink(
                      text: 'Preguntas frecuentes',
                      onTap: () => context.push('/faq'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ayuda',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FooterLink(
                      text: 'Envíos y devoluciones',
                      onTap: () => context.push('/shipping'),
                    ),
                    _FooterLink(
                      text: 'Términos y condiciones',
                      onTap: () => context.push('/terms'),
                    ),
                    _FooterLink(
                      text: 'Política de privacidad',
                      onTap: () => context.push('/privacy'),
                    ),
                    _FooterLink(
                      text: 'Política de cookies',
                      onTap: () => context.push('/cookies'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contacto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FooterLink(text: '900 123 456', onTap: () {}),
                    _FooterLink(text: 'info@benice.com', onTap: () {}),
                    _FooterLink(text: 'WhatsApp', onTap: () {}),
                    Text(
                      'Calle Gran Vía, 123\n28013 Madrid',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          // Divider
          Divider(color: Colors.grey[800]),
          const SizedBox(height: 12),
          // Copyright
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '© ${DateTime.now().year} BeniceAstro Pet Shop',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pagos: ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  _PaymentBadge('Visa'),
                  _PaymentBadge('MC'),
                  _PaymentBadge('PayPal'),
                  _PaymentBadge('Apple Pay'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String text;
  const _PaymentBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
