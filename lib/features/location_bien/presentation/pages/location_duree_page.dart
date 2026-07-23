import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import 'location_contrat_page.dart';

/// Étape 1 du tunnel de location — Sélection de la date et de la durée.
class LocationDureePage extends StatefulWidget {
  final PropertyEntity property;
  final LocationController controller;

  const LocationDureePage({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<LocationDureePage> createState() => _LocationDureePageState();
}

class _LocationDureePageState extends State<LocationDureePage> {
  LocationController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  // ── Ouvrir le date picker ─────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _ctrl.dateDebut,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _ctrl.setDateDebut(picked);
    }
  }

  // ── Continuer → appel API puis navigation directe ─────────────────────────

  Future<void> _continuer() async {
    await _ctrl.initierLocation(widget.property.id);

    if (!mounted) return;

    if (_ctrl.status == LocationStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ctrl.errorMessage ?? 'Une erreur est survenue.',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Succès → navigation directe, pas besoin du listener
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationContratPage(
          property: widget.property,
          controller: _ctrl,
        ),
      ),
    );
  }

  // ── Formatage ─────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
    final total = _ctrl.totalEstime(widget.property.price);
    final fin = _ctrl.dateFin;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _ctrl.annulerLocationSilencieux();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
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
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: _buildForm(fin, total),
              ),
            ),
            _buildBottomBar(total, bottomPad),
          ],
        ),
      ),
    )));
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
            'Louer ce bien',
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

  // ── Indicateur de progression (étape 1/3) ─────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _ProgressStep(label: 'Informations', active: true, done: false),
          _ProgressConnector(active: false),
          _ProgressStep(label: 'Contrat', active: false, done: false),
          _ProgressConnector(active: false),
          _ProgressStep(label: 'Paiement', active: false, done: false),
        ],
      ),
    );
  }

  // ── Formulaire principal ──────────────────────────────────────────────────

  Widget _buildForm(DateTime fin, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          const Text(
            'Détails de la location',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.property.title,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // ── Date de début ───────────────────────────────────────────────
          const _FieldLabel(text: 'Date de début'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fmtDate(_ctrl.dateDebut),
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Durée ────────────────────────────────────────────────────────
          const _FieldLabel(text: 'Durée de la location (mois)'),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant),
              color: Colors.white,
            ),
            child: Row(
              children: [
                _StepperBtn(
                  icon: Icons.remove,
                  enabled: _ctrl.dureeMois > 1,
                  onTap: () => _ctrl.setDuree(_ctrl.dureeMois - 1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_ctrl.dureeMois}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                _StepperBtn(
                  icon: Icons.add,
                  enabled: _ctrl.dureeMois < 36,
                  onTap: () => _ctrl.setDuree(_ctrl.dureeMois + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Durée minimale : 1 mois  ·  Maximum : 36 mois',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // ── Récapitulatif ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                _RecapRow(
                  label: 'Date de fin estimée',
                  value: _fmtDate(fin),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.outlineVariant),
                const SizedBox(height: 10),
                _RecapRow(
                  label: 'Loyer mensuel',
                  value: _fmtMontant(widget.property.price),
                ),
                const SizedBox(height: 8),
                _RecapRow(
                  label: 'Total à payer',
                  value: _fmtMontant(total),
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre bas ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double total, double bottomPad) {
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
      child: Row(
        children: [
          // Total à gauche
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TOTAL ESTIMÉ',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmtMontant(total),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Continuer
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _ctrl.isLoading ? null : _continuer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28),
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
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continuer',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 56,
        height: double.infinity,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.07)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.outline,
          size: 22,
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _RecapRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: highlight ? 15 : 13,
            fontWeight:
                highlight ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: highlight ? 20 : 13,
            fontWeight:
                highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool active;
  final bool done;

  const _ProgressStep({
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: (active || done) ? AppColors.primary : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  (active || done) ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressConnector extends StatelessWidget {
  final bool active;
  const _ProgressConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            color: active ? AppColors.primary : AppColors.outlineVariant,
          ),
          const SizedBox(height: 4 + 10 + 4), // aligne avec le texte en dessous
        ],
      ),
    );
  }
}
