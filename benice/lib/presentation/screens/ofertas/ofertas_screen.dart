import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/product/product_card.dart';

class OfertasScreen extends ConsumerStatefulWidget {
  const OfertasScreen({super.key});

  @override
  ConsumerState<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends ConsumerState<OfertasScreen> {
  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(hours: 23, minutes: 59, seconds: 59);

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    // Filtrar productos con descuento
    final ofertaProducts = productsAsync.products
        .where((p) => p.hasDiscount)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // Header con countdown
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B35),
                      Color(0xFFFF8E53),
                      Color(0xFFFED330),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        '🔥 OFERTAS FLASH 🔥',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Descuentos por tiempo limitado',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      // Countdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CountdownBox(
                            value: _remainingTime.inHours.toString().padLeft(
                              2,
                              '0',
                            ),
                            label: 'Horas',
                          ),
                          const Text(
                            ' : ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          _CountdownBox(
                            value: (_remainingTime.inMinutes % 60)
                                .toString()
                                .padLeft(2, '0'),
                            label: 'Min',
                          ),
                          const Text(
                            ' : ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          _CountdownBox(
                            value: (_remainingTime.inSeconds % 60)
                                .toString()
                                .padLeft(2, '0'),
                            label: 'Seg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Banner cupón
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
              ),
              child: const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Suscríbete y obtén un 10% extra!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Usa el código BIENVENIDO10',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid de productos en oferta
          if (ofertaProducts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay ofertas activas ahora',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '¡Vuelve pronto!',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ProductCard(product: ofertaProducts[index]),
                  childCount: ofertaProducts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}
