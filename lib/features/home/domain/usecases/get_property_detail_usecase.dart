import '../entities/property_entity.dart';
import '../repositories/home_repository.dart';

class GetPropertyDetailUseCase {
  final HomeRepository repository;

  GetPropertyDetailUseCase(this.repository);

  Future<PropertyEntity> call(String id) => repository.getPropertyDetail(id);
}
