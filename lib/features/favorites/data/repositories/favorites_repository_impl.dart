import '../../../home/domain/entities/property_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PropertyEntity>> getFavorites() {
    return remoteDataSource.getFavorites();
  }

  @override
  Future<bool> toggleFavorite(String propertyId) {
    return remoteDataSource.toggleFavorite(propertyId);
  }
}
