import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/product/product_card.dart';

class RecommenderScreen extends ConsumerStatefulWidget {
  const RecommenderScreen({super.key});

  @override
  ConsumerState<RecommenderScreen> createState() => _RecommenderScreenState();
}

class _RecommenderScreenState extends ConsumerState<RecommenderScreen> {
  int _currentStep = 0;
  AnimalType? _selectedAnimal;
  String? _selectedAge;
  String? _selectedNeed;
  String? _selectedBudget;
  bool _showResults = false;

  final _steps = [
    {'question': '¿Qué mascota tienes?', 'key': 'animal'},
    {'question': '¿Qué edad tiene?', 'key': 'age'},
    {'question': '¿Qué necesitas?', 'key': 'need'},
    {'question': '¿Cuál es tu presupuesto?', 'key': 'budget'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendador'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _showResults ? _buildResults() : _buildWizard(),
    );
  }

  Widget _buildWizard() {
    return Column(
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.grey[50],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    '${_currentStep + 1} de ${_steps.length}',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.purple[600]),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _steps[_currentStep]['question']!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildStepContent()),
              ],
            ),
          ),
        ),

        // Nav buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Anterior'),
                ),
              const Spacer(),
              if (_currentStep < _steps.length - 1)
                ElevatedButton(
                  onPressed: _canAdvance()
                      ? () => setState(() => _currentStep++)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Siguiente'),
                )
              else
                ElevatedButton.icon(
                  onPressed: _canAdvance()
                      ? () => setState(() => _showResults = true)
                      : null,
                  icon: const Icon(Icons.search),
                  label: const Text('Ver Recomendaciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _canAdvance() {
    switch (_currentStep) {
      case 0:
        return _selectedAnimal != null;
      case 1:
        return _selectedAge != null;
      case 2:
        return _selectedNeed != null;
      case 3:
        return _selectedBudget != null;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAnimalStep();
      case 1:
        return _buildAgeStep();
      case 2:
        return _buildNeedStep();
      case 3:
        return _buildBudgetStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAnimalStep() {
    final animals = [
      {
        'type': AnimalType.perro,
        'emoji': '🐕',
        'name': 'Perro',
        'desc': 'Fieles compañeros',
      },
      {
        'type': AnimalType.gato,
        'emoji': '🐈',
        'name': 'Gato',
        'desc': 'Independientes y cariñosos',
      },
      {
        'type': AnimalType.otro,
        'emoji': '🐾',
        'name': 'Otro',
        'desc': 'Pájaros, peces, roedores...',
      },
    ];
    return ListView(
      children: animals
          .map(
            (a) => _OptionCard(
              emoji: a['emoji'] as String,
              title: a['name'] as String,
              subtitle: a['desc'] as String,
              selected: _selectedAnimal == a['type'],
              onTap: () =>
                  setState(() => _selectedAnimal = a['type'] as AnimalType),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAgeStep() {
    final ages = [
      {
        'id': 'cachorro',
        'emoji': '🍼',
        'name': _selectedAnimal == AnimalType.gato ? 'Gatito' : 'Cachorro',
        'desc': '0-12 meses',
      },
      {'id': 'adulto', 'emoji': '💪', 'name': 'Adulto', 'desc': '1-7 años'},
      {'id': 'senior', 'emoji': '👴', 'name': 'Senior', 'desc': '+7 años'},
    ];
    return ListView(
      children: ages
          .map(
            (a) => _OptionCard(
              emoji: a['emoji'] as String,
              title: a['name'] as String,
              subtitle: a['desc'] as String,
              selected: _selectedAge == a['id'],
              onTap: () => setState(() => _selectedAge = a['id'] as String),
            ),
          )
          .toList(),
    );
  }

  Widget _buildNeedStep() {
    final needs = [
      {
        'id': 'alimentacion',
        'emoji': '🍖',
        'name': 'Alimentación',
        'desc': 'Piensos y comida húmeda',
      },
      {
        'id': 'juguetes',
        'emoji': '🎾',
        'name': 'Juguetes',
        'desc': 'Diversión y estimulación',
      },
      {
        'id': 'higiene',
        'emoji': '🧴',
        'name': 'Higiene',
        'desc': 'Champús y cuidado',
      },
      {
        'id': 'salud',
        'emoji': '💊',
        'name': 'Salud',
        'desc': 'Vitaminas y suplementos',
      },
      {
        'id': 'accesorios',
        'emoji': '🦴',
        'name': 'Accesorios',
        'desc': 'Camas, collares y más',
      },
    ];
    return ListView(
      children: needs
          .map(
            (n) => _OptionCard(
              emoji: n['emoji'] as String,
              title: n['name'] as String,
              subtitle: n['desc'] as String,
              selected: _selectedNeed == n['id'],
              onTap: () => setState(() => _selectedNeed = n['id'] as String),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBudgetStep() {
    final budgets = [
      {'id': 'bajo', 'emoji': '💰', 'name': 'Económico', 'desc': 'Hasta 20€'},
      {'id': 'medio', 'emoji': '💰💰', 'name': 'Medio', 'desc': '20€ - 50€'},
      {
        'id': 'alto',
        'emoji': '💰💰💰',
        'name': 'Premium',
        'desc': 'Más de 50€',
      },
    ];
    return ListView(
      children: budgets
          .map(
            (b) => _OptionCard(
              emoji: b['emoji'] as String,
              title: b['name'] as String,
              subtitle: b['desc'] as String,
              selected: _selectedBudget == b['id'],
              onTap: () => setState(() => _selectedBudget = b['id'] as String),
            ),
          )
          .toList(),
    );
  }

  Widget _buildResults() {
    final productsAsync = ref.watch(
      filteredProductsProvider(
        ProductFilters(
          animalType: _selectedAnimal,
          category: _selectedNeed != null
              ? ProductCategory.values.firstWhere(
                  (c) => c.name == _selectedNeed,
                  orElse: () => ProductCategory.alimentacion,
                )
              : null,
          animalAge: _selectedAge != null
              ? AnimalAge.values.firstWhere(
                  (a) => a.name == _selectedAge,
                  orElse: () => AnimalAge.adulto,
                )
              : null,
        ),
      ),
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.purple.shade400],
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.recommend, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                '¡Tus recomendaciones!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Para ${_selectedAnimal?.label ?? ''} ${_selectedAge ?? ''} - ${_selectedNeed ?? ''}',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No encontramos productos exactos',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/products'),
                        child: const Text('Ver todos los productos'),
                      ),
                    ],
                  ),
                );
              }
              return ProductsGrid(
                products: products,
                onProductTap: (product) =>
                    context.push('/product/${product.id}'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              _showResults = false;
              _currentStep = 0;
              _selectedAnimal = null;
              _selectedAge = null;
              _selectedNeed = null;
              _selectedBudget = null;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Empezar de nuevo'),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? Colors.purple.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.purple.shade400 : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.purple.shade700
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
