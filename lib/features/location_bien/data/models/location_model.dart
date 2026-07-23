import '../../domain/entities/location_entity.dart';

// ─── LocationModel ────────────────────────────────────────────────────────────

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.bienId,
    required super.locataireId,
    required super.proprietaireId,
    required super.dateDebut,
    required super.dateFin,
    required super.dureeMois,
    required super.prixProprietaire,
    required super.montantCommission,
    required super.montantTotal,
    required super.statut,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id:                json['id']?.toString() ?? '',
      bienId:            json['bien_id']?.toString() ?? '',
      locataireId:       json['locataire_id']?.toString() ?? '',
      proprietaireId:    json['proprietaire_id']?.toString() ?? '',
      dateDebut:         DateTime.parse(json['date_debut'] as String),
      dateFin:           DateTime.parse(json['date_fin'] as String),
      dureeMois:         (json['duree_mois'] as num?)?.toInt() ?? 0,
      prixProprietaire:  (json['prix_proprietaire'] as num?)?.toDouble() ?? 0,
      montantCommission: (json['montant_commission'] as num?)?.toDouble() ?? 0,
      montantTotal:      (json['montant_total'] as num?)?.toDouble() ?? 0,
      statut: locationStatutFromString(json['statut'] as String? ?? ''),
    );
  }
}

// ─── ContratModel ─────────────────────────────────────────────────────────────

class ContratModel extends ContratEntity {
  const ContratModel({
    required super.id,
    super.idContrat,
    required super.locationId,
    required super.contenuHtml,
    super.urlPdf,
    required super.dateGeneration,
    super.dateCreation,
    super.dateAcceptation,
    required super.statut,
    required super.statutSignature,
  });

  factory ContratModel.fromJson(Map<String, dynamic> json) {
    final rawStatut = json['statutSignature'] as String? ?? json['statut_signature'] as String? ?? json['statut'] as String? ?? 'en_attente';
    final dateGenStr = json['dateCreation'] as String? ?? json['date_creation'] as String? ?? json['date_generation'] as String? ?? DateTime.now().toIso8601String();
    final dateGen = DateTime.tryParse(dateGenStr) ?? DateTime.now();

    return ContratModel(
      id:              json['idContrat']?.toString() ?? json['id']?.toString() ?? '',
      idContrat:       json['idContrat']?.toString() ?? json['id']?.toString(),
      locationId:      json['location_id']?.toString() ?? json['locationId']?.toString() ?? '',
      contenuHtml:     json['contenu_html'] as String? ?? json['contenuHtml'] as String? ?? '',
      urlPdf:          json['urlPdf'] as String? ?? json['fichier_pdf'] as String?,
      dateGeneration:  dateGen,
      dateCreation:    dateGen,
      dateAcceptation: json['date_acceptation'] != null
          ? DateTime.tryParse(json['date_acceptation'] as String)
          : null,
      statut:          contratStatutFromString(rawStatut),
      statutSignature: rawStatut,
    );
  }
}

// ─── RecuModel ────────────────────────────────────────────────────────────────

class RecuModel extends RecuEntity {
  const RecuModel({
    required super.id,
    required super.paiementId,
    required super.numeroRecu,
    required super.dateEmission,
    required super.montant,
    required super.operateurPaiement,
  });

  factory RecuModel.fromJson(Map<String, dynamic> json) {
    return RecuModel(
      id:                json['id']?.toString() ?? '',
      paiementId:        json['paiement_id']?.toString() ?? '',
      numeroRecu:        json['numero_recu'] as String? ?? '',
      dateEmission:      DateTime.parse(
          json['date_emission'] as String? ?? DateTime.now().toIso8601String()),
      montant:           (json['montant'] as num?)?.toDouble() ?? 0,
      operateurPaiement: json['operateur_paiement'] as String? ?? '',
    );
  }
}

// ─── InitierLocationResultModel ───────────────────────────────────────────────

class InitierLocationResultModel extends InitierLocationResult {
  const InitierLocationResultModel({
    required super.location,
    required super.contrat,
  });

  factory InitierLocationResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final locationMap = (data['location'] as Map<String, dynamic>?) ?? data;
    final contratMap = (data['contrat'] as Map<String, dynamic>?) ?? {};

    // Si location_id est au niveau racine de data
    final locationId = locationMap['id']?.toString() ?? locationMap['location_id']?.toString() ?? '';

    return InitierLocationResultModel(
      location: LocationModel(
        id: locationId,
        bienId: locationMap['bien_id']?.toString() ?? '',
        locataireId: locationMap['locataire_id']?.toString() ?? '',
        proprietaireId: locationMap['proprietaire_id']?.toString() ?? '',
        dateDebut: DateTime.tryParse(locationMap['date_debut']?.toString() ?? '') ?? DateTime.now(),
        dateFin: DateTime.tryParse(locationMap['date_fin']?.toString() ?? '') ?? DateTime.now(),
        dureeMois: (locationMap['duree_mois'] as num?)?.toInt() ?? 1,
        prixProprietaire: (locationMap['prix_proprietaire'] as num?)?.toDouble() ?? 0,
        montantCommission: (locationMap['montant_commission'] as num?)?.toDouble() ?? 0,
        montantTotal: (locationMap['montant_total'] as num?)?.toDouble() ?? 0,
        statut: locationStatutFromString(locationMap['statut']?.toString() ?? 'en_attente_contrat'),
      ),
      contrat: ContratModel.fromJson(contratMap),
    );
  }
}

// ─── PaiementSemoaModel ───────────────────────────────────────────────────────

/// Parse la réponse POST /locations/{id}/payer (intégration Semoa CashPay).
class PaiementSemoaModel extends PaiementSemoaEntity {
  const PaiementSemoaModel({
    required super.paiementId,
    super.billId,
    required super.montant,
    required super.operateur,
    required super.statut,
    required super.instructions,
    super.paymentUrl,
  });

  factory PaiementSemoaModel.fromJson(Map<String, dynamic> json) {
    return PaiementSemoaModel(
      paiementId:   json['paiement_id']?.toString() ?? '',
      billId:       json['bill_id']?.toString(),
      montant:      (json['montant'] as num?)?.toDouble() ?? 0,
      operateur:    json['operateur']?.toString() ?? '',
      statut:       json['statut']?.toString() ?? 'initie',
      instructions: json['instructions']?.toString() ?? '',
      paymentUrl:   json['payment_url']?.toString(),
    );
  }
}

