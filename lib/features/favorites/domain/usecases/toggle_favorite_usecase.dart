import '../../domain/repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<bool> call(String propertyId) {
    return repository.toggleFavorite(propertyId);
  }
}
