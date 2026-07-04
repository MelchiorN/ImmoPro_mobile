import '../entities/property_entity.dart';
import '../repositories/home_repository.dart';

class GetRecentPropertiesUseCase {
  final HomeRepository repository;

  GetRecentPropertiesUseCase(this.repository);

  Future<List<PropertyEntity>> call() async {
    return await repository.getRecentProperties();
  }
}
