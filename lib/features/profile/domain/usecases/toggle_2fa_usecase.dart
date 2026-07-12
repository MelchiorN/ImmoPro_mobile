import '../repositories/profile_repository.dart';

class Toggle2FAParams {
  final bool enabled;

  const Toggle2FAParams({required this.enabled});
}

class Toggle2FAUseCase {
  final ProfileRepository repository;

  const Toggle2FAUseCase(this.repository);

  Future<void> call(Toggle2FAParams params) {
    return repository.toggle2FA(enabled: params.enabled);
  }
}
