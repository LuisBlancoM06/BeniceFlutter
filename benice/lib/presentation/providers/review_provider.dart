import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

// ==================== REVIEW STATE ====================

class ReviewsState {
  final List<ReviewEntity> reviews;
  final ReviewStats stats;
  final bool isLoading;
  final String? error;

  const ReviewsState({
    this.reviews = const [],
    this.stats = const ReviewStats(),
    this.isLoading = false,
    this.error,
  });

  ReviewsState copyWith({
    List<ReviewEntity>? reviews,
    ReviewStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== HELPERS ====================

ReviewStats _calculateStats(List<ReviewEntity> reviews) {
  final totalReviews = reviews.length;
  double avgRating = 0;
  final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  if (totalReviews > 0) {
    for (final review in reviews) {
      avgRating += review.rating;
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    avgRating /= totalReviews;
  }
  return ReviewStats(
    averageRating: avgRating,
    totalReviews: totalReviews,
    distribution: distribution,
  );
}

// ==================== GLOBAL REVIEWS STORE ====================

/// Store centralizado de reviews (gestiona reviews de todos los productos)
class ReviewsStore extends Notifier<Map<String, List<ReviewEntity>>> {
  @override
  Map<String, List<ReviewEntity>> build() {
    return {};
  }

  List<ReviewEntity> getReviews(String productId) {
    if (!state.containsKey(productId)) {
      // Trigger async load from Supabase
      _loadFromRepo(productId);
    }
    return state[productId] ?? [];
  }

  Future<void> _loadFromRepo(String productId) async {
    final reviewRepo = ref.read(reviewRepositoryProvider);
    final result = await reviewRepo.getProductReviews(productId);
    result.fold((_) => null, (reviews) {
      state = {...state, productId: reviews};
    });
  }

  void addReview(String productId, ReviewEntity review) {
    final currentReviews = getReviews(productId);
    state = {
      ...state,
      productId: [review, ...currentReviews],
    };
  }

  void deleteReview(String productId, String reviewId) {
    final currentReviews = getReviews(productId);
    state = {
      ...state,
      productId: currentReviews.where((r) => r.id != reviewId).toList(),
    };
  }
}

final _reviewsStoreProvider =
    NotifierProvider<ReviewsStore, Map<String, List<ReviewEntity>>>(
      ReviewsStore.new,
    );

// ==================== PER-PRODUCT PROVIDERS ====================

/// Provider de estado de reviews para un producto específico
final reviewsProvider = Provider.family<ReviewsState, String>((ref, productId) {
  // Watch the store to get reactive updates
  final store = ref.watch(_reviewsStoreProvider);
  final reviews = store[productId] ?? [];

  // Si no hay reviews cargadas aún, inicializar
  if (!store.containsKey(productId)) {
    // Trigger load
    Future.microtask(() {
      ref.read(_reviewsStoreProvider.notifier).getReviews(productId);
    });
    return const ReviewsState(isLoading: true);
  }

  return ReviewsState(
    reviews: reviews,
    stats: _calculateStats(reviews),
    isLoading: false,
  );
});

/// Acciones de reviews por producto
class ReviewsActions {
  final Ref ref;
  final String productId;

  ReviewsActions(this.ref, this.productId);

  Future<void> addReview({required int rating, String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newReview = ReviewEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: productId,
      userId: 'current-user',
      userName: 'Tú',
      rating: rating,
      comment: comment,
      verifiedPurchase: true,
      createdAt: DateTime.now(),
    );

    ref.read(_reviewsStoreProvider.notifier).addReview(productId, newReview);
  }

  void deleteReview(String reviewId) {
    ref.read(_reviewsStoreProvider.notifier).deleteReview(productId, reviewId);
  }
}

/// Provider de acciones por productId
final reviewsActionsProvider = Provider.family<ReviewsActions, String>((
  ref,
  productId,
) {
  return ReviewsActions(ref, productId);
});
