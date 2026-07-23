import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remote;
  const LocationRepositoryImpl(this._remote);

  @override
  Future<InitierLocationResult> initierLocation({
    required String bienId,
    required int dureeMois,
    required DateTime dateDebut,
  }) =>
      _remote.initierLocation(
        bienId: bienId,
        dureeMois: dureeMois,
        dateDebut: dateDebut,
      );

  @override
  Future<ContratEntity> accepterContrat(String locationId) =>
      _remote.accepterContrat(locationId);

  @override
  Future<void> refuserContrat(String locationId) =>
      _remote.refuserContrat(locationId);

  @override
  Future<PaiementSemoaEntity> initierPaiement({
    required String locationId,
    required String operateurPaiement,
    String? telephone,
  }) =>
      _remote.initierPaiement(
        locationId: locationId,
        operateurPaiement: operateurPaiement,
        telephone: telephone,
      );
}
