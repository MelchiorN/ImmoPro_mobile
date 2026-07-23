import '../entities/location_entity.dart';

abstract class LocationRepository {
  /// Étape 1 — Initier la location.
  Future<InitierLocationResult> initierLocation({
    required String bienId,
    required int dureeMois,
    required DateTime dateDebut,
  });

  /// Étape 2 — Le client accepte/signe le contrat.
  Future<ContratEntity> accepterContrat(String locationId);

  /// Étape 3 — Initier le paiement via Semoa CashPay.
  /// Retourne les instructions de paiement (T-Money / Flooz / Carte).
  Future<PaiementSemoaEntity> initierPaiement({
    required String locationId,
    required String operateurPaiement,
    String? telephone,
  });

  /// Refuser le contrat — libère la réservation du bien.
  Future<void> refuserContrat(String locationId);
}
