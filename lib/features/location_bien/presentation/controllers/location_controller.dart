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
  int _dureeMois = 1;
  int get dureeMois => _dureeMois;

  DateTime _dateDebut = DateTime.now();
  DateTime get dateDebut => _dateDebut;

  String _operateur = '';
  String get operateur => _operateur;

  String _telephone = '';
  String get telephone => _telephone;

  // ── Données retournées par le backend ─────────────────────────────────────
  LocationEntity? _location;
  LocationEntity? get location => _location;

  ContratEntity? _contrat;
  ContratEntity? get contrat => _contrat;

  /// Résultat de l'initiation du paiement Semoa (instructions USSD / carte)
  PaiementSemoaEntity? _paiementSemoa;
  PaiementSemoaEntity? get paiementSemoa => _paiementSemoa;

  RecuEntity? _recu;
  RecuEntity? get recu => _recu;

  // ── Calcul local du total (avant confirmation backend) ────────────────────
  /// prixPublic est le prix avec commission déjà calculé par le backend.
  double totalEstime(double prixPublic) => prixPublic * _dureeMois;

  DateTime get dateFin {
    final m = _dateDebut.month + _dureeMois;
    final annee = _dateDebut.year + (m - 1) ~/ 12;
    final moisFinal = ((m - 1) % 12) + 1;
    return DateTime(annee, moisFinal, _dateDebut.day);
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  void setDuree(int mois) {
    if (mois < 1) return;
    if (mois > 36) return;
    _dureeMois = mois;
    notifyListeners();
  }

  void setDateDebut(DateTime date) {
    // Refuser toute date strictement antérieure à aujourd'hui
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly.isBefore(todayOnly)) return;
    _dateDebut = dateOnly;
    notifyListeners();
  }

  void setOperateur(String operateur) {
    _operateur = operateur;
    notifyListeners();
  }

  void setTelephone(String telephone) {
    _telephone = telephone;
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
        dateDebut: _dateDebut,
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

  /// Étape 2 (Refus) : refuser le contrat et libérer la réservation.
  Future<void> refuserContrat() async {
    if (_location == null) return;
    _setLoading();
    try {
      await ApiClient.instance.postAuth('/mobile/locations/${_location!.id}/refuser-contrat');
      _step = LocationStep.duree;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur est survenue lors du refus du contrat.');
    }
  }

  /// Annulation silencieuse utilisée lors de l'appui sur le bouton retour
  void annulerLocationSilencieux() {
    if (_location == null) return;
    try {
      ApiClient.instance.postAuth('/mobile/locations/${_location!.id}/refuser-contrat');
      _location = null; // Évite de renvoyer la requête plusieurs fois
      _step = LocationStep.duree;
    } catch (_) {}
  }

  /// Étape 3 → 4 : initier le paiement via Semoa CashPay.
  /// Après appel réussi, l'utilisateur voit les instructions (USSD/carte).
  /// La confirmation définitive arrive via webhook Semoa → backend.
  Future<void> payer() async {
    if (_location == null || _operateur.isEmpty) return;
    _setLoading();
    try {
      _paiementSemoa = await _payerUseCase(
        locationId: _location!.id,
        operateurPaiement: _operateur,
        telephone: _telephone.isNotEmpty ? _telephone : null,
      );
      _step = LocationStep.confirmation;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur inattendue est survenue.');
    }
  }

  /// Appelé depuis l'écran de confirmation pour vérifier le statut réel du paiement Semoa
  /// et obtenir le reçu final s'il est validé.
  Future<bool> verifierPaiement() async {
    if (_location == null || _paiementSemoa == null) return false;
    _setLoading();
    try {
      final response = await ApiClient.instance.postAuth(
        '/mobile/locations/${_location!.id}/confirmer-paiement',
        {
          'paiement_id': _paiementSemoa!.paiementId,
        },
      );
      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final recuMap = data['recu'] ?? {};
        
        _recu = RecuEntity(
          id: recuMap['id']?.toString() ?? '',
          paiementId: _paiementSemoa!.paiementId,
          numeroRecu: recuMap['numero_recu']?.toString() ?? '',
          dateEmission: DateTime.tryParse(recuMap['date']?.toString() ?? '') ?? DateTime.now(),
          montant: _paiementSemoa!.montant,
          operateurPaiement: _paiementSemoa!.operateur,
        );
        
        _setSuccess();
        return true;
      } else {
        _setError(response['message'] ?? 'Paiement toujours en cours de validation.');
        return false;
      }
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Une erreur inattendue est survenue.');
      return false;
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
