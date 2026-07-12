import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String city;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
  });
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<UserEntity> call(UpdateProfileParams params) {
    return repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      country: params.country,
      city: params.city,
    );
  }
}
