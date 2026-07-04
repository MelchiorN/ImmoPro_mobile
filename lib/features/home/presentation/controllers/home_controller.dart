import 'package:flutter/foundation.dart';
import '../../domain/entities/property_entity.dart';
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
  String _userName = 'Jean';
  int _currentNavIndex = 0;

  HomeStatus get status => _status;
  List<PropertyEntity> get properties => _properties;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  int get currentNavIndex => _currentNavIndex;

  /// Initialise la page d'accueil (catégories + biens)
  Future<void> init() async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getCategoriesUseCase(),
        getRecentPropertiesUseCase(),
      ]);

      _categories = results[0] as List<String>;
      _properties = results[1] as List<PropertyEntity>;
      _selectedCategory = _categories.isNotEmpty ? _categories.first : 'Tous';
      _status = HomeStatus.loaded;
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

  /// Recherche de biens par mot-clé
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await init();
      return;
    }

    _status = HomeStatus.loading;
    notifyListeners();

    try {
      _properties = await searchPropertiesUseCase(query);
      _status = HomeStatus.loaded;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Erreur lors de la recherche.';
    }

    notifyListeners();
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
}
