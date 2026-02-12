import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

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

  bool get isEditing => widget.productId != null;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto *',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Precio y Precio descuento
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio (€) *',
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null)
                          return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _discountPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio oferta (€)',
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock y Marca
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (int.tryParse(v) == null) return 'Entero inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // URL de imagen
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 24),

              // Clasificación
              const Text(
                'Clasificación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Tipo de animal
              DropdownButtonFormField<AnimalType>(
                value: _animalType,
                decoration: const InputDecoration(labelText: 'Tipo de Animal'),
                items: AnimalType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text('${t.emoji} ${t.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _animalType = v!),
              ),
              const SizedBox(height: 12),

              // Categoría
              DropdownButtonFormField<ProductCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: ProductCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.emoji} ${c.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),

              // Tamaño
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<AnimalSize>(
                      value: _animalSize,
                      decoration: const InputDecoration(labelText: 'Tamaño'),
                      items: AnimalSize.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _animalSize = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<AnimalAge>(
                      value: _animalAge,
                      decoration: const InputDecoration(labelText: 'Edad'),
                      items: AnimalAge.values
                          .map(
                            (a) => DropdownMenuItem(
                              value: a,
                              child: Text(a.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _animalAge = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Destacado
              SwitchListTile(
                title: const Text('Producto Destacado'),
                subtitle: const Text('Aparecerá en la página de inicio'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                      : const Icon(Icons.save),
                  label: Text(isEditing ? 'Guardar Cambios' : 'Crear Producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1)); // Simular guardado

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Producto actualizado' : 'Producto creado'),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
