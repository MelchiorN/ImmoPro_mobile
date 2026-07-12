class PropertyEntity {
  final String id; // UUID string
  final String title;
  final String description;
  final double price;
  final String location;
  final double? surface;
  final int? rooms;
  final int? bathrooms;
  final String? imageUrl;
  final String? videoUrl;
  final bool isVerified;
  final PropertyType type;        // vente | location | colocation
  final String category;           // type_bien
  final double? latitude;
  final double? longitude;
  final String? publishedAt;
  final List<PropertyMedia> medias;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    this.surface,
    this.rooms,
    this.bathrooms,
    this.imageUrl,
    this.videoUrl,
    this.isVerified = false,
    required this.type,
    required this.category,
    this.latitude,
    this.longitude,
    this.publishedAt,
    this.medias = const [],
  });
}

enum PropertyType { sale, rent, colocation }

class PropertyMedia {
  final String id;
  final String type; // 'image' | 'video'
  final String url;
  final bool isPrimary;
  final int order;

  const PropertyMedia({
    required this.id,
    required this.type,
    required this.url,
    this.isPrimary = false,
    this.order = 0,
  });
}
