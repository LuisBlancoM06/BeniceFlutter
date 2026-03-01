import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';

/// Pantalla para crear/editar un producto (admin)
class AdminProductFormScreen extends ConsumerStatefulWidget {
  final String? productId; // null = crear nuevo

  const AdminProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  final _imageUrlController = TextEditingController();

  AnimalType _animalType = AnimalType.perro;
  AnimalSize _animalSize = AnimalSize.mediano;
  ProductCategory _category = ProductCategory.alimentacion;
  AnimalAge _animalAge = AnimalAge.adulto;
  bool _isFeatured = false;
  bool _isSaving = false;
  bool _isLoadingProduct = false;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final result = await productRepo.getProductById(widget.productId!);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (product) {
          _nameController.text = product.name;
          _descController.text = product.description;
          _priceController.text = product.price.toString();
          if (product.discountPrice != null) {
            _discountPriceController.text = product.discountPrice.toString();
          }
          _stockController.text = product.stock.toString();
          _brandController.text = product.brand ?? '';
          if (product.imageUrl?.isNotEmpty == true) {
            _imageUrlController.text = product.imageUrl!;
          }
          _animalType = product.animalType;
          _animalSize = product.animalSize;
          _category = product.category;
          _animalAge = product.animalAge;
          _isFeatured = product.isFeatured;
        },
      );
    } catch (e) {
      debugPrint('Error cargando producto: $e');
    }
    if (mounted) setState(() => _isLoadingProduct = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _isLoadingProduct
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: const Color(0xFF1E1B4B),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
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
                                child: Icon(
                                  isEditing
                                      ? Icons.edit_rounded
                                      : Icons.add_box_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                isEditing
                                    ? 'Editar Producto'
                                    : 'Nuevo Producto',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información básica
                          _SectionCard(
                            title: 'Información Básica',
                            icon: Icons.info_rounded,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDeco(
                                  'Nombre del producto *',
                                  Icons.label_rounded,
                                ).copyWith(counterText: ''),
                                maxLength: Validators.maxProductName,
                                validator: Validators.productName,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _descController,
                                decoration: _inputDeco(
                                  'Descripción *',
                                  Icons.description_rounded,
                                ).copyWith(counterText: ''),
                                maxLines: 3,
                                maxLength: Validators.maxProductDesc,
                                validator: Validators.productDescription,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: _inputDeco(
                                  'URL de imagen',
                                  Icons.image_rounded,
                                ).copyWith(counterText: ''),
                                maxLength: Validators.maxUrl,
                                validator: Validators.url,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Precio y stock
                          _SectionCard(
                            title: 'Precio y Stock',
                            icon: Icons.euro_rounded,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      decoration: _inputDeco(
                                        'Precio (€) *',
                                        Icons.euro_rounded,
                                      ).copyWith(counterText: ''),
                                      keyboardType: TextInputType.number,
                                      maxLength: Validators.maxPrice,
                                      inputFormatters: [
                                        Validators.decimalNumber(),
                                      ],
                                      validator: Validators.price,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _discountPriceController,
                                      decoration: _inputDeco(
                                        'Precio oferta (€)',
                                        Icons.local_offer_rounded,
                                      ).copyWith(counterText: ''),
                                      keyboardType: TextInputType.number,
                                      maxLength: Validators.maxPrice,
                                      inputFormatters: [
                                        Validators.decimalNumber(),
                                      ],
                                      validator: (v) {
                                        final base = Validators.priceOptional(
                                          v,
                                        );
                                        if (base != null) return base;
                                        if (v != null &&
                                            v.isNotEmpty &&
                                            _priceController.text.isNotEmpty) {
                                          final discount = double.tryParse(v);
                                          final price = double.tryParse(
                                            _priceController.text,
                                          );
                                          if (discount != null &&
                                              price != null &&
                                              discount >= price) {
                                            return 'Debe ser menor que el precio';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _stockController,
                                      decoration: _inputDeco(
                                        'Stock *',
                                        Icons.inventory_rounded,
                                      ).copyWith(counterText: ''),
                                      keyboardType: TextInputType.number,
                                      maxLength: Validators.maxStock,
                                      inputFormatters: [
                                        Validators.digitsOnly(),
                                      ],
                                      validator: Validators.stock,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _brandController,
                                      decoration: _inputDeco(
                                        'Marca',
                                        Icons.business_rounded,
                                      ).copyWith(counterText: ''),
                                      maxLength: Validators.maxBrand,
                                      validator: Validators.brand,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Clasificación
                          _SectionCard(
                            title: 'Clasificación',
                            icon: Icons.category_rounded,
                            children: [
                              DropdownButtonFormField<AnimalType>(
                                initialValue: _animalType,
                                decoration: _inputDeco(
                                  'Tipo de Animal',
                                  Icons.pets_rounded,
                                ),
                                items: AnimalType.values
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _animalType = v!),
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<ProductCategory>(
                                initialValue: _category,
                                decoration: _inputDeco(
                                  'Categoría',
                                  Icons.grid_view_rounded,
                                ),
                                items: ProductCategory.values
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _category = v!),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<AnimalSize>(
                                      initialValue: _animalSize,
                                      decoration: _inputDeco(
                                        'Tamaño',
                                        Icons.straighten_rounded,
                                      ),
                                      items: AnimalSize.values
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s.label),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _animalSize = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<AnimalAge>(
                                      initialValue: _animalAge,
                                      decoration: _inputDeco(
                                        'Edad',
                                        Icons.cake_rounded,
                                      ),
                                      items: AnimalAge.values
                                          .map(
                                            (a) => DropdownMenuItem(
                                              value: a,
                                              child: Text(a.label),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _animalAge = v!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Destacado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
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
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Producto Destacado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Aparecerá en la página de inicio',
                              ),
                              value: _isFeatured,
                              onChanged: (v) => setState(() => _isFeatured = v),
                              activeThumbColor: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón guardar
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveProduct,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(
                                isEditing
                                    ? 'Guardar Cambios'
                                    : 'Crear Producto',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.parse(_priceController.text),
      'sale_price': _discountPriceController.text.isNotEmpty
          ? double.parse(_discountPriceController.text)
          : null,
      'on_sale': _discountPriceController.text.isNotEmpty,
      'stock': int.parse(_stockController.text),
      'brand': _brandController.text.isNotEmpty
          ? _brandController.text
          : 'BeniceAstro',
      'image_url': _imageUrlController.text,
      'animal_type': _animalType.name,
      'size': _animalSize.name,
      'category': _category.name,
      'age_range': _animalAge.name,
    };

    final adminRepo = ref.read(adminRepositoryProvider);

    final result = isEditing
        ? await adminRepo.updateProduct(widget.productId!, data)
        : await adminRepo.createProduct(data);

    if (mounted) {
      setState(() => _isSaving = false);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        },
        (_) {
          ref.read(adminProductsProvider.notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Producto actualizado' : 'Producto creado',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.of(context).pop();
        },
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
