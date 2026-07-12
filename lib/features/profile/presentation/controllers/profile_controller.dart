import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user_entity.dart';

enum ProfilePhotoStatus { idle, uploading, success, error }

class ProfileController extends ChangeNotifier {
  // ── Session ────────────────────────────────────────────────────────────────
  UserEntity? get user => ServiceLocator.instance.currentUser;

  // ── Stats (réelles à connecter à une API future) ──────────────────────────
  int get propertyCount => 0;
  int get visitCount    => 0;
  int get favoriteCount => 0;

  // ── Photo upload ──────────────────────────────────────────────────────────
  ProfilePhotoStatus _photoStatus = ProfilePhotoStatus.idle;
  ProfilePhotoStatus get photoStatus => _photoStatus;

  String? _photoError;
  String? get photoError => _photoError;

  Future<void> uploadPhoto(String filePath) async {
    _photoStatus = ProfilePhotoStatus.uploading;
    _photoError  = null;
    notifyListeners();

    try {
      final newUrl = await ServiceLocator.instance.updatePhotoUseCase(filePath);

      // Mettre à jour l'utilisateur en session avec la nouvelle URL
      final current = ServiceLocator.instance.currentUser;
      if (current != null && newUrl.isNotEmpty) {
        ServiceLocator.instance.currentUser = UserEntity(
          id:               current.id,
          firstName:        current.firstName,
          lastName:         current.lastName,
          email:            current.email,
          telephone:        current.telephone,
          country:          current.country,
          city:             current.city,
          profilePicture:   newUrl,
          role:             current.role,
          status:           current.status,
          emailVerifiedAt:  current.emailVerifiedAt,
          token:            current.token,
        );
      }
      _photoStatus = ProfilePhotoStatus.success;
    } catch (e) {
      _photoStatus = ProfilePhotoStatus.error;
      _photoError  = 'Impossible de mettre à jour la photo.';
    }

    notifyListeners();
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiClient.instance.deleteToken();
    ServiceLocator.instance.currentUser = null;
    notifyListeners();
  }

  void resetPhotoStatus() {
    _photoStatus = ProfilePhotoStatus.idle;
    _photoError  = null;
    notifyListeners();
  }
}
