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
  }) =>
      _remote.initierLocation(bienId: bienId, dureeMois: dureeMois);

  @override
  Future<ContratEntity> accepterContrat(String locationId) =>
      _remote.accepterContrat(locationId);

  @override
  Future<LocationEntity> initierPaiement({
    required String locationId,
    required String operateurPaiement,
  }) =>
      _remote.initierPaiement(
        locationId: locationId,
        operateurPaiement: operateurPaiement,
      );

  @override
  Future<RecuEntity> confirmerPaiement(String locationId) =>
      _remote.confirmerPaiement(locationId);
}
