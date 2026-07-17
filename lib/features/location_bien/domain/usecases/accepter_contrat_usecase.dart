import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class AccepterContratUseCase {
  final LocationRepository _repository;
  const AccepterContratUseCase(this._repository);

  Future<ContratEntity> call(String locationId) =>
      _repository.accepterContrat(locationId);
}
