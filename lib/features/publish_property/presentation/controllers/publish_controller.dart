import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/property_draft_entity.dart';
import '../../domain/usecases/submit_property_usecase.dart';

enum PublishStatus { idle, loading, success, error }

/// Controller du flow "Publier un bien".
/// Gère le brouillon à travers les 4 étapes et la soumission finale.
class PublishController extends ChangeNotifier {
  final SubmitPropertyUseCase _submitUseCase;

  PublishController(this._submitUseCase);

  // ── Étape courante (0 à 3) ──────────────────────────────────────────────
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // ── Brouillon ───────────────────────────────────────────────────────────
  PropertyDraftEntity _draft = const PropertyDraftEntity();
  PropertyDraftEntity get draft => _draft;

  // ── État de soumission ──────────────────────────────────────────────────
  PublishStatus _status = PublishStatus.idle;
  PublishStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _submittedPropertyId;
  String? get submittedPropertyId => _submittedPropertyId;

  // ── Navigation entre étapes ──────────────────────────────────────────────

  void goToStep(int step) {
    _currentStep = step.clamp(0, 3);
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
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
    final value = double.tryParse(raw.replaceAll(' ', ''));
    if (value != null) {
      _draft = _draft.copyWith(price: value);
      notifyListeners();
    }
  }

  void updateSurface(String raw) {
    final value = double.tryParse(raw.replaceAll(' ', ''));
    if (value != null) {
      _draft = _draft.copyWith(surface: value);
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

  void updateLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) {
    _draft = _draft.copyWith(
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  // ── Médias ───────────────────────────────────────────────────────────────

  void addMediaPath(String path) {
    if (_draft.mediaPaths.length < 10) {
      _draft = _draft.copyWith(
        mediaPaths: [..._draft.mediaPaths, path],
      );
      notifyListeners();
    }
  }

  void removeMediaAt(int index) {
    final updated = List<String>.from(_draft.mediaPaths)..removeAt(index);
    _draft = _draft.copyWith(mediaPaths: updated);
    notifyListeners();
  }

  // ── Documents ────────────────────────────────────────────────────────────

  void setTitleDeed(String? path) {
    _draft = _draft.copyWith(titleDeedPath: path);
    notifyListeners();
  }

  void setIdDocument(String? path) {
    _draft = _draft.copyWith(idDocumentPath: path);
    notifyListeners();
  }

  void setCadastralPlan(String? path) {
    _draft = _draft.copyWith(cadastralPlanPath: path);
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
      // Erreurs de validation Laravel (422)
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
    } catch (e) {
      _status = PublishStatus.error;
      _errorMessage = 'Échec de la soumission. Vérifiez votre connexion et réessayez.';
    }

    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    _status = PublishStatus.idle;
    notifyListeners();
  }
}
