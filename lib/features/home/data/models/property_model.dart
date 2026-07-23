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
    super.caracteristiques,
    super.userId,
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

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    double? parseOptionalDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    Map<String, dynamic> parseCaracteristiques(dynamic v) {
      if (v == null) return {};
      if (v is Map) {
        return Map<String, dynamic>.from(v);
      }
      return {};
    }

    final userId = json['user_id']?.toString() ??
        (json['proprietaire'] is Map ? json['proprietaire']['id']?.toString() : null);

    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parseDouble(json['prix_public'] ?? json['prix']),
      location: json['adresse']?.toString() ?? '',
      surface: parseOptionalDouble(json['surface']),
      rooms: parseOptionalInt(json['nb_pieces']),
      bathrooms: null, // not in list resource
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isVerified: json['statut'] == 'publie',
      type: _parseType(json['type_transaction']?.toString()),
      category: (json['categorie_nom']?.toString()) ?? _parseCategory(json['type_bien']?.toString()),
      latitude: parseOptionalDouble(json['latitude']),
      longitude: parseOptionalDouble(json['longitude']),
      publishedAt: json['publie_le']?.toString(),
      medias: medias,
      caracteristiques: parseCaracteristiques(json['caracteristiques']),
      userId: userId,
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

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    double? parseOptionalDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    Map<String, dynamic> parseCaracteristiques(dynamic v) {
      if (v == null) return {};
      if (v is Map) {
        return Map<String, dynamic>.from(v);
      }
      return {};
    }

    final userId = json['user_id']?.toString() ??
        (json['proprietaire'] is Map ? json['proprietaire']['id']?.toString() : null);

    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parseDouble(json['prix_public'] ?? json['prix']),
      location: json['adresse']?.toString() ?? '',
      surface: parseOptionalDouble(json['surface']),
      rooms: parseOptionalInt(json['nb_pieces']),
      bathrooms: parseOptionalInt(json['nb_salles_bain']),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isVerified: json['statut'] == 'publie',
      type: _parseType(json['type_transaction']?.toString()),
      category: (json['categorie_nom']?.toString()) ?? _parseCategory(json['type_bien']?.toString()),
      latitude: parseOptionalDouble(json['latitude']),
      longitude: parseOptionalDouble(json['longitude']),
      publishedAt: json['publie_le']?.toString(),
      medias: medias,
      caracteristiques: parseCaracteristiques(json['caracteristiques']),
      userId: userId,
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
    if (raw == null || raw.isEmpty) return 'Autre';
    switch (raw) {
      case 'appartement':      return 'Appartement';
      case 'maison':           return 'Maison';
      case 'villa':            return 'Villa';
      case 'terrain':          return 'Terrain';
      case 'bureau_commerce':  return 'Bureau / Commerce';
      case 'chambre_studio':   return 'Chambre / Studio';
      default:
        return raw
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
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
