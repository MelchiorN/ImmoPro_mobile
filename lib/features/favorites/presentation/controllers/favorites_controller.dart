import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../../home/domain/entities/property_entity.dart';

class FavoritesController extends ChangeNotifier {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesController({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<PropertyEntity> _favorites = [];
  List<PropertyEntity> get favorites => _favorites;

  // Set pour un accès rapide O(1) afin de savoir si un ID est en favori
  final Set<String> _favoriteIds = {};

  bool isFavorite(String propertyId) => _favoriteIds.contains(propertyId);

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await getFavoritesUseCase();
      _favoriteIds.clear();
      for (var p in _favorites) {
        _favoriteIds.add(p.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    // Optimistic UI update
    final wasFavorite = _favoriteIds.contains(propertyId);
    if (wasFavorite) {
      _favoriteIds.remove(propertyId);
      _favorites.removeWhere((p) => p.id == propertyId);
    } else {
      _favoriteIds.add(propertyId);
      // On ne peut pas ajouter l'entité entière tout de suite (on n'a que l'ID),
      // l'entité complète sera récupérée au prochain loadFavorites() 
      // ou on l'ignore de la liste pour l'instant.
    }
    notifyListeners();

    try {
      final isNowFavorite = await toggleFavoriteUseCase(propertyId);
      
      // Si la réponse du serveur contredit notre UI optimiste, on annule
      if (isNowFavorite != !wasFavorite) {
        if (isNowFavorite) {
          _favoriteIds.add(propertyId);
        } else {
          _favoriteIds.remove(propertyId);
          _favorites.removeWhere((p) => p.id == propertyId);
        }
        notifyListeners();
      }
    } catch (e) {
      // Revert in case of error
      if (wasFavorite) {
        _favoriteIds.add(propertyId);
      } else {
        _favoriteIds.remove(propertyId);
      }
      _error = e.toString();
      notifyListeners();
    }
  }
}
