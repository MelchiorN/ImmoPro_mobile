import '../entities/listing_entity.dart';
import '../repositories/my_listings_repository.dart';

class GetMyListingsUseCase {
  final MyListingsRepository _repository;
  const GetMyListingsUseCase(this._repository);

  Future<List<ListingEntity>> call() => _repository.getMyListings();
}
