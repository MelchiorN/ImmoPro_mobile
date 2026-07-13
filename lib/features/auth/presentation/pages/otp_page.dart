import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../controllers/otp_controller.dart';
import '../../../home/presentation/pages/home_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _digitCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late final OtpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OtpController(
      verifyOtpUseCase: ServiceLocator.instance.verifyOtpUseCase,
      resendOtpUseCase: ServiceLocator.instance.resendOtpUseCase,
      email: widget.email,
    );

    // Listener pour naviguer vers la page d'accueil après validation
    _controller.addListener(() {
      if (_controller.status == OtpStatus.success) {
        // Navigation vers HomePage après succès
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });

    // Focus auto sur la première case
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in _digitCtrls) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _controller.dispose();
    super.dispose();
  }

  String get _otpValue => _digitCtrls.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpValue.length == 6) {
      _focusNodes[index].unfocus();
      _controller.verify(_otpValue);
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onVerify() => _controller.verify(_otpValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── AppBar ──
                _OtpAppBar(),
                // ── Corps scrollable ──
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
                      child: Column(
                        children: [
                          // Icône mail dans cercle
                          _MailIconBadge(),
                          const SizedBox(height: 32),

                          // Titre + description
                          _TextCluster(email: widget.email),
                          const SizedBox(height: 40),

                          // Cases OTP
                          _OtpInputRow(
                            digitCtrls: _digitCtrls,
                            focusNodes: _focusNodes,
                            onDigitChanged: _onDigitChanged,
                            onKeyEvent: _onKeyEvent,
                          ),
                          const SizedBox(height: 40),

                          // Bouton Vérifier
                          _VerifyButton(
                            controller: _controller,
                            onVerify: _onVerify,
                          ),
                          const SizedBox(height: 24),

                          // Renvoyer code + timer
                          _ResendSection(controller: _controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Dégradé en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 128,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.surfaceContainerLow.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AppBar : flèche retour uniquement
// ─────────────────────────────────────────────
class _OtpAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Badge icône mail dans un cercle tonal
// ─────────────────────────────────────────────
class _MailIconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFD6E3FF), // primary-fixed
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.mail_rounded,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Titre + description
// ─────────────────────────────────────────────
class _TextCluster extends StatelessWidget {
  final String email;
  const _TextCluster({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Vérification de l\'e-mail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nous avons envoyé un code de vérification à 6 chiffres à votre adresse e-mail. Veuillez le saisir ci-dessous.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.outline,
              height: 1.6,
            ),
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 6 cases OTP  (w:40, h:80 comme le HTML)
// ─────────────────────────────────────────────
class _OtpInputRow extends StatelessWidget {
  final List<TextEditingController> digitCtrls;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onDigitChanged;
  final void Function(int, KeyEvent) onKeyEvent;

  const _OtpInputRow({
    required this.digitCtrls,
    required this.focusNodes,
    required this.onDigitChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    // Largeur totale disponible → 6 cases + 5 gaps de 8px
    final totalGap = 5 * 8.0;
    final cellWidth =
        (MediaQuery.of(context).size.width - 40 - totalGap) / 6;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: cellWidth,
          height: 80,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => onKeyEvent(i, e),
            child: TextFormField(
              controller: digitCtrls[i],
              focusNode: focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (v) => onDigitChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Bouton Vérifier
// ─────────────────────────────────────────────
class _VerifyButton extends StatelessWidget {
  final OtpController controller;
  final VoidCallback onVerify;

  const _VerifyButton({required this.controller, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.status == OtpStatus.loading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'Vérifier',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section "Renvoyer le code" + timer
// ─────────────────────────────────────────────
class _ResendSection extends StatelessWidget {
  final OtpController controller;
  const _ResendSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Nous avons envoyé un code de vérification à 6 chiffres à votre adresse e-mail. Veuillez le saisir ci-dessous.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.outline,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.canResend ? controller.resend : null,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Renvoyer le code ',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: controller.canResend
                        ? AppColors.primary
                        : AppColors.outline,
                  ),
                ),
                if (!controller.canResend)
                  TextSpan(
                    text: '(${controller.secondsLeft}s)',
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.outline,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Message d'erreur éventuel
        if (controller.status == OtpStatus.failure &&
            controller.errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ],
      ],
    );
  }
}

// ── Fin du fichier ──
