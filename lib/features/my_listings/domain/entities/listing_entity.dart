import '../../../home/domain/entities/property_entity.dart';

/// Entité domaine pour une annonce appartenant à l'utilisateur connecté.
class ListingEntity {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String location;
  final String typeBien;
  final String typeTransaction;
  final String statut;
  final String? imageUrl;
  final double? surface;
  final int? rooms;
  final int? bathrooms;
  final String? publishedAt;
  final String? createdAt;
  final String? rejectionReason;
  final List<PropertyMedia> medias;
  /// Champs dynamiques de la catégorie, ex: {'nb_chambres': 3, 'etat_bien': 'neuf'}
  final Map<String, dynamic> caracteristiques;

  const ListingEntity({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.location,
    required this.typeBien,
    required this.typeTransaction,
    required this.statut,
    this.imageUrl,
    this.surface,
    this.rooms,
    this.bathrooms,
    this.publishedAt,
    this.createdAt,
    this.rejectionReason,
    this.medias = const [],
    this.caracteristiques = const {},
  });
}
