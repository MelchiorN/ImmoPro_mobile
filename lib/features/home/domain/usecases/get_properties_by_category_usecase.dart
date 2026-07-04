import '../entities/property_entity.dart';
import '../repositories/home_repository.dart';

class GetPropertiesByCategoryUseCase {
  final HomeRepository repository;

  GetPropertiesByCategoryUseCase(this.repository);

  Future<List<PropertyEntity>> call(String category) async {
    return await repository.getPropertiesByCategory(category);
  }
}
