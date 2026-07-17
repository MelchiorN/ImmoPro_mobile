import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/fcm_service.dart';

enum OtpStatus { idle, loading, success, failure }

class OtpController extends ChangeNotifier {
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final String email;
  final String? pendingToken;

  OtpController({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.email,
    this.pendingToken,
  }) {
    _startCountdown();
  }

  OtpStatus _status = OtpStatus.idle;
  String? _errorMessage;
  int _secondsLeft = 59;
  bool _canResend = false;
  Timer? _timer;
  UserEntity? _authenticatedUser;

  OtpStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get secondsLeft => _secondsLeft;
  bool get canResend => _canResend;
  UserEntity? get authenticatedUser => _authenticatedUser;

  String get countdownText {
    final s = _secondsLeft < 10 ? '0$_secondsLeft' : '$_secondsLeft';
    return '00:$s';
  }

  void _startCountdown() {
    _secondsLeft = 59;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        _canResend = true;
      } else {
        _secondsLeft--;
      }
      notifyListeners();
    });
  }

  Future<void> verify(String otp) async {
    if (otp.length != 6) {
      _errorMessage = 'Entrez les 6 chiffres du code';
      notifyListeners();
      return;
    }
    _status = OtpStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _authenticatedUser = await verifyOtpUseCase(
        VerifyOtpParams(email: email, otp: otp, pendingToken: pendingToken),
      );
      ServiceLocator.instance.currentUser = _authenticatedUser;
      _status = OtpStatus.success;
    } catch (e) {
      _status = OtpStatus.failure;
      _errorMessage = 'Code incorrect ou expiré';
    }
    notifyListeners();
  }

  Future<void> resend() async {
    if (!_canResend) return;
    try {
      await resendOtpUseCase(email, pendingToken: pendingToken);
      _startCountdown();
      _errorMessage = null;
      _status = OtpStatus.idle;
    } catch (_) {
      _errorMessage = 'Impossible de renvoyer le code';
    }
    notifyListeners();
  }

  void reset() {
    _status = OtpStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
