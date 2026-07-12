import '../../../../core/network/api_client.dart';
import '../models/property_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<PropertyModel>> getProperties({
    String? typeBien,
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
    String? ville,
    String? search,
    String? sort,
    int perPage,
    int page,
  });

  Future<PropertyModel> getPropertyDetail(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _api;

  HomeRemoteDataSourceImpl([ApiClient? api]) : _api = api ?? ApiClient.instance;

  @override
  Future<List<PropertyModel>> getProperties({
    String? typeBien,
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
    String? ville,
    String? search,
    String? sort,
    int perPage = 20,
    int page = 1,
  }) async {
    final params = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    if (typeBien != null && typeBien.isNotEmpty) params['type_bien'] = typeBien;
    if (typeTransaction != null && typeTransaction.isNotEmpty) {
      params['type_transaction'] = typeTransaction;
    }
    if (prixMin != null) params['prix_min'] = prixMin.toString();
    if (prixMax != null) params['prix_max'] = prixMax.toString();
    if (surfaceMin != null) params['surface_min'] = surfaceMin.toString();
    if (ville != null && ville.isNotEmpty) params['ville'] = ville;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sort != null) params['sort'] = sort;

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _api.getPublic('/biens?$query');
    final data = response['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => PropertyModel.fromListJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PropertyModel> getPropertyDetail(String id) async {
    final response = await _api.getPublic('/biens/$id');
    final data = response['data'] as Map<String, dynamic>;
    return PropertyModel.fromDetailJson(data);
  }
}
