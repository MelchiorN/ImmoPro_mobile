/// Entité représentant une demande de location soumise au backend.
class DemandeLocationEntity {
  final String? id;
  final String bienId;
  final DateTime dateDebut;
  final int dureeMois;
  final DateTime dateFinEstimee;
  final double totalEstime;
  final String statut; // 'en_attente' | 'acceptee' | 'refusee'
  final DateTime? createdAt;

  const DemandeLocationEntity({
    this.id,
    required this.bienId,
    required this.dateDebut,
    required this.dureeMois,
    required this.dateFinEstimee,
    required this.totalEstime,
    this.statut = 'en_attente',
    this.createdAt,
  });
}
