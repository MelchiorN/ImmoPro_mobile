import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import '../../domain/entities/location_entity.dart';

/// Étape 4 — Confirmation ou Attente de paiement, et téléchargement des documents (Contrat et Reçu PDF).
class LocationConfirmationPage extends StatefulWidget {
  final PropertyEntity property;
  final LocationController controller;

  const LocationConfirmationPage({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<LocationConfirmationPage> createState() =>
      _LocationConfirmationPageState();
}

class _LocationConfirmationPageState extends State<LocationConfirmationPage> {
  bool _isChecking = false;
  bool _isDownloadingContrat = false;
  bool _isDownloadingRecu = false;

  LocationController get _ctrl => widget.controller;

  // ── Vérification du paiement ──────────────────────────────────────────────

  Future<void> _verifierStatut() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    final success = await _ctrl.verifierPaiement();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎉 Paiement confirmé avec succès ! Reçu et contrat disponibles.',
            style: TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ctrl.errorMessage ??
                'Paiement toujours en attente. Veuillez valider sur votre téléphone.',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Ouvrir le portail de paiement (Cartes bancaires) ─────────────────────────

  Future<void> _lancerUrlPaiement(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir l\'URL de paiement.';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Téléchargement de fichiers PDF ────────────────────────────────────────

  Future<void> _telechargerFichier({
    required String endpointPath,
    required String prefixNom,
    required Function(bool) setDownloading,
  }) async {
    final locationId = _ctrl.location?.id;
    if (locationId == null || locationId.isEmpty) return;

    setDownloading(true);

    try {
      final token = await ApiClient.instance.getToken();
      final uri = Uri.parse('${ApiClient.instance.baseUrl}$endpointPath');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf, application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Serveur indisponible ou document en cours de traitement (${response.statusCode})');
      }

      Directory? dir;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          dir = downloadDir;
        } else {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final targetDir = dir ?? await getApplicationDocumentsDirectory();
      final fileName = '${prefixNom}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${targetDir.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📄 Document PDF enregistré avec succès !\nChemin : ${file.path}',
            style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de téléchargement : ${e.toString().replaceAll('Exception: ', '')}',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setDownloading(false);
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isConfirmed = _ctrl.recu != null || _ctrl.location?.statut == LocationStatut.actif;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar minimal
            Container(
              height: 56,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConfirmed ? 'Confirmation' : 'Paiement initié',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 4,
              color: AppColors.primary,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Icône statut animée
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? const Color(0xFF388E3C).withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConfirmed
                            ? Icons.check_circle_rounded
                            : Icons.pending_rounded,
                        color: isConfirmed
                            ? const Color(0xFF388E3C)
                            : AppColors.primary,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      isConfirmed ? 'Location confirmée !' : 'Paiement initié !',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isConfirmed
                            ? AppColors.onSurface
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      isConfirmed
                          ? 'Votre contrat de location et votre reçu de paiement ont été validés. Vous pouvez désormais les télécharger ci-dessous.'
                          : 'Votre demande de paiement a été envoyée avec succès via Semoa. Veuillez valider la transaction pour activer votre location.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions si non confirmé
                    if (!isConfirmed && _ctrl.paiementSemoa != null)
                      _buildInstructionsCard(_ctrl.paiementSemoa!),

                    if (isConfirmed) ...[
                      // Carte reçu
                      _buildReceiptCard(),
                      const SizedBox(height: 20),
                      // Téléchargement documents
                      _buildDownloadDocsSection(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Boutons d'action au bas
            _buildBottomActionSection(bottomPad, isConfirmed),
          ],
        ),
      ),
    ));
  }

  // ── Instructions de paiement (Mobile money / Carte) ───────────────────────────

  Widget _buildInstructionsCard(PaiementSemoaEntity payment) {
    final isCard = payment.operateur == 'CARD';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCard ? Icons.credit_card_rounded : Icons.phone_android_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                isCard ? 'Paiement par Carte' : 'Instructions ${payment.operateur}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            payment.instructions,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          if (isCard && payment.paymentUrl != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _lancerUrlPaiement(payment.paymentUrl!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text(
                  'Accéder à la page de paiement',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Carte Reçu de paiement ───────────────────────────────────────────────

  Widget _buildReceiptCard() {
    final recu = _ctrl.recu;
    final loc = _ctrl.location;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails du reçu de paiement',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RecuLigne(label: 'Bien loué', valeur: widget.property.title),
                _RecuLigne(label: 'Adresse', valeur: widget.property.location),
                if (loc != null) ...[
                  _RecuLigne(label: 'Durée contrat', valeur: '${loc.dureeMois} mois'),
                  _RecuLigne(label: 'Date de début', valeur: _fmtDate(loc.dateDebut)),
                  _RecuLigne(label: 'Date de fin', valeur: _fmtDate(loc.dateFin)),
                ],
                if (recu != null) ...[
                  _RecuLigne(
                    label: 'Opérateur',
                    valeur: recu.operateurPaiement.toUpperCase(),
                  ),
                  _RecuLigne(
                    label: 'Date de paiement',
                    valeur: _fmtDate(recu.dateEmission),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.outlineVariant),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      _formatMontant(recu?.montant ?? loc?.montantTotal ?? 0),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
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
    );
  }

  // ── Section de Téléchargement ─────────────────────────────────────────────

  Widget _buildDownloadDocsSection() {
    final locationId = _ctrl.location?.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Télécharger vos documents officiels',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Télécharger le contrat
          _buildDownloadButton(
            label: 'Télécharger le Contrat de Bail (PDF)',
            isDownloading: _isDownloadingContrat,
            onTap: () => _telechargerFichier(
              endpointPath: '/mobile/locations/$locationId/contrat/telecharger',
              prefixNom: 'Contrat_Bail_ImmoPro',
              setDownloading: (val) => setState(() => _isDownloadingContrat = val),
            ),
          ),
          const SizedBox(height: 8),
          // Télécharger le reçu
          _buildDownloadButton(
            label: 'Télécharger le Reçu de Paiement (PDF)',
            isDownloading: _isDownloadingRecu,
            onTap: () => _telechargerFichier(
              endpointPath: '/mobile/locations/$locationId/recu/telecharger',
              prefixNom: 'Recu_Paiement_ImmoPro',
              setDownloading: (val) => setState(() => _isDownloadingRecu = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required bool isDownloading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isDownloading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              color: isDownloading ? Colors.grey : Colors.red[800],
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDownloading ? Colors.grey : AppColors.onSurface,
                ),
              ),
            ),
            if (isDownloading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              const Icon(Icons.download_rounded, size: 18, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ── Barre de boutons d'action ─────────────────────────────────────────────

  Widget _buildBottomActionSection(double bottomPad, bool isConfirmed) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isConfirmed) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _verifierStatut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Vérifier le statut du paiement',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isConfirmed ? AppColors.primary : Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isConfirmed ? AppColors.primary : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
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
            width: 110,
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
