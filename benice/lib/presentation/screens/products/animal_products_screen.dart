import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../widgets/product/product_card.dart';

class AnimalProductsScreen extends ConsumerWidget {
  final AnimalType animalType;
  const AnimalProductsScreen({super.key, required this.animalType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByAnimalTypeProvider(animalType));

    final config = _getAnimalConfig(animalType);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => context.pop(),
            ),
            backgroundColor: config['color'] as Color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config['color'] as Color,
                      (config['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              config['emoji'] as String,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Productos para ${config['name']}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    config['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Breadcrumb
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Text(
                      'Inicio',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                  Text(
                    config['name'] as String,
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categorías
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: (config['categories'] as List<Map<String, String>>)
                          .map((cat) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => context.push(
                                  '/products?animal=${animalType.name}&category=${cat['id']}',
                                ),
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cat['icon']!,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat['name']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtro por edad
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Por edad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: (config['ages'] as List<Map<String, String>>).map((
                      age,
                    ) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => context.push(
                              '/products?animal=${animalType.name}&age=${age['id']}',
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (config['color'] as Color).withOpacity(0.1),
                                    (config['color'] as Color).withOpacity(
                                      0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (config['color'] as Color).withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    age['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: config['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    age['desc']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Productos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Todos los Productos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/products?animal=${animalType.name}'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),
          ),

          productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles aún',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAnimalConfig(AnimalType type) {
    switch (type) {
      case AnimalType.perro:
        return {
          'name': 'Perros',
          'emoji': '🐕',
          'description':
              'Todo lo que tu perro necesita para ser feliz y estar sano',
          'color': Colors.blue,
          'categories': <Map<String, String>>[
            {'id': 'alimentacion', 'name': 'Alimentación', 'icon': '🍖'},
            {'id': 'juguetes', 'name': 'Juguetes', 'icon': '🎾'},
            {'id': 'higiene', 'name': 'Higiene', 'icon': '🧴'},
            {'id': 'salud', 'name': 'Salud', 'icon': '💊'},
            {'id': 'accesorios', 'name': 'Accesorios', 'icon': '🦴'},
          ],
          'ages': <Map<String, String>>[
            {'id': 'cachorro', 'name': 'Cachorro', 'desc': '0-12 meses'},
            {'id': 'adulto', 'name': 'Adulto', 'desc': '1-7 años'},
            {'id': 'senior', 'name': 'Senior', 'desc': '+7 años'},
          ],
        };
      case AnimalType.gato:
        return {
          'name': 'Gatos',
          'emoji': '🐈',
          'description':
              'Alimentación premium y accesorios para felinos exigentes',
          'color': Colors.orange,
          'categories': <Map<String, String>>[
            {'id': 'alimentacion', 'name': 'Alimentación', 'icon': '🐟'},
            {'id': 'juguetes', 'name': 'Juguetes', 'icon': '🐭'},
            {'id': 'higiene', 'name': 'Higiene', 'icon': '🧹'},
            {'id': 'salud', 'name': 'Salud', 'icon': '💊'},
            {'id': 'accesorios', 'name': 'Accesorios', 'icon': '🏠'},
          ],
          'ages': <Map<String, String>>[
            {'id': 'cachorro', 'name': 'Gatito', 'desc': '0-12 meses'},
            {'id': 'adulto', 'name': 'Adulto', 'desc': '1-7 años'},
            {'id': 'senior', 'name': 'Senior', 'desc': '+7 años'},
          ],
        };
      case AnimalType.otro:
        return {
          'name': 'Otros Animales',
          'emoji': '🐾',
          'description': 'Pájaros, peces, roedores y más',
          'color': Colors.green,
          'categories': <Map<String, String>>[
            {'id': 'alimentacion', 'name': 'Alimentación', 'icon': '🌾'},
            {'id': 'accesorios', 'name': 'Accesorios', 'icon': '🏠'},
            {'id': 'salud', 'name': 'Salud', 'icon': '💊'},
            {'id': 'juguetes', 'name': 'Juguetes', 'icon': '🎡'},
          ],
          'ages': <Map<String, String>>[
            {'id': 'cachorro', 'name': 'Joven', 'desc': 'Primeros meses'},
            {'id': 'adulto', 'name': 'Adulto', 'desc': 'Edad adulta'},
            {'id': 'senior', 'name': 'Senior', 'desc': 'Edad avanzada'},
          ],
        };
    }
  }
}
