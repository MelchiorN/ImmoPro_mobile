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

  // Ville (saisie libre ou future liste)
  String _city = '';

  RegisterStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get acceptedTerms => _acceptedTerms;
  String get selectedCountry => _selectedCountry;
  String get selectedDialCode => _selectedDialCode;
  String get selectedFlag => _selectedFlag;
  String get city => _city;

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

  void setCity(String city) {
    _city = city;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? city,
  }) async {
    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await registerUseCase(RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: '$_selectedDialCode$phone',
        countryCode: _selectedDialCode,
        country: _selectedCountry,
        city: city ?? _city,
        password: password,
        confirmPassword: confirmPassword,
      ));
      _status = RegisterStatus.success;
    } catch (e) {
      _status = RegisterStatus.failure;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  void reset() {
    _status = RegisterStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
