import '../../../../core/network/api_client.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<InitierLocationResultModel> initierLocation({
    required String bienId,
    required int dureeMois,
  });

  Future<ContratModel> accepterContrat(String locationId);

  Future<LocationModel> initierPaiement({
    required String locationId,
    required String operateurPaiement,
  });

  Future<RecuModel> confirmerPaiement(String locationId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient _api;

  LocationRemoteDataSourceImpl([ApiClient? api])
      : _api = api ?? ApiClient.instance;

  @override
  Future<InitierLocationResultModel> initierLocation({
    required String bienId,
    required int dureeMois,
  }) async {
    final response = await _api.postAuth('/mobile/locations/initier', {
      'bien_id': bienId,
      'duree_mois': dureeMois,
    });
    return InitierLocationResultModel.fromJson(response);
  }

  @override
  Future<ContratModel> accepterContrat(String locationId) async {
    final response =
        await _api.postAuth('/mobile/locations/$locationId/accepter-contrat');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return ContratModel.fromJson(data);
  }

  @override
  Future<LocationModel> initierPaiement({
    required String locationId,
    required String operateurPaiement,
  }) async {
    final response = await _api.postAuth(
      '/mobile/locations/$locationId/payer',
      {'operateur_paiement': operateurPaiement},
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return LocationModel.fromJson(data);
  }

  @override
  Future<RecuModel> confirmerPaiement(String locationId) async {
    final response = await _api
        .postAuth('/mobile/locations/$locationId/confirmer-paiement');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return RecuModel.fromJson(data);
  }
}
