import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';

/// Étape 4 — Confirmation du paiement et affichage du reçu.
class LocationConfirmationPage extends StatelessWidget {
  final PropertyEntity property;
  final LocationController controller;

  const LocationConfirmationPage({
    super.key,
    required this.property,
    required this.controller,
  });

  String _formatMontant(double v) {
    final digits = v.toInt().toString().split('');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u202F');
      buf.write(digits[i]);
    }
    return '${buf.toString()} FCFA';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final recu = controller.recu;
    final loc = controller.location;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar minimal
            Container(
              height: 56,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirmation',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Barre complète
            Container(height: 4, color: AppColors.primary),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Icône succès animée
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF388E3C),
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Location confirmée !',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre paiement a été traité avec succès. Vous recevrez une notification de confirmation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Carte reçu
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                AppColors.outlineVariant.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // En-tête reçu
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long_rounded,
                                    color: AppColors.primary, size: 24),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reçu de paiement',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (recu != null)
                                      Text(
                                        recu.numeroRecu,
                                        style: const TextStyle(
                                          fontFamily: 'HankenGrotesk',
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Détails
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _RecuLigne(
                                    label: 'Bien',
                                    valeur: property.title),
                                _RecuLigne(
                                    label: 'Adresse',
                                    valeur: property.location),
                                if (loc != null) ...[
                                  _RecuLigne(
                                    label: 'Durée',
                                    valeur: '${loc.dureeMois} mois',
                                  ),
                                  _RecuLigne(
                                    label: 'Début',
                                    valeur: _fmtDate(loc.dateDebut),
                                  ),
                                  _RecuLigne(
                                    label: 'Fin',
                                    valeur: _fmtDate(loc.dateFin),
                                  ),
                                ],
                                if (recu != null)
                                  _RecuLigne(
                                    label: 'Opérateur',
                                    valeur: recu.operateurPaiement
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                  ),
                                const SizedBox(height: 12),
                                const Divider(
                                    height: 1,
                                    color: AppColors.outlineVariant),
                                const SizedBox(height: 12),
                                if (recu != null)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL PAYÉ',
                                        style: TextStyle(
                                          fontFamily: 'HankenGrotesk',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        _formatMontant(recu.montant),
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bouton retour à l'accueil
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                border: Border(
                  top: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Retour à la racine (accueil)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

class _RecuLigne extends StatelessWidget {
  final String label;
  final String valeur;
  const _RecuLigne({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
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
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
