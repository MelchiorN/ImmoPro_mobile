import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<UserEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String country,
    required String city,
    required String password,
    required String confirmPassword,
  });

  /// Valide l'OTP et retourne l'utilisateur avec son token Sanctum.
  Future<UserEntity> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp({required String email});
}
