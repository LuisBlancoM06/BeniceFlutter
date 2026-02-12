import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/review_provider.dart';

/// Widget de estrellas de valoración
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showValue;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.color,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            return Icon(Icons.star, size: size, color: starColor);
          } else if (rating >= starValue - 0.5) {
            return Icon(Icons.star_half, size: size, color: starColor);
          } else {
            return Icon(Icons.star_border, size: size, color: starColor);
          }
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget interactivo para seleccionar calificación
class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              starValue <= rating ? Icons.star : Icons.star_border,
              size: size,
              color: Colors.amber,
            ),
          ),
        );
      }),
    );
  }
}

/// Barra de distribución de reseñas
class ReviewDistributionBar extends StatelessWidget {
  final ReviewStats stats;

  const ReviewDistributionBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        final count = stats.distribution[star] ?? 0;
        final percentage = stats.totalReviews > 0
            ? count / stats.totalReviews
            : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  '$star',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.amber,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Lista de reseñas de un producto
class ReviewsList extends ConsumerWidget {
  final String productId;

  const ReviewsList({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(reviewsProvider(productId));

    if (reviewsState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviewsState.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: AppTheme.textLight,
              ),
              SizedBox(height: 8),
              Text(
                'Sin reseñas aún',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              Text(
                '¡Sé el primero en opinar!',
                style: TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Puntuación media
                Column(
                  children: [
                    Text(
                      reviewsState.stats.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StarRating(
                      rating: reviewsState.stats.averageRating,
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reviewsState.stats.totalReviews} reseñas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Distribución
                Expanded(
                  child: ReviewDistributionBar(stats: reviewsState.stats),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Lista de reseñas
        ...reviewsState.reviews.map((review) => ReviewCard(review: review)),
      ],
    );
  }
}

/// Card individual de reseña
class ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (review.verifiedPurchase) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Compra verificada',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      StarRating(rating: review.rating.toDouble(), size: 14),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (review.helpfulCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.helpfulCount} personas encontraron esto útil',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} semanas';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Formulario para crear reseña
class CreateReviewForm extends ConsumerStatefulWidget {
  final String productId;

  const CreateReviewForm({super.key, required this.productId});

  @override
  ConsumerState<CreateReviewForm> createState() => _CreateReviewFormState();
}

class _CreateReviewFormState extends ConsumerState<CreateReviewForm> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escribe tu reseña',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Tu valoración: ',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                StarRatingInput(
                  rating: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia con el producto...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0 || _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar Reseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(reviewsActionsProvider(widget.productId))
          .addReview(
            rating: _rating,
            comment: _commentController.text.isEmpty
                ? null
                : _commentController.text,
          );
      if (mounted) {
        _commentController.clear();
        setState(() {
          _rating = 0;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reseña enviada! Gracias por tu opinión.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar reseña: $e')));
      }
    }
  }
}
