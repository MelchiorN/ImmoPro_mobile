import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// Initie le paiement via Semoa CashPay API.
///
/// Retourne un [PaiementSemoaEntity] avec :
///   - paiementId : UUID local pour le suivi
///   - billId     : identifiant Semoa de la facture
///   - instructions : code USSD ou lien de redirection carte
///
/// La confirmation définitive arrive via webhook Semoa → backend.
class PayerLocationUseCase {
  final LocationRepository _repository;
  const PayerLocationUseCase(this._repository);

  Future<PaiementSemoaEntity> call({
    required String locationId,
    required String operateurPaiement,
    String? telephone,
  }) =>
      _repository.initierPaiement(
        locationId: locationId,
        operateurPaiement: operateurPaiement,
        telephone: telephone,
      );
}
