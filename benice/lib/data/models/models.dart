import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

/// Modelo de Usuario para la capa de datos
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.address,
    super.avatarUrl,
    super.isSubscribedNewsletter,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isSubscribedNewsletter:
          json['is_subscribed_newsletter'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
      'is_subscribed_newsletter': isSubscribedNewsletter,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      avatarUrl: entity.avatarUrl,
      isSubscribedNewsletter: entity.isSubscribedNewsletter,
      createdAt: entity.createdAt,
    );
  }
}

/// Modelo de Producto para la capa de datos
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.discountPrice,
    required super.images,
    required super.animalType,
    required super.animalSize,
    required super.category,
    required super.animalAge,
    required super.stock,
    super.brand,
    super.rating,
    super.reviewsCount,
    super.isFeatured,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      images: List<String>.from(json['images'] as List? ?? []),
      animalType: AnimalType.values.firstWhere(
        (e) => e.name == json['animal_type'],
        orElse: () => AnimalType.perro,
      ),
      animalSize: AnimalSize.values.firstWhere(
        (e) => e.name == json['animal_size'],
        orElse: () => AnimalSize.mediano,
      ),
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.alimentacion,
      ),
      animalAge: AnimalAge.values.firstWhere(
        (e) => e.name == json['animal_age'],
        orElse: () => AnimalAge.adulto,
      ),
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'images': images,
      'animal_type': animalType.name,
      'animal_size': animalSize.name,
      'category': category.name,
      'animal_age': animalAge.name,
      'stock': stock,
      'brand': brand,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Modelo de Item del Carrito
class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      product: entity.product,
      quantity: entity.quantity,
    );
  }
}

/// Modelo del Carrito
class CartModel extends CartEntity {
  const CartModel({super.items, super.discountCode, super.discountPercent});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items:
          (json['items'] as List?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      discountCode: json['discount_code'] as String?,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => CartItemModel.fromEntity(e).toJson()).toList(),
      'discount_code': discountCode,
      'discount_percent': discountPercent,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory CartModel.fromJsonString(String jsonString) {
    return CartModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  factory CartModel.fromEntity(CartEntity entity) {
    return CartModel(
      items: entity.items,
      discountCode: entity.discountCode,
      discountPercent: entity.discountPercent,
    );
  }
}

/// Modelo de Pedido
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.userId,
    required super.items,
    required super.subtotal,
    super.discount,
    required super.shippingCost,
    required super.total,
    super.discountCode,
    required super.status,
    required super.shippingAddress,
    super.trackingNumber,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.paidAt,
    super.shippedAt,
    super.deliveredAt,
    super.cancelledAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber:
          json['order_number'] as String? ??
          'ORD-${json['id'].toString().substring(0, 8).toUpperCase()}',
      userId: json['user_id'] as String,
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discountCode: json['discount_code'] as String?,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pendiente,
      ),
      shippingAddress: json['shipping_address'] as String,
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'items': items.map((e) => (e as OrderItemModel).toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shipping_cost': shippingCost,
      'total': total,
      'discount_code': discountCode,
      'status': status.name,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }
}

/// Modelo de Item de Pedido
class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromCartItem(CartItemEntity cartItem) {
    return OrderItemModel(
      id: cartItem.id,
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      productImage: cartItem.product.mainImage,
      price: cartItem.product.finalPrice,
      quantity: cartItem.quantity,
    );
  }
}

/// Modelo de Código de Descuento
class DiscountCodeModel extends DiscountCodeEntity {
  const DiscountCodeModel({
    required super.code,
    required super.discountPercent,
    super.isActive,
    super.expiresAt,
    super.minPurchase,
  });

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      code: json['code'] as String,
      discountPercent: (json['discount_percent'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      minPurchase: json['min_purchase'] != null
          ? (json['min_purchase'] as num).toDouble()
          : null,
    );
  }
}
