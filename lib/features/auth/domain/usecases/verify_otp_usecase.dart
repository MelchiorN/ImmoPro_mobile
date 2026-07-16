import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  final String email;
  final String otp;
  final String? pendingToken;

  const VerifyOtpParams({
    required this.email,
    required this.otp,
    this.pendingToken,
  });
}

/// Valide le code OTP et retourne l'utilisateur avec son token Sanctum.
class VerifyOtpUseCase {
  final AuthRepository repository;
  const VerifyOtpUseCase(this.repository);

  Future<UserEntity> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      email: params.email,
      otp: params.otp,
      pendingToken: params.pendingToken,
    );
  }
}

class ResendOtpUseCase {
  final AuthRepository repository;
  const ResendOtpUseCase(this.repository);

  Future<void> call(String email, {String? pendingToken}) {
    return repository.resendOtp(email: email, pendingToken: pendingToken);
  }
}
