import '../repositories/home_repository.dart';

class GetCategoriesUseCase {
  final HomeRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<String>> call() async {
    return await repository.getCategories();
  }
}
