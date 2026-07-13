import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Contrat de la data source distante pour l'authentification.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
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

  Future<UserModel> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});
}

/// Implémentation de la data source avec des appels HTTP réels vers le backend Laravel.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  // ─────────────────────────────────────────────────────────────────────────
  // POST /api/client/login
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final body = await _client.post('/client/login', {
      'email': email,
      'password': password,
    });

    // Réponse : { "message": "...", "token": "...", "user": {...} }
    final token = body['token'] as String;
    final userJson = body['user'] as Map<String, dynamic>;

    await _client.saveToken(token);

    return UserModel.fromJson({
      ...userJson,
      'token': token,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /api/register
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String country,
    required String city,
    required String password,
    required String confirmPassword,
  }) async {
    await _client.post('/register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'telephone': phone,
      'country': country,
      'city': city,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    // Le backend ne retourne pas de token ici, seulement un message.
    // On créé un UserModel minimal pour faciliter le flux (l'OTP doit ensuite être validé).
    return UserModel(
      id: '', // pas encore disponible
      firstName: firstName,
      lastName: lastName,
      email: email,
      telephone: phone,
      country: country,
      city: city,
      role: 'client',
      status: 'active',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /api/verify-otp
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final body = await _client.post('/verify-otp', {
      'email': email,
      'otp': otp,
    });

    // Réponse : { "message": "...", "token": "...", "user": {...} }
    final token = body['token'] as String;
    final userJson = body['user'] as Map<String, dynamic>;

    await _client.saveToken(token);

    return UserModel.fromJson({
      ...userJson,
      'token': token,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /api/resend-otp
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> resendOtp({required String email}) async {
    await _client.post('/resend-otp', {'email': email});
  }
}
