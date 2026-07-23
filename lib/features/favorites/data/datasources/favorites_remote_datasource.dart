import '../../../../core/network/api_client.dart';
import '../../../home/data/models/property_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<PropertyModel>> getFavorites();
  Future<bool> toggleFavorite(String propertyId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient apiClient;

  FavoritesRemoteDataSourceImpl({ApiClient? client})
      : apiClient = client ?? ApiClient.instance;

  @override
  Future<List<PropertyModel>> getFavorites() async {
    try {
      final response = await apiClient.getAuth('/favoris');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => PropertyModel.fromListJson(json)).toList();
      }
      throw Exception('Échec de récupération des favoris');
    } catch (e) {
      if (e is ApiException) {
        throw Exception(e.message);
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> toggleFavorite(String propertyId) async {
    try {
      final response = await apiClient.postAuth('/favoris/$propertyId/toggle');
      if (response['success'] == true) {
        return response['is_favorite'] == true;
      }
      throw Exception('Échec de la modification du favori');
    } catch (e) {
      if (e is ApiException) {
        throw Exception(e.message);
      }
      throw Exception(e.toString());
    }
  }
}
