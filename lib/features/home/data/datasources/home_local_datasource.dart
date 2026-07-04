import '../models/property_model.dart';
import '../../domain/entities/property_entity.dart';

abstract class HomeLocalDatasource {
  List<PropertyModel> getRecentProperties();
  List<PropertyModel> getPropertiesByCategory(String category);
  List<PropertyModel> searchProperties(String query);
  List<String> getCategories();
  String getCurrentUserName();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  // Données mock pour simuler une API
  static final List<PropertyModel> _mockProperties = [
    const PropertyModel(
      id: 1,
      title: 'Appartement T4 moderne avec vue mer',
      description:
          'Appartement T4 moderne avec vue mer, terrasse et parking privé.',
      price: 450000,
      location: 'Nice',
      surface: 85,
      rooms: 3,
      bathrooms: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isVerified: true,
      type: PropertyType.sale,
      category: 'Appartement',
    ),
    const PropertyModel(
      id: 2,
      title: 'Charmant studio rénové, cœur historique',
      description: 'Charmant studio rénové, cœur historique, calme et lumineux.',
      price: 315000,
      location: 'Lyon',
      surface: 35,
      rooms: 1,
      bathrooms: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      isVerified: true,
      type: PropertyType.sale,
      category: 'Appartement',
    ),
    const PropertyModel(
      id: 3,
      title: "Chalet d'exception, accès pistes",
      description: "Chalet d'exception, accès pistes, prestations haut de gamme.",
      price: 890000,
      location: 'Megève',
      surface: 210,
      rooms: 5,
      bathrooms: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      isVerified: true,
      type: PropertyType.sale,
      category: 'Chalet',
    ),
    const PropertyModel(
      id: 4,
      title: 'Villa contemporaine avec piscine',
      description: 'Splendide villa avec piscine chauffée et jardin paysager.',
      price: 1200000,
      location: 'Cannes',
      surface: 320,
      rooms: 6,
      bathrooms: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      isVerified: true,
      type: PropertyType.sale,
      category: 'Villa',
    ),
    const PropertyModel(
      id: 5,
      title: 'Maison de famille en centre-ville',
      description: 'Belle maison bourgeoise rénovée avec cachet et charme.',
      price: 3200,
      location: 'Bordeaux',
      surface: 140,
      rooms: 4,
      bathrooms: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      isVerified: false,
      type: PropertyType.rent,
      category: 'Maison',
    ),
    const PropertyModel(
      id: 6,
      title: 'Loft industriel lumineux',
      description: 'Superbe loft avec grandes baies vitrées, parquet massif.',
      price: 650000,
      location: 'Paris',
      surface: 95,
      rooms: 2,
      bathrooms: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800',
      isVerified: true,
      type: PropertyType.sale,
      category: 'Appartement',
    ),
  ];

  static const List<String> _categories = [
    'Tous',
    'Appartement',
    'Villa',
    'Maison',
    'Chalet',
    'Bureau',
    'Terrain',
  ];

  @override
  List<PropertyModel> getRecentProperties() {
    return List.from(_mockProperties);
  }

  @override
  List<PropertyModel> getPropertiesByCategory(String category) {
    if (category == 'Tous') return List.from(_mockProperties);
    return _mockProperties
        .where((p) => p.category == category)
        .toList();
  }

  @override
  List<PropertyModel> searchProperties(String query) {
    final q = query.toLowerCase();
    return _mockProperties
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<String> getCategories() {
    return List.from(_categories);
  }

  @override
  String getCurrentUserName() {
    return 'Jean';
  }
}
