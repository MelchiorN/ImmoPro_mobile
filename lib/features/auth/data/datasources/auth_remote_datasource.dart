import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String confirmPassword,
  });
}

/// Implémentation — à brancher sur le vrai client HTTP (Dio) plus tard
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: injecter Dio ici
  // final Dio dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: POST /api/login
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Connecter à l\'API Laravel');
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String confirmPassword,
  }) async {
    // TODO: POST /api/register
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Connecter à l\'API Laravel');
  }
}
