import '../entities/property_draft_entity.dart';
import '../repositories/publish_repository.dart';

/// Soumet un brouillon de bien pour vérification.
class SubmitPropertyUseCase {
  final PublishRepository _repository;

  const SubmitPropertyUseCase(this._repository);

  Future<String> call(PropertyDraftEntity draft) {
    return _repository.submitProperty(draft);
  }
}
