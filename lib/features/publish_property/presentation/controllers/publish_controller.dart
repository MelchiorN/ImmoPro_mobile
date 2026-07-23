import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/publish_remote_datasource.dart';
import '../../domain/entities/category_schema_entity.dart';
import '../../domain/entities/property_draft_entity.dart';
import '../../domain/usecases/submit_property_usecase.dart';
import '../../../my_listings/domain/entities/listing_entity.dart';
import '../../data/models/property_draft_model.dart';

enum PublishStatus { idle, loading, success, error }
enum SchemaStatus  { idle, loading, loaded, error }

class PublishController extends ChangeNotifier {
  final SubmitPropertyUseCase      _submitUseCase;
  final PublishRemoteDataSource    _dataSource;

  PublishController(this._submitUseCase, [PublishRemoteDataSource? dataSource])
      : _dataSource = dataSource ?? PublishRemoteDataSourceImpl();

  // ── Brouillon ───────────────────────────────────────────────────────────
  PropertyDraftEntity _draft = const PropertyDraftEntity();
  PropertyDraftEntity get draft => _draft;

  // ── Schéma dynamique de la catégorie ───────────────────────────────────
  CategorySchemaEntity? _schema;
  CategorySchemaEntity? get schema => _schema;

  SchemaStatus _schemaStatus = SchemaStatus.idle;
  SchemaStatus get schemaStatus => _schemaStatus;

  // ── État de soumission ──────────────────────────────────────────────────
  PublishStatus _status = PublishStatus.idle;
  PublishStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _submittedPropertyId;
  String? get submittedPropertyId => _submittedPropertyId;

  List<Map<String, String>> _categoriesList = [];
  List<Map<String, String>> get categoriesList => _categoriesList;

  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final data = await _dataSource.getCategories();
      _categoriesList = data.map((c) => {
        'slug': c['slug'] as String? ?? '',
        'nom': c['nom'] as String? ?? '',
      }).where((element) => element['slug']!.isNotEmpty).toList();
      notifyListeners();
      return _categoriesList;
    } catch (_) {
      return [];
    }
  }

  // ── Chargement du schéma de catégorie ───────────────────────────────────

  Future<void> loadCategorySchema(String slug) async {
    if (_schemaStatus == SchemaStatus.loading) return;
    _schemaStatus = SchemaStatus.loading;
    notifyListeners();
    try {
      _schema = await _dataSource.getCategorySchema(slug);
      _schemaStatus = SchemaStatus.loaded;
      // Réinitialiser les caracteristiques si le type change
      _draft = _draft.copyWith(caracteristiques: {});
    } catch (_) {
      _schemaStatus = SchemaStatus.error;
    }
    notifyListeners();
  }

  // ── Mise à jour du brouillon ─────────────────────────────────────────────

  void updatePropertyType(String type) {
    _draft = _draft.copyWith(propertyType: type);
    notifyListeners();
  }

  void updateTransactionType(String type) {
    _draft = _draft.copyWith(transactionType: type);
    notifyListeners();
  }

  void updateTitle(String title) {
    _draft = _draft.copyWith(title: title);
    notifyListeners();
  }

  void updatePrice(String raw) {
    final value = double.tryParse(raw.replaceAll(' ', '').replaceAll(',', '.'));
    if (value != null) {
      _draft = _draft.copyWith(price: value);
      notifyListeners();
    }
  }

  void updateSurface(String raw) {
    final value = double.tryParse(raw.replaceAll(' ', '').replaceAll(',', '.'));
    if (value != null) {
      _draft = _draft.copyWith(surface: value);
      notifyListeners();
    }
  }

  void updateSuperficie(String raw) {
    final value = double.tryParse(raw.replaceAll(' ', '').replaceAll(',', '.'));
    if (value != null) {
      _draft = _draft.copyWith(superficie: value);
      notifyListeners();
    }
  }

  void updateRooms(int value) {
    if (value >= 1) {
      _draft = _draft.copyWith(rooms: value);
      notifyListeners();
    }
  }

  void incrementRooms() {
    _draft = _draft.copyWith(rooms: _draft.rooms + 1);
    notifyListeners();
  }

  void decrementRooms() {
    if (_draft.rooms > 1) {
      _draft = _draft.copyWith(rooms: _draft.rooms - 1);
      notifyListeners();
    }
  }

  void updateBathrooms(int value) {
    if (value >= 1) {
      _draft = _draft.copyWith(bathrooms: value);
      notifyListeners();
    }
  }

  void incrementBathrooms() {
    _draft = _draft.copyWith(bathrooms: _draft.bathrooms + 1);
    notifyListeners();
  }

  void decrementBathrooms() {
    if (_draft.bathrooms > 1) {
      _draft = _draft.copyWith(bathrooms: _draft.bathrooms - 1);
      notifyListeners();
    }
  }

  void updateDescription(String desc) {
    _draft = _draft.copyWith(description: desc);
    notifyListeners();
  }

  void updateAddress(String address) {
    _draft = _draft.copyWith(address: address);
    notifyListeners();
  }

  void updateCoordinates(double lat, double lng) {
    _draft = _draft.copyWith(latitude: lat, longitude: lng);
    notifyListeners();
  }

  // ── Caractéristiques dynamiques ──────────────────────────────────────────

  void setCaracteristique(String nomChamp, dynamic value) {
    final updated = Map<String, dynamic>.from(_draft.caracteristiques)
      ..[nomChamp] = value;
    _draft = _draft.copyWith(caracteristiques: updated);
    notifyListeners();
  }

  dynamic getCaracteristique(String nomChamp) {
    return _draft.caracteristiques[nomChamp];
  }

  // ── Médias ───────────────────────────────────────────────────────────────

  void addMediaPath(String path) {
    if (_draft.mediaPaths.length < 10) {
      _draft = _draft.copyWith(mediaPaths: [..._draft.mediaPaths, path]);
      notifyListeners();
    }
  }

  void removeMediaAt(int index) {
    final updated = List<String>.from(_draft.mediaPaths)..removeAt(index);
    _draft = _draft.copyWith(mediaPaths: updated);
    notifyListeners();
  }

  // ── Documents ────────────────────────────────────────────────────────────

  void setIdDocument(String? path) {
    if (path == null) {
      _draft = _draft.copyWith(clearIdDocument: true);
    } else {
      _draft = _draft.copyWith(idDocumentPath: path);
    }
    notifyListeners();
  }

  void setJustificatifPropriete(String? path) {
    if (path == null) {
      _draft = _draft.copyWith(clearJustificatif: true);
    } else {
      _draft = _draft.copyWith(justificatifProprietePath: path);
    }
    notifyListeners();
  }

  void setCadastralPlan(String? path) {
    if (path == null) {
      _draft = _draft.copyWith(clearCadastral: true);
    } else {
      _draft = _draft.copyWith(cadastralPlanPath: path);
    }
    notifyListeners();
  }

  void addOtherDocument(String path) {
    _draft = _draft.copyWith(
      otherDocumentPaths: [..._draft.otherDocumentPaths, path],
    );
    notifyListeners();
  }

  void removeOtherDocument(int index) {
    final updated = List<String>.from(_draft.otherDocumentPaths)
      ..removeAt(index);
    _draft = _draft.copyWith(otherDocumentPaths: updated);
    notifyListeners();
  }

  // ── Soumission ───────────────────────────────────────────────────────────

  Future<void> submitProperty() async {
    _status = PublishStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _submittedPropertyId = await _submitUseCase(_draft);
      _status = PublishStatus.success;
    } on ApiException catch (e) {
      _status = PublishStatus.error;
      if (e.statusCode == 422 && e.errors != null) {
        final msgs = e.errors!.values
            .expand((v) => v is List ? v : [v])
            .take(3)
            .join('\n');
        _errorMessage = msgs.isNotEmpty ? msgs : e.message;
      } else if (e.statusCode == 401) {
        _errorMessage = 'Session expirée. Reconnectez-vous.';
      } else {
        _errorMessage = e.message;
      }
    } catch (_) {
      _status = PublishStatus.error;
      _errorMessage =
          'Échec de la soumission. Vérifiez votre connexion et réessayez.';
    }
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    _status = PublishStatus.idle;
    notifyListeners();
  }

  // ── Mode Édition ─────────────────────────────────────────────────────────

  void initForEdit(ListingEntity listing) {
    _draft = PropertyDraftEntity(
      propertyType: listing.typeBien,
      transactionType: listing.typeTransaction,
      title: listing.title,
      price: listing.price,
      surface: listing.surface,
      rooms: listing.rooms ?? 1,
      bathrooms: listing.bathrooms ?? 1,
      description: listing.description,
      address: listing.location,
      caracteristiques: Map<String, dynamic>.from(listing.caracteristiques),
      // we don't handle media/documents here for edit text
    );
    loadCategorySchema(listing.typeBien);
    _status = PublishStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateExistingProperty(String id) async {
    _status = PublishStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = PropertyDraftModel.fromEntity(_draft);
      await _dataSource.updateProperty(id, model);
      _status = PublishStatus.success;
    } on ApiException catch (e) {
      _status = PublishStatus.error;
      if (e.statusCode == 422 && e.errors != null) {
        final msgs = e.errors!.values
            .expand((v) => v is List ? v : [v])
            .take(3)
            .join('\n');
        _errorMessage = msgs.isNotEmpty ? msgs : e.message;
      } else {
        _errorMessage = e.message;
      }
    } catch (_) {
      _status = PublishStatus.error;
      _errorMessage = 'Échec de la modification. Vérifiez votre connexion.';
    }
    notifyListeners();
  }
}
