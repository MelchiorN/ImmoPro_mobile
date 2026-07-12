import '../repositories/profile_repository.dart';

class UpdatePhotoUseCase {
  final ProfileRepository repository;

  const UpdatePhotoUseCase(this.repository);

  Future<String> call(String filePath) {
    return repository.updatePhoto(filePath);
  }
}
