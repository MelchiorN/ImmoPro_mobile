import '../network/api_client.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/publish_property/data/datasources/publish_remote_datasource.dart';
import '../../features/publish_property/data/repositories/publish_repository_impl.dart';
import '../../features/publish_property/domain/usecases/submit_property_usecase.dart';
import '../../features/publish_property/presentation/controllers/publish_controller.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/profile/domain/usecases/toggle_2fa_usecase.dart';
import '../../features/profile/domain/usecases/update_photo_usecase.dart';
import '../../features/my_listings/data/datasources/my_listings_remote_datasource.dart';
import '../../features/my_listings/data/repositories/my_listings_repository_impl.dart';
import '../../features/my_listings/domain/usecases/get_my_listings_usecase.dart';
import '../../features/my_listings/presentation/controllers/my_listings_controller.dart';
import '../../features/location_bien/data/datasources/location_remote_datasource.dart';
import '../../features/location_bien/data/repositories/location_repository_impl.dart';
import '../../features/location_bien/domain/usecases/initier_location_usecase.dart';
import '../../features/location_bien/domain/usecases/accepter_contrat_usecase.dart';
import '../../features/location_bien/domain/usecases/payer_location_usecase.dart';
import '../../features/location_bien/presentation/controllers/location_controller.dart';
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/favorites/presentation/controllers/favorites_controller.dart';

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

  // ── Session ──────────────────────────────────────────────────────────────
  UserEntity? currentUser;

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

  // ── Publish property ──────────────────────────────────────────────────────
  late final PublishRemoteDataSource publishRemoteDataSource =
      PublishRemoteDataSourceImpl(apiClient);

  late final PublishRepositoryImpl publishRepository =
      PublishRepositoryImpl(publishRemoteDataSource);

  late final SubmitPropertyUseCase submitPropertyUseCase =
      SubmitPropertyUseCase(publishRepository);

  /// Crée une NOUVELLE instance du controller à chaque appel.
  /// Le controller est stateful (brouillon multi-étapes) donc ne doit pas
  /// être partagé — chaque flow de publication démarre avec un controller frais.
  PublishController createPublishController() =>
      PublishController(submitPropertyUseCase, publishRemoteDataSource);

  // ── Profile ───────────────────────────────────────────────────────────────
  late final ProfileRemoteDataSource profileRemoteDataSource =
      ProfileRemoteDataSourceImpl(apiClient);

  late final ProfileRepository profileRepository =
      ProfileRepositoryImpl(profileRemoteDataSource);

  late final UpdateProfileUseCase updateProfileUseCase =
      UpdateProfileUseCase(profileRepository);

  late final ChangePasswordUseCase changePasswordUseCase =
      ChangePasswordUseCase(profileRepository);

  late final Toggle2FAUseCase toggle2FAUseCase =
      Toggle2FAUseCase(profileRepository);

  late final UpdatePhotoUseCase updatePhotoUseCase =
      UpdatePhotoUseCase(profileRepository);

  // ── My Listings ───────────────────────────────────────────────────────────
  late final MyListingsRemoteDataSource myListingsRemoteDataSource =
      MyListingsRemoteDataSourceImpl(apiClient);

  late final MyListingsRepositoryImpl myListingsRepository =
      MyListingsRepositoryImpl(myListingsRemoteDataSource);

  late final GetMyListingsUseCase getMyListingsUseCase =
      GetMyListingsUseCase(myListingsRepository);

  /// Singleton partagé — une seule instance pour tout le cycle de vie de l'app.
  late final MyListingsController myListingsController =
      MyListingsController(getMyListingsUseCase, myListingsRepository);

  // ── Location ──────────────────────────────────────────────────────────────
  late final LocationRemoteDataSource locationRemoteDataSource =
      LocationRemoteDataSourceImpl(apiClient);

  late final LocationRepositoryImpl locationRepository =
      LocationRepositoryImpl(locationRemoteDataSource);

  late final InitierLocationUseCase initierLocationUseCase =
      InitierLocationUseCase(locationRepository);

  late final AccepterContratUseCase accepterContratUseCase =
      AccepterContratUseCase(locationRepository);

  late final PayerLocationUseCase payerLocationUseCase =
      PayerLocationUseCase(locationRepository);

  /// Crée une NOUVELLE instance du controller à chaque tunnel de location.
  /// Comme PublishController, il est stateful (multi-étapes) donc ne doit
  /// pas être partagé.
  LocationController createLocationController() => LocationController(
        initierUseCase: initierLocationUseCase,
        accepterUseCase: accepterContratUseCase,
        payerUseCase: payerLocationUseCase,
      );

  // ── Favorites ─────────────────────────────────────────────────────────────
  late final FavoritesRemoteDataSource favoritesRemoteDataSource =
      FavoritesRemoteDataSourceImpl(client: apiClient);

  late final FavoritesRepositoryImpl favoritesRepository =
      FavoritesRepositoryImpl(favoritesRemoteDataSource);

  late final GetFavoritesUseCase getFavoritesUseCase =
      GetFavoritesUseCase(favoritesRepository);

  late final ToggleFavoriteUseCase toggleFavoriteUseCase =
      ToggleFavoriteUseCase(favoritesRepository);

  /// Singleton partagé
  late final FavoritesController favoritesController = FavoritesController(
    getFavoritesUseCase: getFavoritesUseCase,
    toggleFavoriteUseCase: toggleFavoriteUseCase,
  );
}
