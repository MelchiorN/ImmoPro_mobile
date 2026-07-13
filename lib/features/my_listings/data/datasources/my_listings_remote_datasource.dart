import '../../../../core/network/api_client.dart';
import '../models/listing_model.dart';

abstract class MyListingsRemoteDataSource {
  Future<List<ListingModel>> getMyListings();
  Future<ListingModel> getListingDetail(String id);
}

class MyListingsRemoteDataSourceImpl implements MyListingsRemoteDataSource {
  final ApiClient _api;

  MyListingsRemoteDataSourceImpl([ApiClient? api])
      : _api = api ?? ApiClient.instance;

  @override
  Future<List<ListingModel>> getMyListings() async {
    // GET /api/proprietaire/biens — retourne les biens de l'utilisateur connecté
    final response = await _api.getAuth('/proprietaire/biens');
    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ListingModel> getListingDetail(String id) async {
    final response = await _api.getAuth('/proprietaire/biens/$id');
    final data = response['data'] as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }
}
