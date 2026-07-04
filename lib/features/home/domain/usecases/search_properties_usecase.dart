import '../entities/property_entity.dart';
import '../repositories/home_repository.dart';

class SearchPropertiesUseCase {
  final HomeRepository repository;

  SearchPropertiesUseCase(this.repository);

  Future<List<PropertyEntity>> call(String query) async {
    return await repository.searchProperties(query);
  }
}
