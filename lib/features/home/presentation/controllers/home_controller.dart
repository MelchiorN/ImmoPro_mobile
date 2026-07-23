import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/property_entity.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/get_recent_properties_usecase.dart';
import '../../domain/usecases/get_properties_by_category_usecase.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeController extends ChangeNotifier {
  final GetRecentPropertiesUseCase getRecentPropertiesUseCase;
  final GetPropertiesByCategoryUseCase getPropertiesByCategoryUseCase;
  final SearchPropertiesUseCase searchPropertiesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  /// Intervalle de rafraîchissement automatique (30 secondes)
  static const _refreshInterval = Duration(seconds: 30);

  Timer? _refreshTimer;

  HomeController({
    required this.getRecentPropertiesUseCase,
    required this.getPropertiesByCategoryUseCase,
    required this.searchPropertiesUseCase,
    required this.getCategoriesUseCase,
  });

  HomeStatus _status = HomeStatus.initial;
  List<PropertyEntity> _properties = [];
  List<String> _categories = [];
  String _selectedCategory = 'Tous';
  String? _errorMessage;
  int _currentNavIndex = 0;

  // Filtres actifs
  String? _filterTypeTransaction;
  double? _filterPrixMin;
  double? _filterPrixMax;
  double? _filterSurfaceMin;
  bool _hasActiveFilters = false;

  HomeStatus get status => _status;
  List<PropertyEntity> get properties => _properties;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  String get userName => ServiceLocator.instance.currentUser?.firstName ?? '';
  int get currentNavIndex => _currentNavIndex;
  bool get hasActiveFilters => _hasActiveFilters;

  String? get filterTypeTransaction => _filterTypeTransaction;
  double? get filterPrixMin => _filterPrixMin;
  double? get filterPrixMax => _filterPrixMax;
  double? get filterSurfaceMin => _filterSurfaceMin;

  /// Démarre le timer de rafraîchissement automatique.
  /// Appelé après le premier chargement réussi.
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _silentRefresh());
  }

  /// Rafraîchissement silencieux (sans spinner) — ne change pas le statut
  /// si des données sont déjà affichées.
  Future<void> _silentRefresh() async {
    if (_hasActiveFilters) return; // Ne pas écraser un filtre actif
    try {
      final fresh = await getRecentPropertiesUseCase();
      _properties = fresh;
      // Met à jour l'état uniquement si chargé (évite d'écraser un état d'erreur)
      if (_status == HomeStatus.loaded) notifyListeners();
    } catch (_) {
      // Échec silencieux — les données existantes restent affichées
    }
  }

  /// Initialise la page d'accueil (catégories + biens)
  Future<void> init() async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await getCategoriesUseCase();
      _selectedCategory = 'Tous';
      _properties = await getRecentPropertiesUseCase();
      _status = HomeStatus.loaded;
      _startAutoRefresh(); // Lance le rafraîchissement auto après succès
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Impossible de charger les données. Vérifiez votre connexion.';
    }

    notifyListeners();
  }

  /// Sélectionne une catégorie et filtre les biens
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _status = HomeStatus.loading;
    notifyListeners();

    try {
      _properties = await getPropertiesByCategoryUseCase(category);
      _status = HomeStatus.loaded;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Impossible de filtrer les biens.';
    }

    notifyListeners();
  }

  /// Recherche de biens par mot-clé (avec filtres optionnels)
  Future<void> search(String query) async {
    if (query.isEmpty && !_hasActiveFilters) {
      await init();
      return;
    }

    _status = HomeStatus.loading;
    notifyListeners();

    try {
      _properties = await searchPropertiesUseCase(SearchParams(
        query: query,
        typeBien: _selectedCategory != 'Tous' ? _selectedCategory : null,
        typeTransaction: _filterTypeTransaction,
        prixMin: _filterPrixMin,
        prixMax: _filterPrixMax,
        surfaceMin: _filterSurfaceMin,
      ));
      _status = HomeStatus.loaded;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Erreur lors de la recherche.';
    }

    notifyListeners();
  }

  /// Applique des filtres et relance la recherche/liste
  Future<void> applyFilters({
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
    String currentQuery = '',
  }) async {
    _filterTypeTransaction = typeTransaction;
    _filterPrixMin = prixMin;
    _filterPrixMax = prixMax;
    _filterSurfaceMin = surfaceMin;
    _hasActiveFilters = typeTransaction != null ||
        prixMin != null ||
        prixMax != null ||
        surfaceMin != null;

    await search(currentQuery);
  }

  /// Réinitialise les filtres
  Future<void> clearFilters() async {
    _filterTypeTransaction = null;
    _filterPrixMin = null;
    _filterPrixMax = null;
    _filterSurfaceMin = null;
    _hasActiveFilters = false;
    await init();
  }

  /// Change l'onglet de la barre de navigation
  void changeNavIndex(int index) {
    if (_currentNavIndex == index) return;
    _currentNavIndex = index;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
