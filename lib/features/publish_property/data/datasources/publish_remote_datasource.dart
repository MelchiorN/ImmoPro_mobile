import '../../../../core/network/api_client.dart';
import '../models/category_schema_model.dart';
import '../models/property_draft_model.dart';

abstract class PublishRemoteDataSource {
  Future<CategorySchemaModel> getCategorySchema(String slug);
  Future<List<Map<String, dynamic>>> getCategories();
  Future<String> submitProperty(PropertyDraftModel model);
  Future<void> updateProperty(String id, PropertyDraftModel model);
}

class PublishRemoteDataSourceImpl implements PublishRemoteDataSource {
  final ApiClient _apiClient;

  PublishRemoteDataSourceImpl([ApiClient? client])
      : _apiClient = client ?? ApiClient.instance;

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiClient.getPublic('/categories');
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // ── GET /api/categories/{slug}/schema ─────────────────────────────────────

  @override
  Future<CategorySchemaModel> getCategorySchema(String slug) async {
    final response = await _apiClient.getPublic('/categories/$slug/schema');
    final data = response['data'] as Map<String, dynamic>;
    return CategorySchemaModel.fromJson(data);
  }

  // ── POST /api/biens (multipart) ────────────────────────────────────────────

  @override
  Future<String> submitProperty(PropertyDraftModel model) async {
    // ── Champs texte (socle) ──────────────────────────────────────────────
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
    if (model.superficie != null) {
      fields['superficie'] = model.superficie!.toStringAsFixed(2);
    }
    if ((model.description ?? '').isNotEmpty) {
      fields['description'] = model.description!;
    }

    // nb_pieces et nb_salles_bain uniquement pour les types qui en ont
    const typesSansChambre = {'terrain', 'bureau_commerce', 'chambre_studio'};
    final typeNorm = _normalizeTypeBien(model.propertyType ?? '');
    if (!typesSansChambre.contains(typeNorm)) {
      fields['nb_pieces']      = model.rooms.toString();
      fields['nb_salles_bain'] = model.bathrooms.toString();
    }

    // ── Caractéristiques dynamiques ───────────────────────────────────────
    // On envoie chaque clé comme caracteristiques[nom_champ]=valeur
    if (model.caracteristiques.isNotEmpty) {
      model.caracteristiques.forEach((key, value) {
        if (value != null) {
          fields['caracteristiques[$key]'] = value.toString();
        }
      });
    }

    // ── Fichiers ──────────────────────────────────────────────────────────
    final files = <MultipartFileEntry>[];

    // Médias (photos + vidéos)
    for (final path in model.mediaPaths) {
      files.add(MultipartFileEntry(fieldName: 'medias[]', filePath: path));
    }

    // Documents
    if (model.idDocumentPath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[piece_identite]',
        filePath:  model.idDocumentPath!,
      ));
    }
    if (model.justificatifProprietePath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[justificatif_propriete]',
        filePath:  model.justificatifProprietePath!,
      ));
    }
    if (model.cadastralPlanPath != null) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[plan_cadastral]',
        filePath:  model.cadastralPlanPath!,
      ));
    }
    for (int i = 0; i < model.otherDocumentPaths.length; i++) {
      files.add(MultipartFileEntry(
        fieldName: 'documents[autres][$i]',
        filePath:  model.otherDocumentPaths[i],
      ));
    }

    // ── Appel API ─────────────────────────────────────────────────────────
    final response = await _apiClient.postMultipart(
      '/biens',
      fields: fields,
      files:  files,
    );

    return response['data']['id']?.toString() ?? '';
  }

  // ── PUT /api/mes-biens/{id} ────────────────────────────────────────────────

  @override
  Future<void> updateProperty(String id, PropertyDraftModel model) async {
    final fields = <String, dynamic>{
      'type_bien':        _normalizeTypeBien(model.propertyType ?? ''),
      'type_transaction': _normalizeTypeTransaction(model.transactionType ?? ''),
      'titre':            model.title ?? '',
      'prix':             model.price ?? 0,
      'adresse':          model.address ?? '',
      'latitude':         model.latitude ?? 0,
      'longitude':        model.longitude ?? 0,
    };

    if (model.surface != null) {
      fields['surface'] = model.surface;
    }
    if (model.superficie != null) {
      fields['superficie'] = model.superficie;
    }
    if ((model.description ?? '').isNotEmpty) {
      fields['description'] = model.description!;
    }

    const typesSansChambre = {'terrain', 'bureau_commerce', 'chambre_studio'};
    final typeNorm = _normalizeTypeBien(model.propertyType ?? '');
    if (!typesSansChambre.contains(typeNorm)) {
      fields['nb_pieces']      = model.rooms;
      fields['nb_salles_bain'] = model.bathrooms;
    }

    if (model.caracteristiques.isNotEmpty) {
      fields['caracteristiques'] = model.caracteristiques;
    }

    await _apiClient.putAuth('/mes-biens/$id', fields);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalizeTypeBien(String v) {
    return v.trim().toLowerCase().replaceAll(' / ', '_').replaceAll(' ', '_');
  }

  String _normalizeTypeTransaction(String v) {
    switch (v.trim().toLowerCase()) {
      case 'vente':      return 'vente';
      case 'location':   return 'location';
      case 'colocation': return 'colocation';
      default:           return v.toLowerCase();
    }
  }
}
