import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/initier_location_usecase.dart';
import '../../domain/usecases/accepter_contrat_usecase.dart';
import '../../domain/usecases/payer_location_usecase.dart';

enum LocationStep { duree, contrat, paiement, confirmation }

enum LocationStatus { idle, loading, success, error }

class LocationController extends ChangeNotifier {
  final InitierLocationUseCase _initierUseCase;
  final AccepterContratUseCase _accepterUseCase;
  final PayerLocationUseCase _payerUseCase;

  LocationController({
    required InitierLocationUseCase initierUseCase,
    required AccepterContratUseCase accepterUseCase,
    required PayerLocationUseCase payerUseCase,
  })  : _initierUseCase = initierUseCase,
        _accepterUseCase = accepterUseCase,
        _payerUseCase = payerUseCase;

  // ── Étape courante ────────────────────────────────────────────────────────
  LocationStep _step = LocationStep.duree;
  LocationStep get step => _step;

  // ── Statut de la requête en cours ─────────────────────────────────────────
  LocationStatus _status = LocationStatus.idle;
  LocationStatus get status => _status;
  bool get isLoading => _status == LocationStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Données saisies ───────────────────────────────────────────────────────
  int _dureeMois = 3;
  int get dureeMois => _dureeMois;

  String _operateur = '';
  String get operateur => _operateur;

  // ── Données retournées par le backend ─────────────────────────────────────
  LocationEntity? _location;
  LocationEntity? get location => _location;

  ContratEntity? _contrat;
  ContratEntity? get contrat => _contrat;

  RecuEntity? _recu;
  RecuEntity? get recu => _recu;

  // ── Calcul local du total (avant confirmation backend) ────────────────────
  /// prixPublic est le prix avec commission déjà calculé par le backend.
  double totalEstime(double prixPublic) => prixPublic * _dureeMois;

  DateTime get dateDebut => DateTime.now();
  DateTime dateFinEstimee(DateTime debut) {
    final m = debut.month + _dureeMois;
    final annee = debut.year + (m - 1) ~/ 12;
    final moisFinal = ((m - 1) % 12) + 1;
    return DateTime(annee, moisFinal, debut.day);
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  void setDuree(int mois) {
    if (mois < 3) return;
    if (mois > 36) return;
    _dureeMois = mois;
    notifyListeners();
  }

  void setOperateur(String operateur) {
    _operateur = operateur;
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Étape 1 → 2 : initier la location et récupérer le contrat.
  Future<void> initierLocation(String bienId) async {
    _setLoading();
    try {
      final result = await _initierUseCase(
        bienId: bienId,
        dureeMois: _dureeMois,
      );
      _location = result.location;
      _contrat = result.contrat;
      _step = LocationStep.contrat;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur inattendue est survenue.');
    }
  }

  /// Étape 2 → 3 : accepter le contrat.
  Future<void> accepterContrat() async {
    if (_location == null) return;
    _setLoading();
    try {
      _contrat = await _accepterUseCase(_location!.id);
      _step = LocationStep.paiement;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur inattendue est survenue.');
    }
  }

  /// Étape 3 → 4 : payer et obtenir le reçu.
  Future<void> payer() async {
    if (_location == null || _operateur.isEmpty) return;
    _setLoading();
    try {
      _recu = await _payerUseCase(
        locationId: _location!.id,
        operateurPaiement: _operateur,
      );
      _step = LocationStep.confirmation;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur inattendue est survenue.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading() {
    _status = LocationStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = LocationStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = LocationStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = LocationStatus.idle;
    notifyListeners();
  }
}
