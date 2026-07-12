import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/property_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  static const List<String> _categories = [
    'Tous',
    'Appartement',
    'Maison',
    'Villa',
    'Terrain',
    'Bureau',
  ];

  @override
  Future<List<PropertyEntity>> getRecentProperties({
    int page = 1,
    int perPage = 15,
  }) async {
    return remoteDataSource.getProperties(
      sort: 'date_desc',
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<PropertyEntity>> getPropertiesByCategory(
    String category, {
    int page = 1,
    int perPage = 15,
  }) async {
    final apiKey = PropertyModel.categoryToApiKey(category);
    return remoteDataSource.getProperties(
      typeBien: apiKey,
      sort: 'date_desc',
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<PropertyEntity>> searchProperties(
    String query, {
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
  }) async {
    return remoteDataSource.getProperties(
      search: query,
      typeTransaction: typeTransaction,
      prixMin: prixMin,
      prixMax: prixMax,
      surfaceMin: surfaceMin,
      sort: 'date_desc',
    );
  }

  @override
  Future<List<String>> getCategories() async {
    return List.from(_categories);
  }

  @override
  Future<PropertyEntity> getPropertyDetail(String id) async {
    return remoteDataSource.getPropertyDetail(id);
  }
}
