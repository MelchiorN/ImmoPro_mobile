import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource localDatasource;

  HomeRepositoryImpl({required this.localDatasource});

  @override
  Future<List<PropertyEntity>> getRecentProperties() async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return localDatasource.getRecentProperties();
  }

  @override
  Future<List<PropertyEntity>> getPropertiesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return localDatasource.getPropertiesByCategory(category);
  }

  @override
  Future<List<PropertyEntity>> searchProperties(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return localDatasource.searchProperties(query);
  }

  @override
  Future<List<String>> getCategories() async {
    return localDatasource.getCategories();
  }

  @override
  Future<String> getCurrentUserName() async {
    return localDatasource.getCurrentUserName();
  }
}
