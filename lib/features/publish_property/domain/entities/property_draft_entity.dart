/// Entité domaine représentant le brouillon d'un bien à publier.
/// Immuable — chaque modification produit une nouvelle instance via copyWith.
class PropertyDraftEntity {
  final String? propertyType;       // slug API : 'appartement', 'maison', etc.
  final String? transactionType;    // 'Vente' | 'Location' | 'Colocation'
  final String? title;
  final double? price;
  final double? surface;
  final double? superficie;
  final int rooms;
  final int bathrooms;
  final String? description;

  // Localisation
  final String? address;
  final double? latitude;
  final double? longitude;

  // Champs dynamiques de la catégorie (clé = nom_champ, valeur = dynamic)
  final Map<String, dynamic> caracteristiques;

  // Étape 2 : médias
  final List<String> mediaPaths;

  // Étape 3 : documents
  final String? idDocumentPath;           // pièce d'identité (obligatoire)
  final String? justificatifProprietePath; // justificatif de propriété (optionnel)
  final String? cadastralPlanPath;        // plan cadastral (optionnel)
  final List<String> otherDocumentPaths;  // autres documents libres

  const PropertyDraftEntity({
    this.propertyType,
    this.transactionType,
    this.title,
    this.price,
    this.surface,
    this.superficie,
    this.rooms = 1,
    this.bathrooms = 1,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.caracteristiques = const {},
    this.mediaPaths = const [],
    this.idDocumentPath,
    this.justificatifProprietePath,
    this.cadastralPlanPath,
    this.otherDocumentPaths = const [],
  });

  PropertyDraftEntity copyWith({
    String? propertyType,
    String? transactionType,
    String? title,
    double? price,
    double? surface,
    double? superficie,
    int? rooms,
    int? bathrooms,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? caracteristiques,
    List<String>? mediaPaths,
    String? idDocumentPath,
    bool clearIdDocument = false,
    String? justificatifProprietePath,
    bool clearJustificatif = false,
    String? cadastralPlanPath,
    bool clearCadastral = false,
    List<String>? otherDocumentPaths,
  }) {
    return PropertyDraftEntity(
      propertyType:             propertyType            ?? this.propertyType,
      transactionType:          transactionType         ?? this.transactionType,
      title:                    title                   ?? this.title,
      price:                    price                   ?? this.price,
      surface:                  surface                 ?? this.surface,
      superficie:               superficie              ?? this.superficie,
      rooms:                    rooms                   ?? this.rooms,
      bathrooms:                bathrooms               ?? this.bathrooms,
      description:              description             ?? this.description,
      address:                  address                 ?? this.address,
      latitude:                 latitude                ?? this.latitude,
      longitude:                longitude               ?? this.longitude,
      caracteristiques:         caracteristiques        ?? this.caracteristiques,
      mediaPaths:               mediaPaths              ?? this.mediaPaths,
      idDocumentPath:           clearIdDocument         ? null : (idDocumentPath            ?? this.idDocumentPath),
      justificatifProprietePath:clearJustificatif       ? null : (justificatifProprietePath  ?? this.justificatifProprietePath),
      cadastralPlanPath:        clearCadastral          ? null : (cadastralPlanPath          ?? this.cadastralPlanPath),
      otherDocumentPaths:       otherDocumentPaths      ?? this.otherDocumentPaths,
    );
  }
}
