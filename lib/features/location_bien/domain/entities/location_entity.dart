// Entités domaine pour le module de location.

// ─── Location ─────────────────────────────────────────────────────────────────

class LocationEntity {
  final String id;
  final String bienId;
  final String locataireId;
  final String proprietaireId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final int dureeMois;
  final double prixProprietaire;
  final double montantCommission;
  final double montantTotal;
  final LocationStatut statut;

  const LocationEntity({
    required this.id,
    required this.bienId,
    required this.locataireId,
    required this.proprietaireId,
    required this.dateDebut,
    required this.dateFin,
    required this.dureeMois,
    required this.prixProprietaire,
    required this.montantCommission,
    required this.montantTotal,
    required this.statut,
  });
}

enum LocationStatut {
  enAttenteContrat,
  enAttentePaiement,
  actif,
  termine,
  annule,
}

LocationStatut locationStatutFromString(String s) {
  return switch (s) {
    'en_attente_contrat'   => LocationStatut.enAttenteContrat,
    'en_attente_paiement'  => LocationStatut.enAttentePaiement,
    'actif'                => LocationStatut.actif,
    'termine'              => LocationStatut.termine,
    _                      => LocationStatut.annule,
  };
}

// ─── Contrat ──────────────────────────────────────────────────────────────────

class ContratEntity {
  final String id;
  final String locationId;
  final String contenuHtml;
  final DateTime dateGeneration;
  final DateTime? dateAcceptation;
  final ContratStatut statut;

  const ContratEntity({
    required this.id,
    required this.locationId,
    required this.contenuHtml,
    required this.dateGeneration,
    this.dateAcceptation,
    required this.statut,
  });
}

enum ContratStatut { enAttente, signe }

ContratStatut contratStatutFromString(String s) =>
    s == 'signe' ? ContratStatut.signe : ContratStatut.enAttente;

// ─── Reçu ─────────────────────────────────────────────────────────────────────

class RecuEntity {
  final String id;
  final String paiementId;
  final String numeroRecu;
  final DateTime dateEmission;
  final double montant;
  final String operateurPaiement;

  const RecuEntity({
    required this.id,
    required this.paiementId,
    required this.numeroRecu,
    required this.dateEmission,
    required this.montant,
    required this.operateurPaiement,
  });
}

// ─── Résultat d'initiation ────────────────────────────────────────────────────

/// Réponse du backend quand on initie une location :
/// contient la location créée + le contrat généré.
class InitierLocationResult {
  final LocationEntity location;
  final ContratEntity contrat;

  const InitierLocationResult({
    required this.location,
    required this.contrat,
  });
}
