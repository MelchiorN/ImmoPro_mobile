import 'package:flutter/foundation.dart';
import '../../domain/usecases/register_usecase.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterController extends ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterController(this.registerUseCase);

  RegisterStatus _status = RegisterStatus.idle;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  // Pays sélectionné (nom + code + drapeau)
  String _selectedCountry = 'Togo';
  String _selectedDialCode = '+228';
  String _selectedFlag = '🇹🇬';

  RegisterStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get acceptedTerms => _acceptedTerms;
  String get selectedCountry => _selectedCountry;
  String get selectedDialCode => _selectedDialCode;
  String get selectedFlag => _selectedFlag;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    _acceptedTerms = value ?? false;
    notifyListeners();
  }

  void selectCountry({
    required String country,
    required String dialCode,
    required String flag,
  }) {
    _selectedCountry = country;
    _selectedDialCode = dialCode;
    _selectedFlag = flag;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await registerUseCase(RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        countryCode: _selectedDialCode,
        password: password,
        confirmPassword: confirmPassword,
      ));
      _status = RegisterStatus.success;
    } catch (e) {
      _status = RegisterStatus.failure;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _status = RegisterStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
