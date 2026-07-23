import '../../../home/domain/entities/property_entity.dart';

abstract class FavoritesRepository {
  Future<List<PropertyEntity>> getFavorites();
  Future<bool> toggleFavorite(String propertyId);
}
