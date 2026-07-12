import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String city,
  }) {
    return remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      country: country,
      city: city,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return remoteDataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> toggle2FA({required bool enabled}) {
    return remoteDataSource.toggle2FA(enabled: enabled);
  }

  @override
  Future<String> updatePhoto(String filePath) {
    return remoteDataSource.updatePhoto(filePath);
  }
}
