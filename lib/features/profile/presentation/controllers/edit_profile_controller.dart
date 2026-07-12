import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum EditProfileStatus { idle, loading, success, failure }

class EditProfileController extends ChangeNotifier {
  final UpdateProfileUseCase updateProfileUseCase;

  EditProfileController({required this.updateProfileUseCase});

  EditProfileStatus _status = EditProfileStatus.idle;
  String? _errorMessage;

  EditProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String city,
  }) async {
    _status = EditProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await updateProfileUseCase(UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        country: country,
        city: city,
      ));

      // Préserver le token Sanctum (le backend ne le renvoie pas lors d'un update)
      final currentToken = ServiceLocator.instance.currentUser?.token;
      final userWithToken = updatedUser.token == null && currentToken != null
          ? UserEntity(
              id: updatedUser.id,
              firstName: updatedUser.firstName,
              lastName: updatedUser.lastName,
              email: updatedUser.email,
              telephone: updatedUser.telephone,
              country: updatedUser.country,
              city: updatedUser.city,
              profilePicture: updatedUser.profilePicture,
              role: updatedUser.role,
              status: updatedUser.status,
              emailVerifiedAt: updatedUser.emailVerifiedAt,
              token: currentToken,
            )
          : updatedUser;

      // Mettre à jour l'utilisateur de la session globale
      ServiceLocator.instance.currentUser = userWithToken;
      
      _status = EditProfileStatus.success;
    } catch (e) {
      _status = EditProfileStatus.failure;
      if (e is Exception) {
        // Extraire le message sans le préfixe "Exception: "
        final raw = e.toString();
        _errorMessage = raw.startsWith('Exception: ')
            ? raw.substring('Exception: '.length)
            : raw;
      } else {
        _errorMessage = 'Une erreur est survenue.';
      }
    }

    notifyListeners();
  }

  void reset() {
    _status = EditProfileStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
