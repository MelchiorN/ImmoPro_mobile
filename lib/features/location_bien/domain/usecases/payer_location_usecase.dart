import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class PayerLocationUseCase {
  final LocationRepository _repository;
  const PayerLocationUseCase(this._repository);

  Future<RecuEntity> call({
    required String locationId,
    required String operateurPaiement,
  }) async {
    await _repository.initierPaiement(
      locationId: locationId,
      operateurPaiement: operateurPaiement,
    );
    return _repository.confirmerPaiement(locationId);
  }
}
