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

  Future<String?> _resolveCategorySlug(String category) async {
    if (category == 'Tous' || category.trim().isEmpty) return null;

    final catLower = category.trim().toLowerCase();

    try {
      final remoteCats = await remoteDataSource.getCategories();
      for (final c in remoteCats) {
        final nom = (c['nom'] as String? ?? '').trim().toLowerCase();
        final slug = (c['slug'] as String? ?? '').trim().toLowerCase();
        if (nom == catLower ||
            slug == catLower ||
            nom.startsWith(catLower) ||
            catLower.startsWith(nom)) {
          if (slug.isNotEmpty) return slug;
        }
      }
    } catch (_) {}

    return PropertyModel.categoryToApiKey(category) ??
        category
            .toLowerCase()
            .replaceAll(' / ', '_')
            .replaceAll('/', '_')
            .replaceAll(' ', '_');
  }

  @override
  Future<List<PropertyEntity>> getPropertiesByCategory(
    String category, {
    int page = 1,
    int perPage = 15,
  }) async {
    final apiKey = await _resolveCategorySlug(category);
    return remoteDataSource.getProperties(
      typeBien: apiKey,
      sort: 'date_desc',
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final remoteCats = await remoteDataSource.getCategories();
      final names = remoteCats
          .map((c) => c['nom'] as String? ?? c['slug'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      if (names.isNotEmpty) {
        return ['Tous', ...names];
      }
    } catch (_) {}
    return List.from(_categories);
  }

  @override
  Future<List<PropertyEntity>> searchProperties(
    String query, {
    String? typeBien,
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
  }) async {
    String? resolvedTypeBien;
    if (typeBien != null && typeBien.isNotEmpty) {
      resolvedTypeBien = await _resolveCategorySlug(typeBien);
    }

    return remoteDataSource.getProperties(
      search: query,
      typeBien: resolvedTypeBien,
      typeTransaction: typeTransaction,
      prixMin: prixMin,
      prixMax: prixMax,
      surfaceMin: surfaceMin,
      sort: 'date_desc',
    );
  }

  @override
  Future<PropertyEntity> getPropertyDetail(String id) async {
    return remoteDataSource.getPropertyDetail(id);
  }
}
