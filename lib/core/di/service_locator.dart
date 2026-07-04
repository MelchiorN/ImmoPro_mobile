import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';

/// Service Locator simple pour l'injection de dépendances.
///
/// Usage :
/// ```dart
/// final sl = ServiceLocator.instance;
/// final controller = RegisterController(sl.registerUseCase);
/// ```
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  // ── Network ──────────────────────────────────────────────────────────────
  final ApiClient apiClient = ApiClient.instance;

  // ── Data sources ─────────────────────────────────────────────────────────
  late final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl(apiClient);

  // ── Repositories ─────────────────────────────────────────────────────────
  late final AuthRepository authRepository =
      AuthRepositoryImpl(authRemoteDataSource);

  // ── Use Cases ────────────────────────────────────────────────────────────
  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);
  late final VerifyOtpUseCase verifyOtpUseCase =
      VerifyOtpUseCase(authRepository);
  late final ResendOtpUseCase resendOtpUseCase =
      ResendOtpUseCase(authRepository);
}
