import '../entities/property_entity.dart';

abstract class HomeRepository {
  Future<List<PropertyEntity>> getRecentProperties();
  Future<List<PropertyEntity>> getPropertiesByCategory(String category);
  Future<List<PropertyEntity>> searchProperties(String query);
  Future<List<String>> getCategories();
  Future<String> getCurrentUserName();
}
