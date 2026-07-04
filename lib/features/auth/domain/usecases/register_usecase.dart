import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode; // code dial (+228)
  final String country;     // nom du pays (Togo)
  final String city;
  final String password;
  final String confirmPassword;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.country,
    required this.city,
    required this.password,
    required this.confirmPassword,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<UserEntity> call(RegisterParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      countryCode: params.countryCode,
      country: params.country,
      city: params.city,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}
