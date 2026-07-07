import '../../../../core/network/api_client.dart';
import '../models/property_draft_model.dart';

abstract class PublishRemoteDataSource {
  Future<String> submitProperty(PropertyDraftModel model);
}

/// Implémentation réelle — appel multipart vers POST /api/biens.
class PublishRemoteDataSourceImpl implements PublishRemoteDataSource {
  final ApiClient _apiClient;

  PublishRemoteDataSourceImpl([ApiClient? client])
      : _apiClient = client ?? ApiClient.instance;

  @override
  Future<String> submitProperty(PropertyDraftModel model) async {
    // ── Champs texte ──────────────────────────────────────────────────────────
    final fields = <String, String>{
      'type_bien':        _normalizeTypeBien(model.propertyType ?? ''),
      'type_transaction': _normalizeTypeTransaction(model.transactionType ?? ''),
      'titre':            model.title ?? '',
      'prix':             model.price?.toStringAsFixed(2) ?? '0',
      'adresse':          model.address ?? '',
      'latitude':         model.latitude?.toString() ?? '0',
      'longitude':        model.longitude?.toString() ?? '0',
    };

    if (model.surface != null) {
      fields['surface'] = model.surface!.toStringAsFixed(2);
    }

    if ((model.description ?? '').isNotEmpty) {
      fields['description'] = model.description!;
    }

    // Pièces/SDB uniquement si le type de bien les supporte
    const typesSansChambre = {'terrain'};
    final typeNormalise = _normalizeTypeBien(model.propertyType ?? '');
    if (!typesSansChambre.contains(typeNormalise)) {
      fields['nb_pieces']      = model.rooms.toString();
      fields['nb_salles_bain'] = model.bathrooms.toString();
    }

    // ── Fichiers ──────────────────────────────────────────────────────────────
    final files = <MultipartFileEntry>[];

    // Médias (photos + vidéos)
    for (int i = 0; i < model.mediaPaths.length; i++) {
      files.add(MultipartFileEntry(
        fieldName: 'medias[]',
        filePath: model.mediaPaths[i],
      ));
    }

    // Documents
    if (model.titleDeedPath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[titre_foncier]',
        filePath: model.titleDeedPath!,
      ));
    }
    if (model.idDocumentPath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[piece_identite]',
        filePath: model.idDocumentPath!,
      ));
    }
    if (model.cadastralPlanPath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[plan_cadastral]',
        filePath: model.cadastralPlanPath!,
      ));
    }

    // Autres documents libres
    for (int i = 0; i < model.otherDocumentPaths.length; i++) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[autres][$i]',
        filePath: model.otherDocumentPaths[i],
      ));
    }

    // ── Appel API ─────────────────────────────────────────────────────────────
    final response = await _apiClient.postMultipart(
      '/biens',
      fields: fields,
      files: files,
    );

    // Le backend retourne { "success": true, "data": { "id": "uuid", ... } }
    final data = response['data'] as Map<String, dynamic>?;
    return data?['id'] as String? ?? '';
  }

  // ── Helpers de normalisation ─────────────────────────────────────────────

  /// Convertit le type de bien affiché en UI vers la valeur enum backend.
  String _normalizeTypeBien(String uiValue) {
    switch (uiValue.trim().toLowerCase()) {
      case 'appartement':
        return 'appartement';
      case 'maison':
        return 'maison';
      case 'villa':
        return 'villa';
      case 'terrain':
        return 'terrain';
      case 'bureau / commerce':
      case 'bureau/commerce':
      case 'bureau_commerce':
        return 'bureau_commerce';
      default:
        return uiValue.toLowerCase().replaceAll(' / ', '_').replaceAll(' ', '_');
    }
  }

  /// Convertit le type de transaction affiché en UI vers la valeur enum backend.
  String _normalizeTypeTransaction(String uiValue) {
    switch (uiValue.trim().toLowerCase()) {
      case 'vente':
        return 'vente';
      case 'location':
        return 'location';
      case 'colocation':
        return 'colocation';
      default:
        return uiValue.toLowerCase();
    }
  }
}
