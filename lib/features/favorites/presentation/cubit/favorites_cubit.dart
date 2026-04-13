import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/model/product.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial()) {
    _loadFavorites();
  }

  // In-memory storage to avoid SharedPreferences platform exception
  static final List<Product> _cachedFavorites = [];

  void _loadFavorites() {
    emit(FavoritesLoaded(List.from(_cachedFavorites)));
  }

  void toggleFavorite(Product product) {
    final currentFavorites = _cachedFavorites;
    final index = currentFavorites.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      // Remove from favorites
      currentFavorites.removeAt(index);
    } else {
      // Add to favorites
      currentFavorites.add(product);
    }

    emit(FavoritesLoaded(List.from(currentFavorites)));
  }

  bool isFavorite(String productId) {
    return _cachedFavorites.any((p) => p.id == productId);
  }

  int get favoritesCount => _cachedFavorites.length;
}
