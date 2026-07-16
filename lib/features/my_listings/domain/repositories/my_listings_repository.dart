import '../entities/listing_entity.dart';

abstract class MyListingsRepository {
  /// Récupère toutes les annonces de l'utilisateur connecté.
  Future<List<ListingEntity>> getMyListings();

  /// Récupère les détails complets d'une annonce.
  Future<ListingEntity> getListingDetail(String id);

  /// Remplace les photos d'un bien par les nouveaux fichiers fournis.
  Future<ListingEntity> uploadMedia(String bienId, List<String> filePaths);
}
