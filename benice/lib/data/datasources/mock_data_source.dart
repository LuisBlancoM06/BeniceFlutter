import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Datos de prueba para desarrollo sin backend
class MockDataSource {
  // Usuario de prueba
  static UserModel getMockUser() {
    return UserModel(
      id: 'user-001',
      email: 'usuario@beniceastro.com',
      name: 'Usuario Demo',
      fullName: 'Usuario Demo',
      phone: '+34 600 123 456',
      address: 'Calle Principal 123',
      city: 'Madrid',
      postalCode: '28001',
      role: 'admin', // Para poder acceder al panel admin en demo
      isSubscribedNewsletter: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  // Productos de prueba
  static List<ProductModel> getMockProducts() {
    return [
      // PERROS - Alimentación
      ProductModel(
        id: 'prod-001',
        name: 'Pienso Premium para Perros Adultos',
        description:
            'Alimento completo y equilibrado para perros adultos de todas las razas. Elaborado con ingredientes de alta calidad, rico en proteínas y vitaminas esenciales para mantener a tu perro sano y activo.',
        price: 45.99,
        discountPrice: 39.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?w=500',
          'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 50,
        brand: 'NutroPet',
        rating: 4.8,
        reviewsCount: 234,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      ProductModel(
        id: 'prod-002',
        name: 'Comida Húmeda para Cachorros',
        description:
            'Deliciosas latas de comida húmeda especialmente formulada para cachorros. Con trozos de pollo real y verduras para un crecimiento saludable.',
        price: 24.99,
        images: [
          'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mini,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.cachorro,
        stock: 100,
        brand: 'PuppyLove',
        rating: 4.6,
        reviewsCount: 156,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      // PERROS - Juguetes
      ProductModel(
        id: 'prod-003',
        name: 'Pelota Resistente para Perros Grandes',
        description:
            'Pelota de goma duradera ideal para perros grandes y enérgicos. Resistente a mordiscos, perfecta para juegos de lanzar y buscar.',
        price: 12.99,
        discountPrice: 9.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.grande,
        category: ProductCategory.juguetes,
        animalAge: AnimalAge.adulto,
        stock: 75,
        brand: 'PlayPet',
        rating: 4.7,
        reviewsCount: 89,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProductModel(
        id: 'prod-004',
        name: 'Cuerda de Juego Interactivo',
        description:
            'Cuerda multicolor de algodón natural para juegos de tira y afloja. Ayuda a mantener los dientes limpios mientras tu perro se divierte.',
        price: 8.99,
        images: [
          'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.juguetes,
        animalAge: AnimalAge.adulto,
        stock: 120,
        brand: 'FunPet',
        rating: 4.5,
        reviewsCount: 67,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      // PERROS - Higiene
      ProductModel(
        id: 'prod-005',
        name: 'Champú Natural para Perros',
        description:
            'Champú suave con ingredientes naturales como aloe vera y avena. Ideal para pieles sensibles. Deja el pelaje suave y brillante.',
        price: 15.99,
        images: [
          'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.higiene,
        animalAge: AnimalAge.adulto,
        stock: 80,
        brand: 'NaturePet',
        rating: 4.9,
        reviewsCount: 178,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      // PERROS - Salud
      ProductModel(
        id: 'prod-006',
        name: 'Vitaminas para Perros Senior',
        description:
            'Suplemento vitamínico especialmente formulado para perros mayores. Contiene glucosamina para articulaciones y omega-3 para el pelaje.',
        price: 28.99,
        images: [
          'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.salud,
        animalAge: AnimalAge.senior,
        stock: 40,
        brand: 'VitaPet',
        rating: 4.7,
        reviewsCount: 95,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      // PERROS - Accesorios
      ProductModel(
        id: 'prod-007',
        name: 'Collar Ajustable con GPS',
        description:
            'Collar de nylon resistente con localizador GPS integrado. Rastrea a tu mascota desde tu móvil. Batería de larga duración.',
        price: 89.99,
        discountPrice: 74.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.grande,
        category: ProductCategory.accesorios,
        animalAge: AnimalAge.adulto,
        stock: 25,
        brand: 'TechPet',
        rating: 4.4,
        reviewsCount: 56,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ProductModel(
        id: 'prod-008',
        name: 'Cama Ortopédica para Perros',
        description:
            'Cama con espuma viscoelástica de alta densidad. Alivia la presión en articulaciones. Funda lavable y antideslizante.',
        price: 65.99,
        images: [
          'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=500',
        ],
        animalType: AnimalType.perro,
        animalSize: AnimalSize.grande,
        category: ProductCategory.accesorios,
        animalAge: AnimalAge.senior,
        stock: 30,
        brand: 'ComfortPet',
        rating: 4.8,
        reviewsCount: 112,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      // GATOS - Alimentación
      ProductModel(
        id: 'prod-009',
        name: 'Pienso Gourmet para Gatos',
        description:
            'Alimento premium para gatos adultos elaborado con salmón fresco. Alto contenido en proteínas y ácidos grasos omega-3 para un pelaje brillante.',
        price: 38.99,
        discountPrice: 32.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 60,
        brand: 'FeliGourmet',
        rating: 4.9,
        reviewsCount: 287,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      ProductModel(
        id: 'prod-010',
        name: 'Snacks Dentales para Gatos',
        description:
            'Premios crujientes que ayudan a mantener los dientes limpios. Con sabor a pollo irresistible para tu felino.',
        price: 9.99,
        images: [
          'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mini,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 150,
        brand: 'CatTreats',
        rating: 4.6,
        reviewsCount: 134,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
      ),
      // GATOS - Juguetes
      ProductModel(
        id: 'prod-011',
        name: 'Ratón Interactivo con Movimiento',
        description:
            'Ratón de juguete con movimiento automático aleatorio. Mantiene a tu gato entretenido durante horas. Funciona con pilas.',
        price: 14.99,
        images: [
          'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mini,
        category: ProductCategory.juguetes,
        animalAge: AnimalAge.cachorro,
        stock: 90,
        brand: 'PlayCat',
        rating: 4.5,
        reviewsCount: 78,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      ProductModel(
        id: 'prod-012',
        name: 'Torre Rascador Multi-nivel',
        description:
            'Árbol rascador con múltiples plataformas, cueva y poste de sisal. Perfecto para que tu gato trepe, descanse y afile sus uñas.',
        price: 79.99,
        discountPrice: 64.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.juguetes,
        animalAge: AnimalAge.adulto,
        stock: 20,
        brand: 'CatWorld',
        rating: 4.8,
        reviewsCount: 145,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      // GATOS - Higiene
      ProductModel(
        id: 'prod-013',
        name: 'Arena Aglomerante Sin Olor',
        description:
            'Arena de bentonita premium con control de olores avanzado. Fácil de limpiar y de larga duración. 10kg.',
        price: 18.99,
        images: [
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.higiene,
        animalAge: AnimalAge.adulto,
        stock: 200,
        brand: 'CleanCat',
        rating: 4.7,
        reviewsCount: 312,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // GATOS - Accesorios
      ProductModel(
        id: 'prod-014',
        name: 'Transportín Plegable',
        description:
            'Transportín ligero y plegable para gatos. Con ventilación lateral y apertura superior. Ideal para viajes al veterinario.',
        price: 35.99,
        images: [
          'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=500',
        ],
        animalType: AnimalType.gato,
        animalSize: AnimalSize.mediano,
        category: ProductCategory.accesorios,
        animalAge: AnimalAge.adulto,
        stock: 45,
        brand: 'TravelCat',
        rating: 4.6,
        reviewsCount: 89,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      // OTROS ANIMALES
      ProductModel(
        id: 'prod-015',
        name: 'Heno Premium para Conejos',
        description:
            'Heno timothy de primera calidad, alto en fibra y bajo en proteínas. Esencial para la dieta de conejos y cobayas.',
        price: 12.99,
        images: [
          'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=500',
        ],
        animalType: AnimalType.otro,
        animalSize: AnimalSize.mini,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 80,
        brand: 'BunnyFood',
        rating: 4.8,
        reviewsCount: 67,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ProductModel(
        id: 'prod-016',
        name: 'Jaula Grande para Hámster',
        description:
            'Jaula espaciosa con rueda de ejercicio, bebedero y casita incluidos. Barras de metal resistentes y bandeja extraíble.',
        price: 49.99,
        discountPrice: 42.99,
        onSale: true,
        images: [
          'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=500',
        ],
        animalType: AnimalType.otro,
        animalSize: AnimalSize.mini,
        category: ProductCategory.accesorios,
        animalAge: AnimalAge.adulto,
        stock: 35,
        brand: 'SmallPetHome',
        rating: 4.5,
        reviewsCount: 45,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 38)),
      ),
      ProductModel(
        id: 'prod-017',
        name: 'Semillas Mixtas para Aves',
        description:
            'Mezcla de semillas variadas de alta calidad para canarios, periquitos y otras aves. Rico en nutrientes esenciales.',
        price: 8.99,
        images: [
          'https://images.unsplash.com/photo-1452570053594-1b985d6ea890?w=500',
        ],
        animalType: AnimalType.otro,
        animalSize: AnimalSize.mini,
        category: ProductCategory.alimentacion,
        animalAge: AnimalAge.adulto,
        stock: 100,
        brand: 'BirdSeed',
        rating: 4.6,
        reviewsCount: 78,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ProductModel(
        id: 'prod-018',
        name: 'Comedero Automático para Peces',
        description:
            'Dispensador automático programable para acuarios. Mantén alimentados a tus peces incluso cuando no estés en casa.',
        price: 24.99,
        images: [
          'https://images.unsplash.com/photo-1520302630591-fd1c66edc19d?w=500',
        ],
        animalType: AnimalType.otro,
        animalSize: AnimalSize.mini,
        category: ProductCategory.accesorios,
        animalAge: AnimalAge.adulto,
        stock: 55,
        brand: 'AquaTech',
        rating: 4.4,
        reviewsCount: 34,
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(days: 42)),
      ),
    ];
  }

  // Códigos de descuento de prueba
  static List<DiscountCodeModel> getMockDiscountCodes() {
    return [
      DiscountCodeModel(
        code: 'BIENVENIDO10',
        discountPercent: 10,
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(days: 365)),
      ),
      DiscountCodeModel(
        code: 'VERANO20',
        discountPercent: 20,
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(days: 90)),
      ),
      DiscountCodeModel(
        code: 'PRIMERACOMPRA',
        discountPercent: 15,
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      const DiscountCodeModel(
        code: 'CADUCADO',
        discountPercent: 25,
        isActive: false,
      ),
    ];
  }

  // Pedidos de prueba
  static List<OrderModel> getMockOrders(String userId) {
    return [
      OrderModel(
        id: 'order-001',
        orderNumber: 'ORD-001',
        userId: userId,
        items: [
          const OrderItemModel(
            id: 'item-001',
            productId: 'prod-001',
            productName: 'Pienso Premium para Perros Adultos',
            productImage:
                'https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?w=500',
            price: 39.99,
            quantity: 2,
          ),
          const OrderItemModel(
            id: 'item-002',
            productId: 'prod-005',
            productName: 'Champú Natural para Perros',
            productImage:
                'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=500',
            price: 15.99,
            quantity: 1,
          ),
        ],
        subtotal: 95.97,
        discount: 9.60,
        shippingCost: 0,
        total: 86.37,
        discountCode: 'BIENVENIDO10',
        status: OrderStatus.entregado,
        shippingAddress: 'Calle Principal 123, 28001 Madrid',
        trackingNumber: 'ES123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      OrderModel(
        id: 'order-002',
        orderNumber: 'ORD-002',
        userId: userId,
        items: [
          const OrderItemModel(
            id: 'item-003',
            productId: 'prod-009',
            productName: 'Pienso Gourmet para Gatos',
            productImage:
                'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500',
            price: 32.99,
            quantity: 1,
          ),
        ],
        subtotal: 32.99,
        discount: 0,
        shippingCost: 4.99,
        total: 37.98,
        status: OrderStatus.enviado,
        shippingAddress: 'Calle Principal 123, 28001 Madrid',
        trackingNumber: 'ES987654321',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      OrderModel(
        id: 'order-003',
        orderNumber: 'ORD-003',
        userId: userId,
        items: [
          const OrderItemModel(
            id: 'item-004',
            productId: 'prod-012',
            productName: 'Torre Rascador Multi-nivel',
            productImage:
                'https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?w=500',
            price: 64.99,
            quantity: 1,
          ),
        ],
        subtotal: 64.99,
        discount: 0,
        shippingCost: 0,
        total: 64.99,
        status: OrderStatus.pagado,
        shippingAddress: 'Calle Principal 123, 28001 Madrid',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      OrderModel(
        id: 'order-004',
        orderNumber: 'ORD-004',
        userId: userId,
        items: [
          const OrderItemModel(
            id: 'item-005',
            productId: 'prod-003',
            productName: 'Pelota Resistente para Perros Grandes',
            productImage:
                'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=500',
            price: 9.99,
            quantity: 3,
          ),
        ],
        subtotal: 29.97,
        discount: 0,
        shippingCost: 4.99,
        total: 34.96,
        status: OrderStatus.cancelado,
        shippingAddress: 'Calle Principal 123, 28001 Madrid',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  // Acceso estático a productos y pedidos
  static List<ProductModel> get mockProducts => getMockProducts();
  static List<OrderModel> get mockOrders => getMockOrders('user-001');
  static List<DiscountCodeModel> get mockDiscountCodes =>
      getMockDiscountCodes();

  // Reviews de prueba
  static List<ReviewEntity> getMockReviews(String productId) {
    return [
      ReviewEntity(
        id: 'rev-1',
        productId: productId,
        userId: 'user-002',
        userName: 'María García',
        rating: 5,
        comment: '¡Excelente producto! Mi perro está encantado.',
        verifiedPurchase: true,
        helpfulCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewEntity(
        id: 'rev-2',
        productId: productId,
        userId: 'user-003',
        userName: 'Carlos López',
        rating: 4,
        comment: 'Buena calidad, aunque el envío tardó un poco.',
        verifiedPurchase: true,
        helpfulCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ReviewEntity(
        id: 'rev-3',
        productId: productId,
        userId: 'user-004',
        userName: 'Ana Martínez',
        rating: 5,
        comment: 'Relación calidad-precio inmejorable. Repetiré.',
        verifiedPurchase: false,
        helpfulCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ReviewEntity(
        id: 'rev-4',
        productId: productId,
        userId: 'user-005',
        userName: 'Pedro Sánchez',
        rating: 3,
        comment: 'Cumple su función, nada especial.',
        verifiedPurchase: true,
        helpfulCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}
