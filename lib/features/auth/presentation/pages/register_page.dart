import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/register_controller.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

// ─────────────────────────────────────────────
// Page principale
// ─────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      RegisterUseCase(_PlaceholderAuthRepository()),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_controller.acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      _controller.register(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HeroSection(),
            Expanded(
              child: _FormSection(
                formKey: _formKey,
                firstNameCtrl: _firstNameCtrl,
                lastNameCtrl: _lastNameCtrl,
                emailCtrl: _emailCtrl,
                phoneCtrl: _phoneCtrl,
                passwordCtrl: _passwordCtrl,
                confirmCtrl: _confirmCtrl,
                controller: _controller,
                onSubmit: _onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Hero (55% de l'écran)
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.30,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/assets/images/register.png', fit: BoxFit.cover),
          // Overlay dégradé bleu
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A56A0).withOpacity(0.40),
                  const Color(0xFF1A56A0).withOpacity(0.75),
                ],
              ),
            ),
          ),
          // Branding centré
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez ImmoPro',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.56,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Formulaire
// ─────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final RegisterController controller;
  final VoidCallback onSubmit;

  const _FormSection({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Form(
          key: formKey,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => _FormContent(
              firstNameCtrl: firstNameCtrl,
              lastNameCtrl: lastNameCtrl,
              emailCtrl: emailCtrl,
              phoneCtrl: phoneCtrl,
              passwordCtrl: passwordCtrl,
              confirmCtrl: confirmCtrl,
              controller: controller,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Contenu du formulaire
// ─────────────────────────────────────────────
class _FormContent extends StatelessWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final RegisterController controller;
  final VoidCallback onSubmit;

  const _FormContent({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // ── Prénom & Nom (2 colonnes) ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('PRÉNOM'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: firstNameCtrl,
                    hintText: 'Prénom',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('NOM'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: lastNameCtrl,
                    hintText: 'Nom',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Email ──
        const _FieldLabel('ADRESSE EMAIL'),
        const SizedBox(height: 6),
        _InputField(
          controller: emailCtrl,
          hintText: 'email@exemple.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email requis';
            if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        // ── Pays ──
        const _FieldLabel('PAYS'),
        const SizedBox(height: 6),
        _CountryPickerField(controller: controller),
        const SizedBox(height: 14),

        // ── Téléphone ──
        const _FieldLabel('NUMÉRO DE TÉLÉPHONE'),
        const SizedBox(height: 6),
        _PhoneField(
          controller: phoneCtrl,
          registerController: controller,
        ),
        const SizedBox(height: 14),

        // ── Mot de passe ──
        const _FieldLabel('MOT DE PASSE'),
        const SizedBox(height: 6),
        _InputField(
          controller: passwordCtrl,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: controller.obscurePassword,
          suffixIcon: IconButton(
            onPressed: controller.togglePasswordVisibility,
            icon: Icon(
              controller.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.outline,
              size: 22,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Mot de passe requis';
            if (v.length < 6) return 'Minimum 6 caractères';
            return null;
          },
        ),
        const SizedBox(height: 14),

        // ── Confirmer le mot de passe ──
        const _FieldLabel('CONFIRMER LE MOT DE PASSE'),
        const SizedBox(height: 6),
        _InputField(
          controller: confirmCtrl,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: controller.obscureConfirm,
          suffixIcon: IconButton(
            onPressed: controller.toggleConfirmVisibility,
            icon: Icon(
              controller.obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.outline,
              size: 22,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirmation requise';
            if (v != passwordCtrl.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // ── Conditions d'utilisation ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: controller.acceptedTerms,
                onChanged: controller.toggleTerms,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'J\'accepte les '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: ouvrir les CGU
                        },
                        child: const Text(
                          "conditions d'utilisation",
                          style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Message d'erreur ──
        if (controller.status == RegisterStatus.failure &&
            controller.errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Color(0xFFBA1A1A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFF93000A),
                      fontSize: 13,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Bouton Créer mon compte ──
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                controller.status == RegisterStatus.loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.primaryContainer.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: controller.status == RegisterStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Créer mon compte',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Diviseur social ──
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.outlineVariant)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'ou',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.outline,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.outlineVariant)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Boutons sociaux ──
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                onPressed: () {/* TODO: Google Sign-Up */},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GoogleIcon(),
                    const SizedBox(width: 8),
                    const Text('Google',
                        style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                onPressed: () {/* TODO: Apple Sign-Up */},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple, size: 22, color: AppColors.onSurface),
                    SizedBox(width: 8),
                    Text('Apple',
                        style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Lien connexion ──
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Déjà un compte? ',
                  style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6)),
              GestureDetector(
                onTap: () {
                  // TODO: navigation vers connexion
                  Navigator.of(context).pop();
                },
                child: const Text('Se connecter',
                    style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Widgets utilitaires
// ─────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          fontFamily: 'HankenGrotesk', fontSize: 16, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: AppColors.outlineVariant,
            fontFamily: 'HankenGrotesk',
            fontSize: 16),
        prefixIcon: Icon(prefixIcon, color: AppColors.outline, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

// ── Sélecteur de pays (modal bottom sheet) ──
class _CountryPickerField extends StatelessWidget {
  final RegisterController controller;
  const _CountryPickerField({required this.controller});

  static const _countries = [
    {'name': 'Togo', 'dial': '+228', 'flag': '🇹🇬'},
    {'name': 'Bénin', 'dial': '+229', 'flag': '🇧🇯'},
    {'name': 'Côte d\'Ivoire', 'dial': '+225', 'flag': '🇨🇮'},
    {'name': 'Sénégal', 'dial': '+221', 'flag': '🇸🇳'},
    {'name': 'Cameroun', 'dial': '+237', 'flag': '🇨🇲'},
    {'name': 'Mali', 'dial': '+223', 'flag': '🇲🇱'},
    {'name': 'Burkina Faso', 'dial': '+226', 'flag': '🇧🇫'},
    {'name': 'Niger', 'dial': '+227', 'flag': '🇳🇪'},
    {'name': 'Ghana', 'dial': '+233', 'flag': '🇬🇭'},
    {'name': 'Nigeria', 'dial': '+234', 'flag': '🇳🇬'},
    {'name': 'France', 'dial': '+33', 'flag': '🇫🇷'},
  ];

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _countries.length,
        itemBuilder: (ctx, i) {
          final c = _countries[i];
          return ListTile(
            leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(c['name']!,
                style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 16,
                    color: AppColors.onSurface)),
            trailing: Text(c['dial']!,
                style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant)),
            onTap: () {
              controller.selectCountry(
                  country: c['name']!,
                  dialCode: c['dial']!,
                  flag: c['flag']!);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.outline, size: 22),
            const SizedBox(width: 12),
            Text(controller.selectedFlag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.selectedCountry,
                style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 16,
                    color: AppColors.onSurface),
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.outline, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Champ téléphone avec indicatif ──
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final RegisterController registerController;

  const _PhoneField({
    required this.controller,
    required this.registerController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          // Indicatif pays
          GestureDetector(
            onTap: () {
              // Le changement de pays via le champ pays met aussi à jour l'indicatif
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(registerController.selectedFlag,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    registerController.selectedDialCode,
                    style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 15,
                        color: AppColors.onSurface),
                  ),
                  const Icon(Icons.expand_more,
                      color: AppColors.outline, size: 18),
                ],
              ),
            ),
          ),
          // Champ numéro
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 16,
                  color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: '00 00 00 00',
                hintStyle: TextStyle(
                    color: AppColors.outlineVariant,
                    fontFamily: 'HankenGrotesk',
                    fontSize: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Numéro requis' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton social ──
class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const _SocialButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
        ),
        child: child,
      ),
    );
  }
}

// ── Icône Google (CustomPainter) ──
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _GoogleIconPainter());
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.scale(size.width / 24, size.height / 24);

    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
        Path()
          ..moveTo(22.56, 12.25)
          ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10)
          ..lineTo(12, 10)
          ..lineTo(12, 14.26)
          ..lineTo(17.92, 14.26)
          ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
          ..lineTo(15.71, 20.34)
          ..lineTo(19.28, 20.34)
          ..cubicTo(21.36, 18.42, 22.56, 15.60, 22.56, 12.25)
          ..close(),
        paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
        Path()
          ..moveTo(12, 23)
          ..cubicTo(14.97, 23, 17.46, 22.02, 19.28, 20.34)
          ..lineTo(15.71, 17.57)
          ..cubicTo(14.73, 18.23, 13.48, 18.63, 12, 18.63)
          ..cubicTo(9.14, 18.63, 6.71, 16.70, 5.84, 14.10)
          ..lineTo(2.18, 14.10)
          ..lineTo(2.18, 16.94)
          ..cubicTo(3.99, 20.53, 7.70, 23, 12, 23)
          ..close(),
        paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
        Path()
          ..moveTo(5.84, 14.09)
          ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12)
          ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
          ..lineTo(5.84, 7.07)
          ..lineTo(2.18, 7.07)
          ..cubicTo(1.43, 8.55, 1, 10.22, 1, 12)
          ..cubicTo(1, 13.78, 1.43, 15.45, 2.18, 16.93)
          ..lineTo(5.84, 14.09)
          ..close(),
        paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
        Path()
          ..moveTo(12, 5.38)
          ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
          ..lineTo(19.36, 3.87)
          ..cubicTo(17.45, 2.09, 14.97, 1, 12, 1)
          ..cubicTo(7.70, 1, 3.99, 3.47, 2.18, 7.07)
          ..lineTo(5.84, 9.91)
          ..cubicTo(6.71, 7.31, 9.14, 5.38, 12, 5.38)
          ..close(),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Placeholder repository
// ─────────────────────────────────────────────
class _PlaceholderAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    throw Exception('API Laravel non connectée');
  }

  @override
  Future<UserEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    throw Exception('API Laravel non connectée');
  }
}
