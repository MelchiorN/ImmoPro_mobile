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
    required super.locationId,
    required super.contenuHtml,
    required super.dateGeneration,
    super.dateAcceptation,
    required super.statut,
  });

  factory ContratModel.fromJson(Map<String, dynamic> json) {
    return ContratModel(
      id:              json['id']?.toString() ?? '',
      locationId:      json['location_id']?.toString() ?? '',
      contenuHtml:     json['contenu_html'] as String? ?? '',
      dateGeneration:  DateTime.parse(
          json['date_generation'] as String? ?? DateTime.now().toIso8601String()),
      dateAcceptation: json['date_acceptation'] != null
          ? DateTime.parse(json['date_acceptation'] as String)
          : null,
      statut: contratStatutFromString(json['statut_signature'] as String? ?? ''),
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
    return InitierLocationResultModel(
      location: LocationModel.fromJson(
          data['location'] as Map<String, dynamic>),
      contrat: ContratModel.fromJson(
          data['contrat'] as Map<String, dynamic>),
    );
  }
}
