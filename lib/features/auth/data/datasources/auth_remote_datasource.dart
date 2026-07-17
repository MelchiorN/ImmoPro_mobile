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

  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
    String? pendingToken,
  });

  Future<void> resendOtp({
    required String email,
    String? pendingToken,
  });

  String? get pendingToken;
}

/// Implémentation de la data source avec des appels HTTP réels vers le backend Laravel.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

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

  // Stocke le pending_token retourné par le backend pour le passer à verify-otp
  String? _pendingToken;

  /// Expose le pending_token pour que l'OtpPage puisse le récupérer
  @override
  String? get pendingToken => _pendingToken;

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
    final body = await _client.post('/register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'telephone': phone,
      'country': country,
      'city': city,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    // Stocker le pending_token pour l'utiliser dans verify-otp et resend-otp
    _pendingToken = body['pending_token'] as String?;

    return UserModel(
      id: '',
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
    String? pendingToken,
  }) async {
    final tokenToSend = pendingToken ?? _pendingToken;
    final body = await _client.post('/verify-otp', {
      'email': email,
      'otp': otp,
      if (tokenToSend != null) 'pending_token': tokenToSend,
    });

    // Réponse : { "message": "...", "token": "...", "user": {...} }
    final token = body['token'] as String;
    final userJson = body['user'] as Map<String, dynamic>;

    await _client.saveToken(token);
    _pendingToken = null; // nettoyer après utilisation

    return UserModel.fromJson({
      ...userJson,
      'token': token,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /api/resend-otp
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> resendOtp({
    required String email,
    String? pendingToken,
  }) async {
    final tokenToSend = pendingToken ?? _pendingToken;
    await _client.post('/resend-otp', {
      'email': email,
      if (tokenToSend != null) 'pending_token': tokenToSend,
    });
  }
}
