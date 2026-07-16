import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return remoteDataSource.login(email: email, password: password);
  }

  @override
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
  }) {
    return remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      countryCode: countryCode,
      country: country,
      city: city,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<UserEntity> verifyOtp({
    required String email,
    required String otp,
    String? pendingToken,
  }) {
    return remoteDataSource.verifyOtp(
      email: email,
      otp: otp,
      pendingToken: pendingToken,
    );
  }

  @override
  Future<void> resendOtp({
    required String email,
    String? pendingToken,
  }) {
    return remoteDataSource.resendOtp(
      email: email,
      pendingToken: pendingToken,
    );
  }
}
