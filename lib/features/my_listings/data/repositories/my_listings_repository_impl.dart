import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/my_listings_repository.dart';
import '../datasources/my_listings_remote_datasource.dart';

class MyListingsRepositoryImpl implements MyListingsRepository {
  final MyListingsRemoteDataSource _remote;
  const MyListingsRepositoryImpl(this._remote);

  @override
  Future<List<ListingEntity>> getMyListings() => _remote.getMyListings();

  @override
  Future<ListingEntity> getListingDetail(String id) =>
      _remote.getListingDetail(id);

  @override
  Future<ListingEntity> uploadMedia(String bienId, List<String> filePaths) =>
      _remote.uploadMedia(bienId, filePaths);
}
