import '../../domain/repositories/favorites_repository.dart';
import '../../../home/domain/entities/property_entity.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<PropertyEntity>> call() {
    return repository.getFavorites();
  }
}
