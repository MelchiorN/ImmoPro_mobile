import '../entities/demande_location_entity.dart';
import '../repositories/location_repository.dart';

/// Cas d'utilisation : soumettre une demande de location au backend.
class SoumettreDemandeLocationUseCase {
  final LocationRepository _repository;

  const SoumettreDemandeLocationUseCase(this._repository);

  Future<DemandeLocationEntity> call(DemandeLocationEntity demande) =>
      _repository.soumettreDemande(demande);
}
