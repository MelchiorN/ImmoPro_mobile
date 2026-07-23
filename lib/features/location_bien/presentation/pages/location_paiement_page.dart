import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import '../widgets/location_progress_indicator.dart';
import 'location_confirmation_page.dart';

/// Étape 3 du tunnel — Sélection du moyen de paiement et initiation via Semoa.
///
/// Deux catégories :
///   • Mobile Money → T-Money (Togo Cellulaire) / Flooz (Moov Africa)
///   • Carte bancaire / prépayée → CARD
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

class _LocationPaiementPageState extends State<LocationPaiementPage>
    with SingleTickerProviderStateMixin {
  // ── Catégories & opérateurs ─────────────────────────────────────────────
  static const _categories = [
    _PayCategory(
      id: 'mobile_money',
      label: 'Mobile Money',
      icon: Icons.phone_android_rounded,
      operators: [
        _Operateur(
          id: 'TMONEY',
          label: 'T-Money',
          subtitle: 'Togo Cellulaire',
          color: Color(0xFF009E4D),
          icon: Icons.phone_android_rounded,
        ),
        _Operateur(
          id: 'FLOOZ',
          label: 'Flooz',
          subtitle: 'Moov Africa',
          color: Color(0xFF0066CC),
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    ),
    _PayCategory(
      id: 'card',
      label: 'Carte Bancaire / Prépayée',
      icon: Icons.credit_card_rounded,
      operators: [
        _Operateur(
          id: 'CARD',
          label: 'Carte Bancaire',
          subtitle: 'Visa, Mastercard, Prépayée',
          color: Color(0xFF1A237E),
          icon: Icons.credit_card_rounded,
        ),
      ],
    ),
  ];

  late TabController _tabCtrl;
  LocationController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _ctrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _ctrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  // ── Payer ────────────────────────────────────────────────────────────────

  Future<void> _payer() async {
    if (_ctrl.operateur.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez choisir un moyen de paiement.',
            style: TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isMobileMoney = _ctrl.operateur == 'TMONEY' || _ctrl.operateur == 'FLOOZ';
    final telClean = _ctrl.telephone.trim().replaceAll(' ', '');

    if (isMobileMoney) {
      if (telClean.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez saisir votre numéro ${_ctrl.operateur == 'TMONEY' ? 'T-Money' : 'Flooz'} pour continuer.',
              style: const TextStyle(fontFamily: 'HankenGrotesk'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final digitsOnly = telClean.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez saisir un numéro de téléphone valide (au moins 8 chiffres).',
              style: TextStyle(fontFamily: 'HankenGrotesk'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    await _ctrl.payer();

    if (!mounted) return;

    if (_ctrl.status == LocationStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ctrl.errorMessage ?? 'Erreur lors du paiement.',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LocationConfirmationPage(
          property: widget.property,
          controller: _ctrl,
        ),
      ),
    );
  }

  String _fmtMontant(double v) {
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Résumé montant ──────────────────────────────────
                    _buildMontantCard(montant),
                    const SizedBox(height: 24),

                    // ── Titre ────────────────────────────────────────────
                    const Text(
                      'Moyen de paiement',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choisissez comment payer votre location.',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Onglets catégories ──────────────────────────────
                    _buildCategoryTabs(),
                    const SizedBox(height: 16),

                    // ── Contenu onglet actif ────────────────────────────
                    _buildTabContent(),
                    const SizedBox(height: 20),

                    // ── Note sécurité ───────────────────────────────────
                    _buildSecurityNote(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(montant, bottomPad),
          ],
        ),
      ),
    ));
  }

  // ── Carte montant ────────────────────────────────────────────────────────

  Widget _buildMontantCard(double montant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            _fmtMontant(montant),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_ctrl.dureeMois} mois × ${_fmtMontant(montant / (_ctrl.dureeMois > 0 ? _ctrl.dureeMois : 1))}/mois',
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ── Onglets catégories (Mobile Money / Carte) ───────────────────────────

  Widget _buildCategoryTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        onTap: (_) => setState(() {}),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerHeight: 0,
        tabs: _categories
            .map((c) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          c.label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Contenu onglet ──────────────────────────────────────────────────────

  Widget _buildTabContent() {
    final cat = _categories[_tabCtrl.index];
    final isMobileMoney = cat.id == 'mobile_money';

    return Column(
      children: [
        ...cat.operators.map((op) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOperateurCard(op),
            )),
        if (isMobileMoney && _ctrl.operateur.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildTelephoneInputField(),
        ],
      ],
    );
  }

  // ── Champ de saisie du téléphone (Mobile Money) ──────────────────────────

  Widget _buildTelephoneInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Numéro ${_ctrl.operateur == 'TMONEY' ? 'T-Money' : 'Flooz'}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Entrez le numéro qui recevra la notification de validation USSD.',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _ctrl.telephone,
            keyboardType: TextInputType.phone,
            onChanged: (val) => _ctrl.setTelephone(val),
            decoration: InputDecoration(
              hintText: 'ex: 90 12 34 56',
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text(
                  '+228',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte opérateur ────────────────────────────────────────────────────

  Widget _buildOperateurCard(_Operateur op) {
    final selected = _ctrl.operateur == op.id;
    return GestureDetector(
      onTap: () => _ctrl.setOperateur(op.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? op.color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? op.color : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: op.color.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icône dans un cercle coloré
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: op.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(op.icon, color: op.color, size: 24),
            ),
            const SizedBox(width: 14),
            // Label et sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    op.label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? op.color : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    op.subtitle,
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      color: selected
                          ? op.color.withValues(alpha: 0.7)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? op.color : AppColors.outlineVariant,
                  width: 2,
                ),
                color: selected ? op.color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Note sécurité ───────────────────────────────────────────────────────

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF388E3C).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF388E3C)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Paiement sécurisé via Semoa CashPay — vos données ne sont jamais stockées.',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

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
            'Paiement de la location',
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

  // ── Indicateur de progression étape 3/3 ──────────────────────────────────

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          LocationProgStep(
              label: 'Informations', state: LocationStepState.done),
          LocationProgConnector(active: true),
          LocationProgStep(label: 'Contrat', state: LocationStepState.done),
          LocationProgConnector(active: true),
          LocationProgStep(label: 'Paiement', state: LocationStepState.active),
        ],
      ),
    );
  }

  // ── Barre bas ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double montant, double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.4)),
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
                      'Payer ${_fmtMontant(montant)}',
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

// ── Modèles privés ────────────────────────────────────────────────────────

class _PayCategory {
  final String id;
  final String label;
  final IconData icon;
  final List<_Operateur> operators;

  const _PayCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.operators,
  });
}

class _Operateur {
  final String id;
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _Operateur({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
