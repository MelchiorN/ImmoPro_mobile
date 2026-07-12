import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> updateProfile({
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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl([ApiClient? client])
      : _apiClient = client ?? ApiClient.instance;

  // ── Mettre à jour le profil ──────────────────────────────────────────────

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String city,
  }) async {
    final response = await _apiClient.putAuth('/client/profile', {
      'first_name': firstName,
      'last_name':  lastName,
      'email':      email,
      'telephone':  phone,
      'country':    country,
      'city':       city,
    });

    // Backend retourne { "success": true, "user": {...} }
    final userJson = response['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // ── Changer le mot de passe ──────────────────────────────────────────────

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.putAuth('/client/password', {
      'current_password':      oldPassword,
      'password':              newPassword,
      'password_confirmation': newPassword,
    });
  }

  // ── Toggle 2FA ────────────────────────────────────────────────────────────

  @override
  Future<void> toggle2FA({required bool enabled}) async {
    await _apiClient.postAuth('/client/2fa', {
      'enabled': enabled,
    });
  }

  // ── Upload photo de profil ────────────────────────────────────────────────

  @override
  Future<String> updatePhoto(String filePath) async {
    // Utiliser readAsBytes pour une compatibilité maximale cross-platform
    // (évite les problèmes avec les URI content:// sur Android)
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileName = filePath.split('/').last.split('\\').last;

    final response = await _apiClient.postMultipartBytes(
      '/client/profile/photo',
      fields: {},
      files: [
        MultipartBytesEntry(
          fieldName: 'photo',
          bytes: bytes,
          fileName: fileName,
        ),
      ],
    );

    final url = response['profile_picture'] as String?;
    if (url == null || url.isEmpty) {
      throw ApiException(
        statusCode: 200,
        message: 'La réponse du serveur ne contient pas l\'URL de la photo.',
      );
    }
    return url;
  }
}
