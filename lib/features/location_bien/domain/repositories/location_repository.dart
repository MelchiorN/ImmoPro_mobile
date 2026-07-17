import '../entities/location_entity.dart';

abstract class LocationRepository {
  /// Étape 1 — Initier la location.
  /// Vérifie côté backend que le client n'est pas le proprio, verrouille le
  /// bien, crée la location et génère le contrat.
  Future<InitierLocationResult> initierLocation({
    required String bienId,
    required int dureeMois,
  });

  /// Étape 2 — Le client accepte/signe le contrat.
  Future<ContratEntity> accepterContrat(String locationId);

  /// Étape 3 — Initier le paiement.
  /// Retourne la location mise à jour (statut → en_attente_paiement).
  Future<LocationEntity> initierPaiement({
    required String locationId,
    required String operateurPaiement,
  });

  /// Étape 4 — Confirmer le paiement (simulé).
  /// En production ce serait un webhook ; ici on expose un endpoint pour la démo.
  Future<RecuEntity> confirmerPaiement(String locationId);
}
