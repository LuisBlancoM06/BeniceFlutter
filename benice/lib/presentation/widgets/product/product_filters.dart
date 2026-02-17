import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';

/// Barra de filtros de productos
class ProductFilterBar extends StatelessWidget {
  final ProductFilters filters;
  final ValueChanged<ProductFilters> onFiltersChanged;
  final VoidCallback? onClearFilters;

  const ProductFilterBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Botón limpiar filtros
            if (filters.hasActiveFilters) ...[
              ActionChip(
                label: const Text('Limpiar'),
                avatar: const Icon(Icons.clear, size: 18),
                onPressed: onClearFilters,
                backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: AppTheme.errorColor),
              ),
              const SizedBox(width: 8),
            ],
            // Tipo de animal
            _FilterDropdown<AnimalType>(
              label: 'Animal',
              value: filters.animalType,
              items: AnimalType.values,
              itemLabel: (e) => e.label,
              onChanged: (value) {
                if (value == filters.animalType) {
                  onFiltersChanged(filters.copyWith(clearAnimalType: true));
                } else {
                  onFiltersChanged(filters.copyWith(animalType: value));
                }
              },
            ),
            const SizedBox(width: 8),
            // Categoría
            _FilterDropdown<ProductCategory>(
              label: 'Categoría',
              value: filters.category,
              items: ProductCategory.values,
              itemLabel: (e) => e.label,
              onChanged: (value) {
                if (value == filters.category) {
                  onFiltersChanged(filters.copyWith(clearCategory: true));
                } else {
                  onFiltersChanged(filters.copyWith(category: value));
                }
              },
            ),
            const SizedBox(width: 8),
            // Tamaño
            _FilterDropdown<AnimalSize>(
              label: 'Tamaño',
              value: filters.animalSize,
              items: AnimalSize.values,
              itemLabel: (e) => e.label,
              onChanged: (value) {
                if (value == filters.animalSize) {
                  onFiltersChanged(filters.copyWith(clearAnimalSize: true));
                } else {
                  onFiltersChanged(filters.copyWith(animalSize: value));
                }
              },
            ),
            const SizedBox(width: 8),
            // Edad
            _FilterDropdown<AnimalAge>(
              label: 'Edad',
              value: filters.animalAge,
              items: AnimalAge.values,
              itemLabel: (e) => e.label,
              onChanged: (value) {
                if (value == filters.animalAge) {
                  onFiltersChanged(filters.copyWith(clearAnimalAge: true));
                } else {
                  onFiltersChanged(filters.copyWith(animalAge: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value != null;

    return PopupMenuButton<T>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      ),
      itemBuilder: (context) => items.map((item) {
        final isItemSelected = item == value;
        return PopupMenuItem(
          value: item,
          child: Row(
            children: [
              if (isItemSelected)
                const Icon(Icons.check, size: 18, color: AppTheme.primaryColor)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(itemLabel(item)),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? itemLabel(value as T) : label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal de filtros completo
class FiltersBottomSheet extends StatefulWidget {
  final ProductFilters initialFilters;
  final ValueChanged<ProductFilters> onApply;

  const FiltersBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductFilters initialFilters,
    required ValueChanged<ProductFilters> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FiltersBottomSheet(initialFilters: initialFilters, onApply: onApply),
    );
  }

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late ProductFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _filters = const ProductFilters()),
                      child: const Text('Limpiar todo'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tipo de animal
                    _FilterSection(
                      title: 'Tipo de Animal',
                      children: AnimalType.values.map((type) {
                        return _FilterChip(
                          label: type.label,
                          isSelected: _filters.animalType == type,
                          onTap: () => setState(() {
                            _filters = _filters.animalType == type
                                ? _filters.copyWith(clearAnimalType: true)
                                : _filters.copyWith(animalType: type);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Categoría
                    _FilterSection(
                      title: 'Categoría',
                      children: ProductCategory.values.map((cat) {
                        return _FilterChip(
                          label: cat.label,
                          isSelected: _filters.category == cat,
                          onTap: () => setState(() {
                            _filters = _filters.category == cat
                                ? _filters.copyWith(clearCategory: true)
                                : _filters.copyWith(category: cat);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Tamaño
                    _FilterSection(
                      title: 'Tamaño del Animal',
                      children: AnimalSize.values.map((size) {
                        return _FilterChip(
                          label: size.label,
                          subtitle: size.description,
                          isSelected: _filters.animalSize == size,
                          onTap: () => setState(() {
                            _filters = _filters.animalSize == size
                                ? _filters.copyWith(clearAnimalSize: true)
                                : _filters.copyWith(animalSize: size);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Edad
                    _FilterSection(
                      title: 'Edad del Animal',
                      children: AnimalAge.values.map((age) {
                        return _FilterChip(
                          label: age.label,
                          subtitle: age.ageRange,
                          isSelected: _filters.animalAge == age,
                          onTap: () => setState(() {
                            _filters = _filters.animalAge == age
                                ? _filters.copyWith(clearAnimalAge: true)
                                : _filters.copyWith(animalAge: age);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Opciones adicionales
                    _FilterSection(
                      title: 'Opciones',
                      children: [
                        _FilterChip(
                          label: 'Con descuento',
                          isSelected: _filters.onlyWithDiscount == true,
                          onTap: () => setState(() {
                            _filters = _filters.copyWith(
                              onlyWithDiscount:
                                  _filters.onlyWithDiscount == true
                                  ? null
                                  : true,
                            );
                          }),
                        ),
                        _FilterChip(
                          label: 'En stock',
                          isSelected: _filters.onlyInStock == true,
                          onTap: () => setState(() {
                            _filters = _filters.copyWith(
                              onlyInStock: _filters.onlyInStock == true
                                  ? null
                                  : true,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_filters);
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
