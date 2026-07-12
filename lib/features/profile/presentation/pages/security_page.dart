import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/security_controller.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _formKey = GlobalKey<FormState>();
  late final SecurityController _controller;

  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = 'Aucun';
  Color _passwordStrengthColor = AppColors.outline;

  @override
  void initState() {
    super.initState();
    _controller = SecurityController(
      changePasswordUseCase: ServiceLocator.instance.changePasswordUseCase,
      toggle2FAUseCase: ServiceLocator.instance.toggle2FAUseCase,
    );

    _newPasswordCtrl.addListener(_updatePasswordStrength);

    _controller.addListener(() {
      if (_controller.status == SecurityStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action réussie avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _oldPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _newPasswordCtrl.removeListener(_updatePasswordStrength);
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final pass = _newPasswordCtrl.text;
    double strength = 0.0;
    String label = 'Aucun';
    Color color = AppColors.outline;

    if (pass.isNotEmpty) {
      strength = (pass.length * 10).clamp(0, 100) / 100.0;
      if (pass.length < 6) {
        label = 'Très faible';
        color = AppColors.error;
      } else if (pass.length < 10) {
        label = 'Moyen';
        color = Colors.orange;
      } else {
        label = 'Fort';
        color = Colors.green;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  void _onChangePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.changePassword(
        oldPassword: _oldPasswordCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );
    }
  }

  IconData _getDeviceIcon(String device) {
    final dev = device.toLowerCase();
    if (dev.contains('iphone') || dev.contains('phone')) {
      return Icons.smartphone_rounded;
    } else if (dev.contains('mac') || dev.contains('laptop')) {
      return Icons.laptop_mac_rounded;
    } else if (dev.contains('ipad') || dev.contains('tablet')) {
      return Icons.tablet_mac_rounded;
    }
    return Icons.devices_other_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Sécurité',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final isLoading = _controller.status == SecurityStatus.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── SECTION 1: Mot de passe ──
                _buildCardSection(
                  icon: Icons.lock_outline_rounded,
                  title: 'Mot de passe',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('ANCIEN MOT DE PASSE'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _oldPasswordCtrl,
                          hint: '••••••••',
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('NOUVEAU MOT DE PASSE'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _newPasswordCtrl,
                          hint: '••••••••',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (v.length < 6) return 'Minimum 6 caractères';
                            return null;
                          },
                        ),
                        if (_newPasswordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: AppColors.surfaceContainer,
                              color: _passwordStrengthColor,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Force du mot de passe : $_passwordStrengthLabel',
                            style: TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _passwordStrengthColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const _FieldLabel('CONFIRMER LE NOUVEAU MOT DE PASSE'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _confirmPasswordCtrl,
                          hint: '••••••••',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (v != _newPasswordCtrl.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_controller.status == SecurityStatus.failure && _controller.errorMessage != null) ...[
                          Text(
                            _controller.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _onChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryContainer,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text(
                                          'Valider',
                                          style: TextStyle(
                                            fontFamily: 'HankenGrotesk',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _oldPasswordCtrl.clear();
                                    _newPasswordCtrl.clear();
                                    _confirmPasswordCtrl.clear();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.outlineVariant),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontFamily: 'HankenGrotesk',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── SECTION 2: Double authentification ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Double authentification',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _controller.is2faEnabled,
                            onChanged: (val) {
                              _controller.toggle2FA(val);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ajoutez une couche de sécurité supplémentaire à votre compte.',
                        style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (_controller.is2faEnabled) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFECEEF0)),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                                ),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD_vuMLtRUG3-AuKtSZXzrRi2QuU6sTpOJZT-l1ehrENgb2WOxtkxR5f4240a6qK6ccFsBep4lQliZQf7Lt-F15asSCzALEYss7ElObMZxVIIzjJAfQcHzM-LPxBaldiwk29d5HSWh6zt059hRSSzDZHLqg_xjJPNzyGErGII7RcGHSSmJwW12KkdMXgFHAy3CMxBlc8NBb7SWzuntKm4hxLRr44J7hIvapkr9eciVlL-mzrRJuLeGmuHyiuihmz0yqDVPh7hMs_u8',
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Scannez ce code avec votre application d\'authentification (Google Authenticator, Authy, etc.)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'HankenGrotesk',
                                  fontSize: 12,
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── SECTION 3: Sessions actives ──
                _buildCardSection(
                  icon: Icons.devices_rounded,
                  title: 'Sessions actives',
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFECEEF0)),
                    itemBuilder: (context, index) {
                      final session = _controller.sessions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD6E3FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getDeviceIcon(session.device),
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.device,
                                    style: const TextStyle(
                                      fontFamily: 'HankenGrotesk',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${session.location} • ${session.lastActive}',
                                    style: const TextStyle(
                                      fontFamily: 'HankenGrotesk',
                                      fontSize: 12,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!session.isCurrent)
                              TextButton(
                                onPressed: () => _controller.disconnectSession(session),
                                child: const Text(
                                  'Déconnecter',
                                  style: TextStyle(
                                    fontFamily: 'HankenGrotesk',
                                    fontSize: 13,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.outline,
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 16,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.outlineVariant),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.outline,
            size: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
