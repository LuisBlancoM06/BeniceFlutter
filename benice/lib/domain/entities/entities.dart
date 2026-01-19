import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Entidad de Usuario
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final bool isSubscribedNewsletter;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.avatarUrl,
    this.isSubscribedNewsletter = false,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
    bool? isSubscribedNewsletter,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSubscribedNewsletter:
          isSubscribedNewsletter ?? this.isSubscribedNewsletter,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    address,
    avatarUrl,
    isSubscribedNewsletter,
    createdAt,
  ];
}

/// Entidad de Producto
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final AnimalType animalType;
  final AnimalSize animalSize;
  final ProductCategory category;
  final AnimalAge animalAge;
  final int stock;
  final String? brand;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.animalType,
    required this.animalSize,
    required this.category,
    required this.animalAge,
    required this.stock,
    this.brand,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    required this.createdAt,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get finalPrice => discountPrice ?? price;
  int get discountPercentage =>
      hasDiscount ? ((1 - discountPrice! / price) * 100).round() : 0;
  bool get inStock => stock > 0;
  String get mainImage => images.isNotEmpty ? images.first : '';

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    discountPrice,
    images,
    animalType,
    animalSize,
    category,
    animalAge,
    stock,
    brand,
    rating,
    reviewsCount,
    isFeatured,
    createdAt,
  ];
}

/// Entidad de Item del Carrito
class CartItemEntity extends Equatable {
  final String id;
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.finalPrice * quantity;

  CartItemEntity copyWith({String? id, ProductEntity? product, int? quantity}) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}

/// Entidad del Carrito completo
class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final String? discountCode;
  final double discountPercent;

  const CartEntity({
    this.items = const [],
    this.discountCode,
    this.discountPercent = 0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get discount => subtotal * (discountPercent / 100);
  double get shippingCost => subtotal >= AppConstants.freeShippingMinAmount
      ? 0
      : AppConstants.shippingCost;
  double get total => subtotal - discount + shippingCost;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get hasDiscount => discountCode != null && discountPercent > 0;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    String? discountCode,
    double? discountPercent,
  }) {
    return CartEntity(
      items: items ?? this.items,
      discountCode: discountCode ?? this.discountCode,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  @override
  List<Object?> get props => [items, discountCode, discountPercent];
}

/// Entidad de Pedido
class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double discount;
  final double shippingCost;
  final double total;
  final String? discountCode;
  final OrderStatus status;
  final String shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.shippingCost,
    required this.total,
    this.discountCode,
    required this.status,
    required this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? discount,
    double? shippingCost,
    double? total,
    String? discountCode,
    OrderStatus? status,
    String? shippingAddress,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      discountCode: discountCode ?? this.discountCode,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get canCancel => status == OrderStatus.pagado;
  bool get canRequestReturn => status == OrderStatus.entregado;

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    userId,
    items,
    subtotal,
    discount,
    shippingCost,
    total,
    discountCode,
    status,
    shippingAddress,
    trackingNumber,
    notes,
    createdAt,
    updatedAt,
    paidAt,
    shippedAt,
    deliveredAt,
    cancelledAt,
  ];
}

/// Entidad de Item de Pedido
class OrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productImage,
    price,
    quantity,
  ];
}

/// Entidad de Código de Descuento
class DiscountCodeEntity extends Equatable {
  final String code;
  final double discountPercent;
  final bool isActive;
  final DateTime? expiresAt;
  final double? minPurchase;

  const DiscountCodeEntity({
    required this.code,
    required this.discountPercent,
    this.isActive = true,
    this.expiresAt,
    this.minPurchase,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
    code,
    discountPercent,
    isActive,
    expiresAt,
    minPurchase,
  ];
}

/// Filtros para búsqueda de productos
class ProductFilters extends Equatable {
  final AnimalType? animalType;
  final AnimalSize? animalSize;
  final ProductCategory? category;
  final AnimalAge? animalAge;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final bool? onlyWithDiscount;
  final bool? onlyInStock;

  const ProductFilters({
    this.animalType,
    this.animalSize,
    this.category,
    this.animalAge,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.onlyWithDiscount,
    this.onlyInStock,
  });

  bool get hasActiveFilters =>
      animalType != null ||
      animalSize != null ||
      category != null ||
      animalAge != null ||
      (searchQuery?.isNotEmpty ?? false) ||
      minPrice != null ||
      maxPrice != null ||
      onlyWithDiscount == true ||
      onlyInStock == true;

  ProductFilters copyWith({
    AnimalType? animalType,
    AnimalSize? animalSize,
    ProductCategory? category,
    AnimalAge? animalAge,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    bool? onlyWithDiscount,
    bool? onlyInStock,
    bool clearAnimalType = false,
    bool clearAnimalSize = false,
    bool clearCategory = false,
    bool clearAnimalAge = false,
  }) {
    return ProductFilters(
      animalType: clearAnimalType ? null : (animalType ?? this.animalType),
      animalSize: clearAnimalSize ? null : (animalSize ?? this.animalSize),
      category: clearCategory ? null : (category ?? this.category),
      animalAge: clearAnimalAge ? null : (animalAge ?? this.animalAge),
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyWithDiscount: onlyWithDiscount ?? this.onlyWithDiscount,
      onlyInStock: onlyInStock ?? this.onlyInStock,
    );
  }

  ProductFilters clear() => const ProductFilters();

  @override
  List<Object?> get props => [
    animalType,
    animalSize,
    category,
    animalAge,
    searchQuery,
    minPrice,
    maxPrice,
    onlyWithDiscount,
    onlyInStock,
  ];
}
