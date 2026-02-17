import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

// ==================== FAVORITES STATE ====================

class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;

  const FavoritesState({this.favoriteIds = const {}, this.isLoading = false});

  FavoritesState copyWith({Set<String>? favoriteIds, bool? isLoading}) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ==================== FAVORITES NOTIFIER ====================

class FavoritesNotifier extends Notifier<FavoritesState> {
  static const _storageKey = 'benice_favorites';

  @override
  FavoritesState build() {
    Future.microtask(() => _loadFavorites());
    return const FavoritesState();
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  void _loadFavorites() {
    final stored = _prefs.getString(_storageKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      state = FavoritesState(
        favoriteIds: decoded.map((e) => e.toString()).toSet(),
      );
    }
  }

  void _saveFavorites() {
    _prefs.setString(_storageKey, jsonEncode(state.favoriteIds.toList()));
  }

  void toggleFavorite(String productId) {
    final updated = Set<String>.from(state.favoriteIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = FavoritesState(favoriteIds: updated);
    _saveFavorites();
  }

  bool isFavorite(String productId) {
    return state.favoriteIds.contains(productId);
  }

  void clearAll() {
    state = const FavoritesState();
    _prefs.remove(_storageKey);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesProvider).favoriteIds.contains(productId);
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).favoriteIds.length;
});

/// Provider que carga los productos favoritos por sus IDs
final favoriteProductsProvider =
    FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
      final favoriteIds = ref.watch(favoritesProvider).favoriteIds;
      if (favoriteIds.isEmpty) return [];

      final productRepo = ref.read(productRepositoryProvider);
      final results = <ProductEntity>[];
      for (final id in favoriteIds) {
        final result = await productRepo.getProductById(id);
        result.fold((_) {}, (product) => results.add(product));
      }
      return results;
    });
