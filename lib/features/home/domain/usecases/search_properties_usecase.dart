import '../entities/property_entity.dart';
import '../repositories/home_repository.dart';

class SearchParams {
  final String query;
  final String? typeBien;
  final String? typeTransaction;
  final double? prixMin;
  final double? prixMax;
  final double? surfaceMin;

  const SearchParams({
    required this.query,
    this.typeBien,
    this.typeTransaction,
    this.prixMin,
    this.prixMax,
    this.surfaceMin,
  });
}

class SearchPropertiesUseCase {
  final HomeRepository repository;

  SearchPropertiesUseCase(this.repository);

  Future<List<PropertyEntity>> call(SearchParams params) async {
    return repository.searchProperties(
      params.query,
      typeBien: params.typeBien,
      typeTransaction: params.typeTransaction,
      prixMin: params.prixMin,
      prixMax: params.prixMax,
      surfaceMin: params.surfaceMin,
    );
  }
}
