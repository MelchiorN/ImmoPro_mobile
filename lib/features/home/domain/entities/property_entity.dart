class PropertyEntity {
  final int id;
  final String title;
  final String description;
  final double price;
  final String location;
  final double surface;
  final int rooms;
  final int bathrooms;
  final String imageUrl;
  final String? videoUrl;
  final bool isVerified;
  final PropertyType type;
  final String category;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.surface,
    required this.rooms,
    required this.bathrooms,
    required this.imageUrl,
    this.videoUrl,
    this.isVerified = false,
    required this.type,
    required this.category,
  });
}

enum PropertyType { sale, rent }
