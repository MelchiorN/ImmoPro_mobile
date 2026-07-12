import 'package:flutter/foundation.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../../core/di/service_locator.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginController extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginController(this.loginUseCase);

  LoginStatus _status = LoginStatus.idle;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get obscurePassword => _obscurePassword;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUseCase(LoginParams(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      ));
      ServiceLocator.instance.currentUser = user;
      _status = LoginStatus.success;
    } catch (e) {
      _status = LoginStatus.failure;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _status = LoginStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
