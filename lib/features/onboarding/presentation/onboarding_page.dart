import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/models/onboarding_page_model.dart';
import '../../auth/presentation/pages/login_page.dart';

const String _kHeroImage = 'lib/assets/images/onboradimg.png';

const List<OnboardingPageModel> _pages = [
  // ── Slide 1 : illustration vectorielle ──
  OnboardingPageModel(
    title: 'Découvrez des biens exclusifs',
    description:
        'Accédez à une sélection rigoureuse de propriétés haut de gamme adaptées à vos besoins.',
    illustrationIcon: Icons.location_city_rounded,
    iconColor: Color(0xFF003E7E),
    bgColor: Color(0xFFD6E3FF),
  ),
  // ── Slide 2 : illustration vectorielle ──
  OnboardingPageModel(
    title: 'Vérification certifiée',
    description:
        'Chaque bien sur notre plateforme est vérifié par nos experts pour garantir votre sécurité.',
    illustrationIcon: Icons.verified_rounded,
    iconColor: Color(0xFF005996),
    bgColor: Color(0xFFD1E4FF),
  ),
  // ── Slide 3 : illustration vectorielle ──
  OnboardingPageModel(
    title: 'Gérez vos transactions',
    description:
        'Suivez vos réservations, paiements et visites en temps réel depuis votre tableau de bord.',
    illustrationIcon: Icons.account_balance_wallet_rounded,
    iconColor: Color(0xFF1A56A0),
    bgColor: Color(0xFFD5E3FF),
  ),
  // ── Slide 4 : hero photo onboradimg.png ──
  OnboardingPageModel(
    title: 'Prêt à commencer ?',
    description:
        "Rejoignez la communauté ImmoPro et trouvez la perle rare dès aujourd'hui.",
    useHeroImage: true,
  ),
];

// ─────────────────────────────────────────────
// Page principale
// ─────────────────────────────────────────────
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skip() => _navigateToLogin();

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(onSkip: _skip),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingSlide(
                  model: _pages[i],
                  fadeAnim: _fadeAnim,
                  slideAnim: _slideAnim,
                ),
              ),
            ),
            _Footer(
              currentIndex: _currentIndex,
              totalPages: _pages.length,
              isLast: isLast,
              onNext: _goToNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TopBar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onSkip;
  const _TopBar({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Passer',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slide — dispatch entre vectoriel et hero image
// ─────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final OnboardingPageModel model;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _OnboardingSlide({
    required this.model,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return model.useHeroImage
        ? _HeroImageSlide(model: model, fadeAnim: fadeAnim, slideAnim: slideAnim)
        : _VectorSlide(model: model, fadeAnim: fadeAnim, slideAnim: slideAnim);
  }
}

// ─────────────────────────────────────────────
// Slides 1-3 : cercle tonal + icône (design HTML)
// ─────────────────────────────────────────────
class _VectorSlide extends StatelessWidget {
  final OnboardingPageModel model;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _VectorSlide({
    required this.model,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration vectorielle
          FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _VectorIllustration(
                icon: model.illustrationIcon!,
                iconColor: model.iconColor!,
                bgColor: model.bgColor!,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Texte
          FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Column(
                children: [
                  Text(
                    model.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                      letterSpacing: -0.56,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    model.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Illustration vectorielle : deux cercles + icône
// ─────────────────────────────────────────────
class _VectorIllustration extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _VectorIllustration({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond tonal (grand)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
          // Cercle intérieur (plus petit, plus saturé)
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
          // Icône
          Icon(icon, size: 96, color: iconColor),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slide 4 : hero photo onboradimg.png
// layout : image 60% + texte + dots + bouton
// ─────────────────────────────────────────────
class _HeroImageSlide extends StatelessWidget {
  final OnboardingPageModel model;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _HeroImageSlide({
    required this.model,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Photo plein largeur (60% hauteur du slide)
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(_kHeroImage, fit: BoxFit.cover),
              // Dégradé en haut : overlay sombre pour lisibilité
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x55000000), Colors.transparent],
                    stops: [0.0, 0.45],
                  ),
                ),
              ),
              // Fondu blanc vers le bas
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Texte centré
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                        letterSpacing: -0.64,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      model.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 16,
                        color: AppColors.outline,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Footer : dots animés + bouton
// ─────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final bool isLast;
  final VoidCallback onNext;

  const _Footer({
    required this.currentIndex,
    required this.totalPages,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final active = i == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Bouton
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                isLast ? 'Commencer' : 'Suivant',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}