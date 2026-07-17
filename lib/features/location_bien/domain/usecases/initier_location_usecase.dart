import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class InitierLocationUseCase {
  final LocationRepository _repository;
  const InitierLocationUseCase(this._repository);

  Future<InitierLocationResult> call({
    required String bienId,
    required int dureeMois,
  }) =>
      _repository.initierLocation(bienId: bienId, dureeMois: dureeMois);
}
