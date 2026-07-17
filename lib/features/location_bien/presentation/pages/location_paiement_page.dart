import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import 'location_confirmation_page.dart';

/// Étape 3 du tunnel — Sélection de l'opérateur et paiement.
class LocationPaiementPage extends StatefulWidget {
  final PropertyEntity property;
  final LocationController controller;

  const LocationPaiementPage({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<LocationPaiementPage> createState() => _LocationPaiementPageState();
}

class _LocationPaiementPageState extends State<LocationPaiementPage> {
  static const _operateurs = [
    _Operateur(
      id: 'orange_money',
      label: 'Orange Money',
      color: Color(0xFFFF6B00),
      icon: Icons.phone_android_rounded,
    ),
    _Operateur(
      id: 'wave',
      label: 'Wave',
      color: Color(0xFF1A9BF0),
      icon: Icons.waves_rounded,
    ),
    _Operateur(
      id: 'mtn_momo',
      label: 'MTN MoMo',
      color: Color(0xFFFFCC00),
      icon: Icons.phone_android_rounded,
    ),
    _Operateur(
      id: 'moov_money',
      label: 'Moov Money',
      color: Color(0xFF0066CC),
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  LocationController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;
    if (_ctrl.step == LocationStep.confirmation &&
        _ctrl.status == LocationStatus.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LocationConfirmationPage(
            property: widget.property,
            controller: _ctrl,
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _payer() async {
    if (_ctrl.operateur.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez choisir un opérateur de paiement.',
            style: TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _ctrl.payer();
    if (_ctrl.status == LocationStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ctrl.errorMessage ?? 'Erreur',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatMontant(double v) {
    final digits = v.toInt().toString().split('');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u202F');
      buf.write(digits[i]);
    }
    return '${buf.toString()} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final montant = _ctrl.location?.montantTotal ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paiement',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choisissez votre opérateur de paiement.',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Résumé du montant
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MONTANT À PAYER',
                            style: TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatMontant(montant),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_ctrl.dureeMois} mois × ${_formatMontant(montant / (_ctrl.dureeMois > 0 ? _ctrl.dureeMois : 1))}/mois',
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Opérateur de paiement',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grille opérateurs
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: _operateurs
                          .map((op) => _buildOperateurCard(op))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Note sécurité
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF388E3C).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              size: 18, color: Color(0xFF388E3C)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Paiement sécurisé. Vos données ne sont jamais stockées.',
                              style: TextStyle(
                                fontFamily: 'HankenGrotesk',
                                fontSize: 13,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(montant, bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildOperateurCard(_Operateur op) {
    final selected = _ctrl.operateur == op.id;
    return GestureDetector(
      onTap: () => _ctrl.setOperateur(op.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? op.color.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? op.color : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: op.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(op.icon, color: op.color, size: 22),
            const SizedBox(width: 8),
            Text(
              op.label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? op.color : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'Paiement',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
            flex: 3, child: Container(height: 4, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildBottomBar(double montant, double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: Border(
          top:
              BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _ctrl.isLoading ? null : _payer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _ctrl.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Payer ${_formatMontant(montant)}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Operateur {
  final String id;
  final String label;
  final Color color;
  final IconData icon;

  const _Operateur({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });
}
