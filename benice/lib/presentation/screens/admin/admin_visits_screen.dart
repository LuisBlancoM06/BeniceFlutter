import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class AdminVisitsScreen extends ConsumerWidget {
  const AdminVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF312E81),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(56, 8, 20, 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visitas y Analítica',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Estadísticas de tu tienda',
                                  style: TextStyle(
                                    color: Color(0xFFA5B4FC),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Las estadísticas se actualizan automáticamente. '
                            'Conecta Google Analytics para datos en tiempo real.',
                            style: TextStyle(
                              color: Color(0xFF3730A3),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KPIs
                  _sectionTitle('Resumen General', Icons.dashboard_rounded),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: const [
                      _VisitKPI(
                        title: 'Visitas Hoy',
                        value: '--',
                        icon: Icons.visibility_rounded,
                        color: Color(0xFF6366F1),
                        bgColor: Color(0xFFE0E7FF),
                      ),
                      _VisitKPI(
                        title: 'Visitas Mes',
                        value: '--',
                        icon: Icons.calendar_month_rounded,
                        color: Color(0xFFF97316),
                        bgColor: Color(0xFFFFF7ED),
                      ),
                      _VisitKPI(
                        title: 'Usuarios Únicos',
                        value: '--',
                        icon: Icons.people_rounded,
                        color: Color(0xFF10B981),
                        bgColor: Color(0xFFD1FAE5),
                      ),
                      _VisitKPI(
                        title: 'Tasa Conversión',
                        value: '--%',
                        icon: Icons.trending_up_rounded,
                        color: Color(0xFFF59E0B),
                        bgColor: Color(0xFFFEF3C7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Páginas populares
                  _sectionTitle('Páginas más Visitadas', Icons.article_rounded),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Column(
                      children: [
                        _PageRow(
                          page: '/',
                          name: 'Inicio',
                          visits: '--',
                          icon: Icons.home_rounded,
                        ),
                        _PageRow(
                          page: '/products',
                          name: 'Catálogo',
                          visits: '--',
                          icon: Icons.grid_view_rounded,
                        ),
                        _PageRow(
                          page: '/ofertas',
                          name: 'Ofertas Flash',
                          visits: '--',
                          icon: Icons.local_fire_department_rounded,
                        ),
                        _PageRow(
                          page: '/blog',
                          name: 'Blog',
                          visits: '--',
                          icon: Icons.article_rounded,
                        ),
                        _PageRow(
                          page: '/contact',
                          name: 'Contacto',
                          visits: '--',
                          icon: Icons.mail_rounded,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dispositivos
                  _sectionTitle('Dispositivos', Icons.devices_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        _DeviceBar(
                          label: 'Móvil',
                          icon: Icons.phone_android_rounded,
                          percentage: 0.65,
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(height: 14),
                        _DeviceBar(
                          label: 'Escritorio',
                          icon: Icons.desktop_windows_rounded,
                          percentage: 0.25,
                          color: Color(0xFFF97316),
                        ),
                        SizedBox(height: 14),
                        _DeviceBar(
                          label: 'Tablet',
                          icon: Icons.tablet_android_rounded,
                          percentage: 0.10,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fuentes de trafico
                  _sectionTitle('Fuentes de Tráfico', Icons.public_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        _TrafficSource(
                          source: 'Búsqueda Orgánica',
                          icon: Icons.search_rounded,
                          percentage: '--',
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(height: 10),
                        _TrafficSource(
                          source: 'Directo',
                          icon: Icons.link_rounded,
                          percentage: '--',
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(height: 10),
                        _TrafficSource(
                          source: 'Redes Sociales',
                          icon: Icons.share_rounded,
                          percentage: '--',
                          color: Color(0xFFF97316),
                        ),
                        SizedBox(height: 10),
                        _TrafficSource(
                          source: 'Referidos',
                          icon: Icons.people_outline_rounded,
                          percentage: '--',
                          color: Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _VisitKPI extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _VisitKPI({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageRow extends StatelessWidget {
  final String page;
  final String name;
  final String visits;
  final IconData icon;
  final bool isLast;

  const _PageRow({
    required this.page,
    required this.name,
    required this.visits,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  page,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              visits,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final double percentage;
  final Color color;

  const _DeviceBar({
    required this.label,
    required this.icon,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFF1F5F9),
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrafficSource extends StatelessWidget {
  final String source;
  final IconData icon;
  final String percentage;
  final Color color;

  const _TrafficSource({
    required this.source,
    required this.icon,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            source,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
