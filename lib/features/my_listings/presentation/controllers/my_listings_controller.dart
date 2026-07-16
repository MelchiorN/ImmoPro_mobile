import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/my_listings_repository.dart';
import '../../domain/usecases/get_my_listings_usecase.dart';

enum MyListingsStatus { initial, loading, loaded, empty, error }

class MyListingsController extends ChangeNotifier {
  final GetMyListingsUseCase _getMyListings;
  final MyListingsRepository? _repository;

  static const _refreshInterval = Duration(seconds: 30);
  Timer? _refreshTimer;

  MyListingsController(this._getMyListings, [this._repository]);

  MyListingsStatus _status = MyListingsStatus.initial;
  List<ListingEntity> _listings = [];
  String? _errorMessage;

  /// True si l'utilisateur n'a jamais soumis de bien
  bool _hasBiens = true;

  /// Message serveur quand has_biens == false
  static const String _emptyMessage =
      "Vous n'avez pas encore soumis d'annonce. Commencez par publier votre premier bien !";

  MyListingsStatus get status    => _status;
  List<ListingEntity> get listings => _listings;
  String? get errorMessage       => _errorMessage;
  bool get hasBiens              => _hasBiens;
  String get emptyMessage        => _emptyMessage;

  /// Filtre courant : null = tous les statuts
  String? _filterStatut;
  String? get filterStatut => _filterStatut;

  List<ListingEntity> get filteredListings {
    if (_filterStatut == null) return _listings;
    return _listings.where((l) => l.statut == _filterStatut).toList();
  }

  Future<void> load() async {
    _status = MyListingsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _getMyListings();
      _hasBiens = _listings.isNotEmpty;
      _status = _hasBiens ? MyListingsStatus.loaded : MyListingsStatus.empty;
      if (_hasBiens) _startAutoRefresh();
    } catch (e) {
      _status = MyListingsStatus.error;
      _errorMessage = 'Impossible de charger vos annonces.';
    }
    notifyListeners();
  }

  /// Rafraîchissement silencieux sans spinner
  Future<void> silentRefresh() async {
    try {
      final fresh = await _getMyListings();
      _listings = fresh;
      _hasBiens = fresh.isNotEmpty;
      _status = _hasBiens ? MyListingsStatus.loaded : MyListingsStatus.empty;
      notifyListeners();
    } catch (_) {}
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => silentRefresh());
  }

  void setFilter(String? statut) {
    _filterStatut = statut;
    notifyListeners();
  }

  /// Remplace les photos d'un bien et met à jour la liste locale.
  Future<ListingEntity?> uploadMedia(
      String bienId, List<String> filePaths) async {
    if (_repository == null) return null;
    try {
      final updated = await _repository!.uploadMedia(bienId, filePaths);
      // Met à jour le listing local pour refléter les nouvelles images
      _listings = _listings
          .map((l) => l.id == bienId ? updated : l)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
