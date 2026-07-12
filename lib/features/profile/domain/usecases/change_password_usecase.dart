import '../repositories/profile_repository.dart';

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });
}

class ChangePasswordUseCase {
  final ProfileRepository repository;

  const ChangePasswordUseCase(this.repository);

  Future<void> call(ChangePasswordParams params) {
    return repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}
