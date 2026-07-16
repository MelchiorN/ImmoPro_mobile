import '../entities/demande_location_entity.dart';

abstract class LocationRepository {
  /// Soumet une demande de location au backend.
  /// Retourne l'entité créée (avec ID assigné par le serveur).
  Future<DemandeLocationEntity> soumettreDemande(
      DemandeLocationEntity demande);
}
