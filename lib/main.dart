import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/publish_property/presentation/pages/step1_info_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style global de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialisation du service locator (injection de dépendances)
  // Le singleton est lazy — les instances ne sont créées qu'au premier accès.
  ServiceLocator.instance;

  runApp(const ImmoproApp());
}

class ImmoproApp extends StatelessWidget {
  const ImmoproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ── Route initiale ──────────────────────────────────────────────────
      initialRoute: '/',

      // ── Routes nommées ──────────────────────────────────────────────────
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/publish': (context) => const Step1InfoPage(),
      },

      // ── Route dynamique pour OTP (arguments supportant Map ou String) ─────────────
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          String email = '';
          String? pendingToken;
          if (settings.arguments is Map<String, dynamic>) {
            final args = settings.arguments as Map<String, dynamic>;
            email = args['email'] as String? ?? '';
            pendingToken = args['pendingToken'] as String?;
          } else if (settings.arguments is String) {
            email = settings.arguments as String;
          }
          return MaterialPageRoute(
            builder: (_) => OtpPage(email: email, pendingToken: pendingToken),
            settings: settings,
          );
        }
        return null;
      },

      // ── Route inconnue ─────────────────────────────────────────────────
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }
}