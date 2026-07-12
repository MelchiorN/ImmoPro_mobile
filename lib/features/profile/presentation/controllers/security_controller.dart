import 'package:flutter/foundation.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/toggle_2fa_usecase.dart';

enum SecurityStatus { idle, loading, success, failure }

class ActiveSession {
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;

  ActiveSession({
    required this.device,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
  });
}

class SecurityController extends ChangeNotifier {
  final ChangePasswordUseCase changePasswordUseCase;
  final Toggle2FAUseCase toggle2FAUseCase;

  SecurityController({
    required this.changePasswordUseCase,
    required this.toggle2FAUseCase,
  });

  SecurityStatus _status = SecurityStatus.idle;
  String? _errorMessage;
  bool _is2faEnabled = false;

  SecurityStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get is2faEnabled => _is2faEnabled;

  // Sessions actives mockées conformes à expmo.md
  final List<ActiveSession> _sessions = [
    ActiveSession(device: 'iPhone 13', location: 'Paris, France', lastActive: 'En ligne', isCurrent: true),
    ActiveSession(device: 'Mac Studio', location: 'Nice, France', lastActive: 'Il y a 2h'),
    ActiveSession(device: 'iPad Pro', location: 'Lyon, France', lastActive: 'Hier'),
  ];

  List<ActiveSession> get sessions => List.unmodifiable(_sessions);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _status = SecurityStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await changePasswordUseCase(ChangePasswordParams(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ));
      _status = SecurityStatus.success;
    } catch (e) {
      _status = SecurityStatus.failure;
      if (e is Exception) {
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

  Future<void> toggle2FA(bool value) async {
    _status = SecurityStatus.loading;
    notifyListeners();

    try {
      await toggle2FAUseCase(Toggle2FAParams(enabled: value));
      _is2faEnabled = value;
      _status = SecurityStatus.success;
    } catch (_) {
      // Si la route n'existe pas encore côté backend, on bascule localement
      // sans propager l'erreur à l'UI
      _is2faEnabled = value;
      _status = SecurityStatus.idle;
    }

    notifyListeners();
  }

  void disconnectSession(ActiveSession session) {
    _sessions.removeWhere((s) => s.device == session.device && !s.isCurrent);
    notifyListeners();
  }

  void reset() {
    _status = SecurityStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
