import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String city,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> toggle2FA({
    required bool enabled,
  });

  Future<String> updatePhoto(String filePath);
}
