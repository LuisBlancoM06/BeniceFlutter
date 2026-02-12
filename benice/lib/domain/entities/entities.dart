import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Entidad de Usuario
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? avatarUrl;
  final String role; // 'user' o 'admin'
  final bool isSubscribedNewsletter;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.avatarUrl,
    this.role = 'user',
    this.isSubscribedNewsletter = false,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? avatarUrl,
    String? role,
    bool? isSubscribedNewsletter,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
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
    fullName,
    phone,
    address,
    city,
    postalCode,
    avatarUrl,
    role,
    isSubscribedNewsletter,
    createdAt,
  ];
}

/// Entidad de Producto
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String description;
  final double price;
  final double? discountPrice; // DB: sale_price
  final bool onSale; // DB: on_sale
  final String? imageUrl; // DB: image_url (single main)
  final List<String> images; // DB: images (text[])
  final AnimalType animalType;
  final AnimalSize animalSize; // DB: size
  final ProductCategory category;
  final AnimalAge animalAge; // DB: age_range
  final int stock;
  final String? brand;
  final double rating; // Computed from reviews, not in products table
  final int reviewsCount; // Computed from reviews, not in products table
  final bool isFeatured; // Not in DB, used by mock; from DB use on_sale
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    this.onSale = false,
    this.imageUrl,
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

  bool get hasDiscount =>
      onSale && discountPrice != null && discountPrice! < price;
  double get finalPrice =>
      (onSale && discountPrice != null) ? discountPrice! : price;
  int get discountPercentage =>
      hasDiscount ? ((1 - discountPrice! / price) * 100).round() : 0;
  bool get inStock => stock > 0;
  String get mainImage => imageUrl ?? (images.isNotEmpty ? images.first : '');

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    price,
    discountPrice,
    onSale,
    imageUrl,
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
  final double discount; // DB: discount_amount
  final double shippingCost;
  final double total;
  final String? discountCode; // DB: promo_code
  final OrderStatus status;
  final String shippingAddress; // DB: shipping_address
  final String? shippingName; // DB: shipping_name
  final String? shippingPhone; // DB: shipping_phone
  final String? stripeSessionId; // DB: stripe_session_id
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    this.shippingName,
    this.shippingPhone,
    this.stripeSessionId,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
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
    String? shippingName,
    String? shippingPhone,
    String? stripeSessionId,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      shippingName: shippingName ?? this.shippingName,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      stripeSessionId: stripeSessionId ?? this.stripeSessionId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    shippingName,
    shippingPhone,
    stripeSessionId,
    trackingNumber,
    notes,
    createdAt,
    updatedAt,
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

/// Entidad de Código de Descuento (DB: promo_codes)
class DiscountCodeEntity extends Equatable {
  final String? id;
  final String code;
  final double discountPercent; // DB: discount_percentage (int)
  final bool isActive; // DB: active
  final int? maxUses; // DB: max_uses
  final int currentUses; // DB: current_uses
  final DateTime? expiresAt; // DB: expires_at
  final DateTime? createdAt;

  const DiscountCodeEntity({
    this.id,
    required this.code,
    required this.discountPercent,
    this.isActive = true,
    this.maxUses,
    this.currentUses = 0,
    this.expiresAt,
    this.createdAt,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxUses != null && currentUses >= maxUses!) return false;
    return true;
  }

  @override
  List<Object?> get props => [
    id,
    code,
    discountPercent,
    isActive,
    maxUses,
    currentUses,
    expiresAt,
    createdAt,
  ];
}

/// Entidad de Reseña de Producto
class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final bool verifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    this.verifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    userId,
    userName,
    rating,
    comment,
    verifiedPurchase,
    helpfulCount,
    createdAt,
  ];
}

/// Estadísticas de reseñas de un producto
class ReviewStats extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  const ReviewStats({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.distribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  });

  @override
  List<Object?> get props => [averageRating, totalReviews, distribution];
}

/// Entidad de Factura (DB: invoices)
class InvoiceEntity extends Equatable {
  final String id;
  final String orderId; // DB: order_id
  final String userId; // DB: user_id
  final String invoiceNumber; // DB: invoice_number
  final String invoiceType; // DB: invoice_type ('factura' | 'abono')
  final double subtotal;
  final double taxAmount; // DB: tax_amount
  final double total;
  final String? pdfUrl; // DB: pdf_url
  final DateTime createdAt; // DB: created_at

  const InvoiceEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.invoiceNumber,
    required this.invoiceType,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.pdfUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    userId,
    invoiceNumber,
    invoiceType,
    subtotal,
    taxAmount,
    total,
    pdfUrl,
    createdAt,
  ];
}

/// Entidad de Devolución (DB: returns)
class ReturnEntity extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final String reason;
  final String status; // 'solicitada', 'aprobada', 'rechazada', 'completada'
  final double? refundAmount; // DB: refund_amount
  final String? adminNotes; // DB: admin_notes
  final DateTime createdAt;
  final DateTime? updatedAt; // DB: updated_at

  const ReturnEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    this.status = 'solicitada',
    this.refundAmount,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    userId,
    reason,
    status,
    refundAmount,
    adminNotes,
    createdAt,
    updatedAt,
  ];
}

/// Entidad de Suscriptor Newsletter (DB: newsletters)
class NewsletterSubscriber extends Equatable {
  final String id;
  final String email;
  final String promoCode; // DB: promo_code (required)
  final String source; // DB: source ('footer' default)
  final DateTime createdAt; // DB: created_at

  const NewsletterSubscriber({
    required this.id,
    required this.email,
    required this.promoCode,
    this.source = 'footer',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, promoCode, source, createdAt];
}

/// Entidad de Configuración del Sitio
class SiteSettingsEntity extends Equatable {
  final bool ofertasFlashActive;
  final String storeName;
  final String storeEmail;
  final String storePhone;

  const SiteSettingsEntity({
    this.ofertasFlashActive = false,
    this.storeName = 'BeniceAstro',
    this.storeEmail = 'info@benice.com',
    this.storePhone = '+34 600 000 000',
  });

  @override
  List<Object?> get props => [
    ofertasFlashActive,
    storeName,
    storeEmail,
    storePhone,
  ];
}

/// Entidad de Producto Favorito
class FavoriteEntity extends Equatable {
  final String productId;
  final DateTime addedAt;

  const FavoriteEntity({required this.productId, required this.addedAt});

  @override
  List<Object?> get props => [productId, addedAt];
}

/// Datos del Dashboard Admin
class DashboardStats extends Equatable {
  final double totalSales;
  final int totalOrders;
  final int totalUsers;
  final int totalProducts;
  final int lowStockProducts;
  final List<OrderEntity> recentOrders;
  final Map<String, double> salesByMonth;
  final Map<String, int> ordersByStatus;

  const DashboardStats({
    this.totalSales = 0,
    this.totalOrders = 0,
    this.totalUsers = 0,
    this.totalProducts = 0,
    this.lowStockProducts = 0,
    this.recentOrders = const [],
    this.salesByMonth = const {},
    this.ordersByStatus = const {},
  });

  @override
  List<Object?> get props => [
    totalSales,
    totalOrders,
    totalUsers,
    totalProducts,
    lowStockProducts,
    recentOrders,
    salesByMonth,
    ordersByStatus,
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
