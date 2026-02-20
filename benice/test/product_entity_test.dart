import 'package:flutter_test/flutter_test.dart';
import 'package:benice/domain/entities/entities.dart';
import 'package:benice/core/constants/app_constants.dart';

void main() {
  group('ProductEntity pricing helpers', () {
    ProductEntity buildProduct({
      required double price,
      double? discountPrice,
      bool onSale = false,
    }) {
      return ProductEntity(
        id: 'p1',
        name: 'Producto test',
        slug: 'producto-test',
        description: 'Descripción',
        price: price,
        discountPrice: discountPrice,
        onSale: onSale,
        imageUrl: null,
        images: const [],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 10,
        brand: 'Benice',
        createdAt: DateTime(2026, 1, 1),
      );
    }

    test('hasDiscount true when onSale and discountPrice lower than price', () {
      final product = buildProduct(price: 20, discountPrice: 15, onSale: true);

      expect(product.hasDiscount, isTrue);
      expect(product.finalPrice, 15);
      expect(product.discountPercentage, 25);
    });

    test('hasDiscount false when onSale is false', () {
      final product = buildProduct(price: 20, discountPrice: 15, onSale: false);

      expect(product.hasDiscount, isFalse);
      expect(product.finalPrice, 20);
      expect(product.discountPercentage, 0);
    });

    test('hasDiscount false when discountPrice is null', () {
      final product = buildProduct(
        price: 20,
        discountPrice: null,
        onSale: true,
      );

      expect(product.hasDiscount, isFalse);
      expect(product.finalPrice, 20);
      expect(product.discountPercentage, 0);
    });
  });
}
