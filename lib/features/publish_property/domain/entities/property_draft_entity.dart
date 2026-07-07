/// Entité domaine représentant le brouillon d'un bien à publier.
/// Immuable — chaque modification produit une nouvelle instance via copyWith.
class PropertyDraftEntity {
  final String? propertyType;
  final String? transactionType; // 'Vente' | 'Location' | 'Colocation'
  final String? title;
  final double? price;
  final double? surface;
  final int rooms;
  final int bathrooms;
  final String? description;

  // Localisation
  final String? address;
  final double? latitude;
  final double? longitude;

  // Étape 2 : médias
  final List<String> mediaPaths; // chemins locaux

  // Étape 3 : documents
  final String? titleDeedPath;  // titre foncier
  final String? idDocumentPath; // pièce d'identité
  final String? cadastralPlanPath; // plan cadastral (optionnel)
  final List<String> otherDocumentPaths; // autres documents libres

  const PropertyDraftEntity({
    this.propertyType,
    this.transactionType,
    this.title,
    this.price,
    this.surface,
    this.rooms = 1,
    this.bathrooms = 1,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.mediaPaths = const [],
    this.titleDeedPath,
    this.idDocumentPath,
    this.cadastralPlanPath,
    this.otherDocumentPaths = const [],
  });

  PropertyDraftEntity copyWith({
    String? propertyType,
    String? transactionType,
    String? title,
    double? price,
    double? surface,
    int? rooms,
    int? bathrooms,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? mediaPaths,
    String? titleDeedPath,
    String? idDocumentPath,
    String? cadastralPlanPath,
    List<String>? otherDocumentPaths,
  }) {
    return PropertyDraftEntity(
      propertyType: propertyType ?? this.propertyType,
      transactionType: transactionType ?? this.transactionType,
      title: title ?? this.title,
      price: price ?? this.price,
      surface: surface ?? this.surface,
      rooms: rooms ?? this.rooms,
      bathrooms: bathrooms ?? this.bathrooms,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      titleDeedPath: titleDeedPath ?? this.titleDeedPath,
      idDocumentPath: idDocumentPath ?? this.idDocumentPath,
      cadastralPlanPath: cadastralPlanPath ?? this.cadastralPlanPath,
      otherDocumentPaths: otherDocumentPaths ?? this.otherDocumentPaths,
    );
  }
}
