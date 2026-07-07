import '../../domain/entities/property_draft_entity.dart';
import '../../domain/repositories/publish_repository.dart';
import '../datasources/publish_remote_datasource.dart';
import '../models/property_draft_model.dart';

class PublishRepositoryImpl implements PublishRepository {
  final PublishRemoteDataSource _remoteDataSource;

  const PublishRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> submitProperty(PropertyDraftEntity draft) {
    final model = PropertyDraftModel.fromEntity(draft);
    return _remoteDataSource.submitProperty(model);
  }
}
