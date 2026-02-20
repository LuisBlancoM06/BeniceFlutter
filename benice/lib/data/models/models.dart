import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

/// Modelo de Usuario para la capa de datos
/// DB table: users (id, email, full_name, phone, address, role, created_at)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.fullName,
    super.phone,
    super.address,
    super.city,
    super.postalCode,
    super.avatarUrl,
    super.role,
    super.isSubscribedNewsletter,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['full_name'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      isSubscribedNewsletter:
          json['is_subscribed_newsletter'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName ?? name,
      'phone': phone,
      'address': address,
      'role': role,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      fullName: entity.fullName,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      postalCode: entity.postalCode,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isSubscribedNewsletter: entity.isSubscribedNewsletter,
      createdAt: entity.createdAt,
    );
  }
}

/// Modelo de Producto para la capa de datos
/// DB table: products (id, name, slug, description, price, sale_price, on_sale,
///   stock, image_url, images, brand, animal_type, size, category, age_range, created_at)
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.slug,
    required super.description,
    required super.price,
    super.discountPrice,
    super.onSale,
    super.imageUrl,
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
    // DB column 'images' is text[] (PostgreSQL array)
    List<String> imagesList;
    if (json['images'] is List) {
      imagesList = List<String>.from(json['images'] as List);
    } else if (json['images'] is String) {
      // Handle PostgreSQL text[] serialized as string: {url1,url2}
      final raw = json['images'] as String;
      if (raw.startsWith('{') && raw.endsWith('}')) {
        imagesList = raw
            .substring(1, raw.length - 1)
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        imagesList = [];
      }
    } else {
      imagesList = [];
    }

    // DB: animal_type enum values: 'perro', 'gato', 'otros'
    final animalTypeStr = json['animal_type'] as String? ?? 'perro';
    final animalType = AnimalType.values.firstWhere(
      (e) => e.name == animalTypeStr,
      orElse: () => AnimalType.perro,
    );

    // DB: size enum: 'mini', 'mediano', 'grande'
    final sizeStr =
        json['size'] as String? ?? json['animal_size'] as String? ?? 'mediano';
    final animalSize = AnimalSize.values.firstWhere(
      (e) => e.name == sizeStr,
      orElse: () => AnimalSize.mediano,
    );

    // DB: category enum: 'alimentacion', 'higiene', 'salud', 'accesorios', 'juguetes'
    final categoryStr = json['category'] as String? ?? 'alimentacion';
    final category = ProductCategory.values.firstWhere(
      (e) => e.name == categoryStr,
      orElse: () => ProductCategory.alimentacion,
    );

    // DB: age_range enum: 'cachorro', 'adulto', 'senior'
    final ageStr =
        json['age_range'] as String? ??
        json['animal_age'] as String? ??
        'adulto';
    final animalAge = AnimalAge.values.firstWhere(
      (e) => e.name == ageStr,
      orElse: () => AnimalAge.adulto,
    );

    final onSale = json['on_sale'] as bool? ?? false;

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['sale_price'] != null
          ? (json['sale_price'] as num).toDouble()
          : null,
      onSale: onSale,
      imageUrl: json['image_url'] as String?,
      images: imagesList,
      animalType: animalType,
      animalSize: animalSize,
      category: category,
      animalAge: animalAge,
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      isFeatured: onSale, // Use on_sale as featured since DB has no is_featured
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'sale_price': discountPrice,
      'on_sale': onSale,
      'image_url': imageUrl ?? mainImage,
      'images': images,
      'brand': brand ?? 'Benice',
      'animal_type': animalType.name,
      'size': animalSize.name,
      'category': category.name,
      'age_range': animalAge.name,
      'stock': stock,
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
      'product': product is ProductModel ? (product as ProductModel).toJson() : {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'sale_price': product.salePrice,
        'on_sale': product.onSale,
        'image_url': product.imageUrl,
        'stock': product.stock,
      },
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
/// DB table: orders (id, user_id, total, status, promo_code, discount_amount,
///   shipping_address, shipping_name, shipping_phone, stripe_session_id,
///   tracking_number, created_at, updated_at)
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
    super.shippingName,
    super.shippingPhone,
    super.stripeSessionId,
    super.trackingNumber,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Items may come from join or separate
    List<OrderItemEntity> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['order_items'] is List) {
      items = (json['order_items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final total = (json['total'] as num).toDouble();
    final discountAmount = (json['discount_amount'] as num?)?.toDouble() ?? 0;
    final shippingCost = (json['shipping_cost'] as num?)?.toDouble() ?? 0;

    // Compute subtotal from items if available, else from total + discount - shipping
    double subtotal;
    if (items.isNotEmpty) {
      subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    } else {
      subtotal = total + discountAmount - shippingCost;
    }

    return OrderModel(
      id: json['id'] as String,
      orderNumber:
          json['order_number'] as String? ??
          'ORD-${json['id'].toString().substring(0, 8).toUpperCase()}',
      userId: json['user_id'] as String,
      items: items,
      subtotal: subtotal,
      discount: discountAmount,
      shippingCost: shippingCost,
      total: total,
      discountCode: json['promo_code'] as String?,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pendiente,
      ),
      shippingAddress: json['shipping_address'] as String? ?? '',
      shippingName: json['shipping_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      stripeSessionId: json['stripe_session_id'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'status': status.name,
      'promo_code': discountCode,
      'discount_amount': discount,
      'shipping_address': shippingAddress,
      'shipping_name': shippingName,
      'shipping_phone': shippingPhone,
      'stripe_session_id': stripeSessionId,
      'tracking_number': trackingNumber,
    };
  }
}

/// Modelo de Item de Pedido
/// DB table: order_items (id, order_id, product_id, quantity, price)
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
    // Handle joined product data if available
    String productName = json['product_name'] as String? ?? '';
    String productImage = json['product_image'] as String? ?? '';

    // If we have a nested product object from join
    if (json['products'] is Map) {
      final product = json['products'] as Map<String, dynamic>;
      productName = product['name'] as String? ?? productName;
      productImage = product['image_url'] as String? ?? productImage;
    }

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: productName,
      productImage: productImage,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'price': price, 'quantity': quantity};
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
/// DB table: promo_codes (id, code, discount_percentage, active, max_uses,
///   current_uses, expires_at, created_at)
class DiscountCodeModel extends DiscountCodeEntity {
  const DiscountCodeModel({
    super.id,
    required super.code,
    required super.discountPercent,
    super.isActive,
    super.maxUses,
    super.currentUses,
    super.expiresAt,
    super.createdAt,
  });

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      id: json['id'] as String?,
      code: json['code'] as String,
      discountPercent: (json['discount_percentage'] as num).toDouble(),
      isActive: json['active'] as bool? ?? true,
      maxUses: json['max_uses'] as int?,
      currentUses: json['current_uses'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount_percentage': discountPercent.round(),
      'active': isActive,
      'max_uses': maxUses,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

/// Modelo de Reseña
/// DB table: product_reviews
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    required super.rating,
    super.comment,
    super.verifiedPurchase,
    super.helpfulCount,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Anónimo',
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      verifiedPurchase: json['verified_purchase'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'verified_purchase': verifiedPurchase,
    };
  }
}

/// Modelo de Factura
/// DB table: invoices (id, order_id, user_id, invoice_number, invoice_type,
///   subtotal, tax_amount, total, pdf_url, created_at)
class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.invoiceNumber,
    required super.invoiceType,
    required super.subtotal,
    required super.taxAmount,
    required super.total,
    super.pdfUrl,
    required super.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      invoiceType: json['invoice_type'] as String? ?? 'factura',
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      pdfUrl: json['pdf_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Modelo de Devolución
/// DB table: returns (id, order_id, user_id, reason, status, refund_amount,
///   admin_notes, created_at, updated_at)
class ReturnModel extends ReturnEntity {
  const ReturnModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.reason,
    super.status,
    super.refundAmount,
    super.adminNotes,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'solicitada',
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] as num).toDouble()
          : null,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'reason': reason,
      'status': status,
      'refund_amount': refundAmount,
      'admin_notes': adminNotes,
    };
  }
}

/// Modelo de Suscriptor Newsletter
/// DB table: newsletters (id, email, promo_code, source, created_at)
class NewsletterSubscriberModel extends NewsletterSubscriber {
  const NewsletterSubscriberModel({
    required super.id,
    required super.email,
    required super.promoCode,
    super.source,
    required super.createdAt,
  });

  factory NewsletterSubscriberModel.fromJson(Map<String, dynamic> json) {
    return NewsletterSubscriberModel(
      id: json['id'] as String,
      email: json['email'] as String,
      promoCode: json['promo_code'] as String? ?? '',
      source: json['source'] as String? ?? 'footer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
