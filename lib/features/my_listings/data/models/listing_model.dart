import '../../../home/domain/entities/property_entity.dart';
import '../../../home/data/models/property_model.dart';
import '../../domain/entities/listing_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.title,
    super.description,
    required super.price,
    required super.location,
    required super.typeBien,
    required super.typeTransaction,
    required super.statut,
    super.imageUrl,
    super.surface,
    super.rooms,
    super.bathrooms,
    super.publishedAt,
    super.createdAt,
    super.rejectionReason,
    super.medias,
    super.caracteristiques,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Récupère la photo principale depuis le tableau medias ou photo_principale
    String? imageUrl = json['photo_principale'] as String?;
    final mediasRaw = json['medias'] as List<dynamic>? ?? [];
    final List<PropertyMedia> medias = mediasRaw
        .map((m) => PropertyMediaModel.fromJson(m as Map<String, dynamic>))
        .toList();

    if ((imageUrl == null || imageUrl.isEmpty) && medias.isNotEmpty) {
      for (final m in medias) {
        if (m.type == 'image' && m.url.isNotEmpty) {
          imageUrl = m.url;
          break;
        }
      }
    }

    // Le backend renvoie 'en_cours' pour les biens en vérification par l'agent.
    // Le backend ProprietaireBienController normalise déjà en 'en_verification',
    // mais on sécurise ici au cas où.
    final rawStatut = json['statut'] as String? ?? 'en_attente';
    final statut = rawStatut == 'en_cours' ? 'en_verification' : rawStatut;

    // raison_rejet est mappé depuis note_admin côté backend
    final rejectionReason = json['raison_rejet'] as String?
        ?? (statut == 'rejete' ? json['note_admin'] as String? : null);

    return ListingModel(
      id:              json['id']?.toString() ?? '',
      title:           json['titre']           as String?  ?? '',
      description:     json['description']     as String?,
      price:           (json['prix'] as num?)?.toDouble() ?? 0,
      location:        json['adresse']         as String?  ?? '',
      typeBien:        json['type_bien']        as String?  ?? '',
      typeTransaction: json['type_transaction'] as String?  ?? '',
      statut:          statut,
      imageUrl:        imageUrl,
      surface:         (json['surface'] as num?)?.toDouble(),
      rooms:           json['nb_pieces']        as int?,
      bathrooms:       json['nb_salles_bain']   as int?,
      publishedAt:     json['publie_le']        as String?,
      createdAt:       json['created_at']       as String?,
      rejectionReason: rejectionReason,
      medias:          medias,
      caracteristiques: (json['caracteristiques'] as Map<String, dynamic>?) ?? {},
    );
  }
}
