import '../../domain/entities/property_entity.dart';

class PropertyMediaModel extends PropertyMedia {
  const PropertyMediaModel({
    required super.id,
    required super.type,
    required super.url,
    super.isPrimary,
    super.order,
  });

  factory PropertyMediaModel.fromJson(Map<String, dynamic> json) {
    return PropertyMediaModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
      isPrimary: json['est_principale'] as bool? ?? false,
      order: json['ordre'] as int? ?? 0,
    );
  }
}

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.location,
    super.surface,
    super.rooms,
    super.bathrooms,
    super.imageUrl,
    super.videoUrl,
    super.isVerified,
    required super.type,
    required super.category,
    super.latitude,
    super.longitude,
    super.publishedAt,
    super.medias,
  });

  /// Parse depuis BienListResource (GET /api/biens)
  factory PropertyModel.fromListJson(Map<String, dynamic> json) {
    final mediasRaw = json['medias'] as List<dynamic>? ?? [];
    final medias = mediasRaw
        .map((m) => PropertyMediaModel.fromJson(m as Map<String, dynamic>))
        .toList();

    // Cherche la photo principale parmi les médias, sinon utilise photo_principale
    String? imageUrl = json['photo_principale'] as String?;
    String? videoUrl;

    for (final m in medias) {
      if (m.isPrimary) {
        if (m.type == 'video') {
          videoUrl = m.url;
        } else {
          imageUrl = m.url;
        }
        break;
      }
    }
    // Si pas de principale, prend la première image
    if (imageUrl == null || imageUrl.isEmpty) {
      for (final m in medias) {
        if (m.type == 'image') {
          imageUrl = m.url;
          break;
        }
      }
    }

    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['prix'] as num?)?.toDouble() ?? 0,
      location: json['adresse'] as String? ?? '',
      surface: (json['surface'] as num?)?.toDouble(),
      rooms: json['nb_pieces'] as int?,
      bathrooms: null, // not in list resource
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isVerified: json['statut'] == 'publie',
      type: _parseType(json['type_transaction'] as String?),
      category: _parseCategory(json['type_bien'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      publishedAt: json['publie_le'] as String?,
      medias: medias,
    );
  }

  /// Parse depuis BienResource (GET /api/biens/{id})
  factory PropertyModel.fromDetailJson(Map<String, dynamic> json) {
    final mediasRaw = json['medias'] as List<dynamic>? ?? [];
    final medias = mediasRaw
        .map((m) => PropertyMediaModel.fromJson(m as Map<String, dynamic>))
        .toList();

    String? imageUrl;
    String? videoUrl;

    for (final m in medias) {
      if (m.type == 'video' && videoUrl == null) videoUrl = m.url;
      if (m.type == 'image' && imageUrl == null) imageUrl = m.url;
      if (m.isPrimary) {
        if (m.type == 'image') imageUrl = m.url;
        if (m.type == 'video') videoUrl = m.url;
        break;
      }
    }

    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['prix'] as num?)?.toDouble() ?? 0,
      location: json['adresse'] as String? ?? '',
      surface: (json['surface'] as num?)?.toDouble(),
      rooms: json['nb_pieces'] as int?,
      bathrooms: json['nb_salles_bain'] as int?,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isVerified: json['statut'] == 'publie',
      type: _parseType(json['type_transaction'] as String?),
      category: _parseCategory(json['type_bien'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      publishedAt: json['publie_le'] as String?,
      medias: medias,
    );
  }

  static PropertyType _parseType(String? raw) {
    switch (raw) {
      case 'location':
        return PropertyType.rent;
      case 'colocation':
        return PropertyType.colocation;
      default:
        return PropertyType.sale;
    }
  }

  static String _parseCategory(String? raw) {
    switch (raw) {
      case 'appartement':
        return 'Appartement';
      case 'maison':
        return 'Maison';
      case 'villa':
        return 'Villa';
      case 'terrain':
        return 'Terrain';
      case 'bureau_commerce':
        return 'Bureau';
      default:
        return raw ?? 'Autre';
    }
  }

  /// Clé API correspondant à une catégorie affichée
  static String? categoryToApiKey(String category) {
    switch (category) {
      case 'Appartement':
        return 'appartement';
      case 'Maison':
        return 'maison';
      case 'Villa':
        return 'villa';
      case 'Terrain':
        return 'terrain';
      case 'Bureau':
        return 'bureau_commerce';
      default:
        return null; // "Tous" → pas de filtre
    }
  }
}
