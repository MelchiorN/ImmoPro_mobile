import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import 'location_paiement_page.dart';

/// Étape 2 du tunnel — Consultation et acceptation du contrat.
class LocationContratPage extends StatefulWidget {
  final PropertyEntity property;
  final LocationController controller;

  const LocationContratPage({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<LocationContratPage> createState() => _LocationContratPageState();
}

class _LocationContratPageState extends State<LocationContratPage> {
  bool _lu = false;

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
    if (_ctrl.step == LocationStep.paiement && _ctrl.status == LocationStatus.success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LocationPaiementPage(
            property: widget.property,
            controller: _ctrl,
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _accepter() async {
    if (!_lu) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez lire le contrat avant d\'accepter.',
            style: TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _ctrl.accepterContrat();
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final contenu = _ctrl.contrat?.contenuHtml ?? '';

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
                      'Contrat de location',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lisez attentivement le contrat avant d\'accepter.',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Corps du contrat
                    NotificationListener<ScrollNotification>(
                      onNotification: (notif) {
                        if (notif is ScrollEndNotification &&
                            notif.metrics.atEdge &&
                            notif.metrics.pixels > 0) {
                          setState(() => _lu = true);
                        }
                        return false;
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 420),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: contenu.isNotEmpty
                              ? Text(
                                  contenu,
                                  style: const TextStyle(
                                    fontFamily: 'HankenGrotesk',
                                    fontSize: 14,
                                    height: 1.7,
                                    color: AppColors.onSurface,
                                  ),
                                )
                              : _buildContratPlaceholder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Checkbox lecture
                    GestureDetector(
                      onTap: () => setState(() => _lu = !_lu),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _lu
                              ? const Color(0xFFE8F5E9)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _lu
                                ? const Color(0xFF388E3C)
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _lu
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: _lu
                                  ? const Color(0xFF388E3C)
                                  : AppColors.outline,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'J\'ai lu et j\'accepte les termes du contrat de location.',
                                style: TextStyle(
                                  fontFamily: 'HankenGrotesk',
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(bottomPad),
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
            'Contrat de location',
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
        Expanded(flex: 2, child: Container(height: 4, color: AppColors.primary)),
        Expanded(flex: 1, child: Container(height: 4, color: AppColors.outlineVariant)),
      ],
    );
  }

  Widget _buildContratPlaceholder() {
    final loc = _ctrl.location;
    if (loc == null) return const SizedBox.shrink();

    final debut = loc.dateDebut;
    final fin = loc.dateFin;

    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTRAT DE LOCATION',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _ligne('Bien :', widget.property.title),
        _ligne('Adresse :', widget.property.location),
        _ligne('Durée :', '${loc.dureeMois} mois'),
        _ligne('Date de début :', fmt(debut)),
        _ligne('Date de fin :', fmt(fin)),
        _ligne('Loyer mensuel :', '${loc.prixProprietaire.toInt()} FCFA'),
        _ligne('Total :', '${loc.montantTotal.toInt()} FCFA'),
        const SizedBox(height: 20),
        const Text(
          'Le locataire s\'engage à payer le loyer mensuel à la date convenue et à '
          'respecter les obligations du présent contrat. Le propriétaire s\'engage '
          'à mettre à disposition le bien dans l\'état décrit.',
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _ligne(String titre, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titre,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
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
          onPressed: (_ctrl.isLoading || !_lu) ? null : _accepter,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.outlineVariant,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Accepter et continuer',
                      style: TextStyle(
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
