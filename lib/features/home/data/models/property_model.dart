import '../../domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.location,
    required super.surface,
    required super.rooms,
    required super.bathrooms,
    required super.imageUrl,
    super.videoUrl,
    super.isVerified,
    required super.type,
    required super.category,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      surface: (json['surface'] as num).toDouble(),
      rooms: json['rooms'] as int,
      bathrooms: json['bathrooms'] as int,
      imageUrl: json['image_url'] as String,
      videoUrl: json['video_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      type: PropertyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PropertyType.sale,
      ),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'surface': surface,
      'rooms': rooms,
      'bathrooms': bathrooms,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_verified': isVerified,
      'type': type.name,
      'category': category,
    };
  }
}
