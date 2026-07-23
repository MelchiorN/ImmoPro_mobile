import '../entities/property_entity.dart';

abstract class HomeRepository {
  Future<List<PropertyEntity>> getRecentProperties({int page, int perPage});
  Future<List<PropertyEntity>> getPropertiesByCategory(
    String category, {
    int page,
    int perPage,
  });
  Future<List<PropertyEntity>> searchProperties(
    String query, {
    String? typeBien,
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
  });
  Future<List<String>> getCategories();
  Future<PropertyEntity> getPropertyDetail(String id);
}
