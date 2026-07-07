import '../entities/property_draft_entity.dart';

/// Contrat du repository pour la publication d'un bien.
abstract class PublishRepository {
  /// Soumet le brouillon complet pour vérification.
  /// Retourne l'ID de l'annonce créée.
  Future<String> submitProperty(PropertyDraftEntity draft);
}
