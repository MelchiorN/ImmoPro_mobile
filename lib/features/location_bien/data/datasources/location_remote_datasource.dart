import '../../../../core/network/api_client.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<InitierLocationResultModel> initierLocation({
    required String bienId,
    required int dureeMois,
    required DateTime dateDebut,
  });

  Future<ContratModel> accepterContrat(String locationId);

  Future<void> refuserContrat(String locationId);

  Future<PaiementSemoaModel> initierPaiement({
    required String locationId,
    required String operateurPaiement,
    String? telephone,
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
    required DateTime dateDebut,
  }) async {
    final response = await _api.postAuth('/mobile/locations/initier', {
      'bien_id': bienId,
      'duree_mois': dureeMois,
      'date_debut':
          '${dateDebut.year}-${dateDebut.month.toString().padLeft(2, '0')}-${dateDebut.day.toString().padLeft(2, '0')}',
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
  Future<void> refuserContrat(String locationId) async {
    await _api.postAuth('/mobile/locations/$locationId/refuser-contrat');
  }

  @override
  Future<PaiementSemoaModel> initierPaiement({
    required String locationId,
    required String operateurPaiement,
    String? telephone,
  }) async {
    final body = <String, dynamic>{
      'operateur_paiement': operateurPaiement,
    };
    if (telephone != null && telephone.isNotEmpty) {
      body['telephone'] = telephone;
    }
    final response = await _api.postAuth(
      '/mobile/locations/$locationId/payer',
      body,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return PaiementSemoaModel.fromJson(data);
  }

  @override
  Future<RecuModel> confirmerPaiement(String locationId) async {
    final response = await _api
        .postAuth('/mobile/locations/$locationId/confirmer-paiement');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return RecuModel.fromJson(data);
  }
}
