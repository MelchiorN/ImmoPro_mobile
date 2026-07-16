import '../../../../core/network/api_client.dart';
import '../models/listing_model.dart';

abstract class MyListingsRemoteDataSource {
  Future<List<ListingModel>> getMyListings();
  Future<ListingModel> getListingDetail(String id);
  Future<ListingModel> uploadMedia(String bienId, List<String> filePaths);
}

class MyListingsRemoteDataSourceImpl implements MyListingsRemoteDataSource {
  final ApiClient _api;

  MyListingsRemoteDataSourceImpl([ApiClient? api])
      : _api = api ?? ApiClient.instance;

  @override
  Future<List<ListingModel>> getMyListings() async {
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

  @override
  Future<ListingModel> uploadMedia(String bienId, List<String> filePaths) async {
    final files = filePaths
        .map((path) => MultipartFileEntry(
              fieldName: 'medias[]',
              filePath: path,
            ))
        .toList();

    final response = await _api.postMultipart(
      '/mes-biens/$bienId/media',
      fields: {},
      files: files,
    );

    final data = response['data'] as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }
}
