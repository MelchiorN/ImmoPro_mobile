import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../controllers/location_controller.dart';
import '../widgets/location_progress_indicator.dart';
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

  String _getContractTitle() {
    final cat = widget.property.category.toLowerCase();
    if (cat.contains('bureau') || cat.contains('commerce')) {
      return 'Bail Commercial (Acte OHADA)';
    } else if (cat.contains('meuble') || cat.contains('studio')) {
      return 'Contrat de Location Meublée';
    }
    return 'Bail d\'habitation Résidentiel';
  }

  String _getCategoryTag() {
    final cat = widget.property.category.toLowerCase();
    if (cat.contains('bureau') || cat.contains('commerce')) {
      return 'COMMERCIAL';
    } else if (cat.contains('meuble') || cat.contains('studio')) {
      return 'MEUBLÉ';
    }
    return 'HABITATION';
  }

  // ── Accepter le contrat → navigation directe après await ─────────────────

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

    if (!mounted) return;

    if (_ctrl.status == LocationStatus.error) {
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
      return;
    }

    // Succès → navigation directe
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationPaiementPage(
          property: widget.property,
          controller: _ctrl,
        ),
      ),
    );
  }

  Future<void> _refuser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refuser le contrat ?', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
        content: const Text(
          'En refusant ce contrat, la réservation du bien sera immédiatement annulée et le bien sera de nouveau disponible pour d\'autres clients.',
          style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(fontFamily: 'Manrope', color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Oui, refuser le contrat', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _ctrl.refuserContrat();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Contrat refusé. La réservation a été annulée et le bien est de nouveau disponible.',
          style: TextStyle(fontFamily: 'HankenGrotesk'),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  Future<void> _telechargerPdf() async {
    final locationId = _ctrl.location?.id;
    if (locationId == null || locationId.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Téléchargement du contrat PDF certifié ImmoPro en cours...',
          style: TextStyle(fontFamily: 'HankenGrotesk'),
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final token = await ApiClient.instance.getToken();
      final uri = Uri.parse('${ApiClient.instance.baseUrl}/mobile/locations/$locationId/contrat/telecharger');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf, application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur (${response.statusCode})');
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
      final fileName = 'Contrat_ImmoPro_${_getCategoryTag()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${targetDir.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📄 Vrai fichier PDF télécharge avec succès !\nStockage : ${file.path}',
            style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 7),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement PDF : $e'),
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
            _buildLockSubHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getContractTitle(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Veuillez défiler et lire attentivement l\'intégralité du bail avant d\'accepter.',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Visualiseur de contrat scrollable ──────────────────────
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          ),
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
                            // En-tête type PDF
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Contrat_${_getCategoryTag()}_ImmoPro.pdf',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getCategoryTag(),
                                      style: const TextStyle(
                                        fontFamily: 'HankenGrotesk',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _telechargerPdf,
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.file_download_outlined, size: 20, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Corps du contrat avec détection de défilement complet
                            Expanded(
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notif) {
                                  if (!_lu &&
                                      notif.metrics.maxScrollExtent > 0 &&
                                      notif.metrics.pixels >= (notif.metrics.maxScrollExtent - 40)) {
                                    setState(() => _lu = true);
                                  }
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(18),
                                  child: _renderHtmlContent(contenu),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Badge "Vous avez lu jusqu'à la fin ✓"
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _lu ? const Color(0xFFE8F5E9) : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _lu ? const Color(0xFF388E3C) : AppColors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lu ? Icons.check_circle_rounded : Icons.south_rounded,
                            size: 18,
                            color: _lu ? const Color(0xFF388E3C) : AppColors.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lu
                                  ? 'Vous avez lu l\'intégralité du contrat ✓'
                                  : 'Défilez vers le bas pour débloquer l\'acceptation',
                              style: TextStyle(
                                fontFamily: 'HankenGrotesk',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _lu ? const Color(0xFF2E7D32) : AppColors.onSurfaceVariant,
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
            _buildBottomBar(bottomPad),
          ],
        ),
      ),
    )));
  }

  // ── Sous-en-tête alerte verrouillage ───────────────────────────────────────
  Widget _buildLockSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.lock_clock_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Bien réservé temporairement',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Text(
            '15:00 restantes',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderHtmlContent(String rawHtml) {
    if (rawHtml.isEmpty) return _buildContratPlaceholder();

    final cleanText = rawHtml
        .replaceAll(RegExp(r'</h\d>'), '\n\n')
        .replaceAll(RegExp(r'</p>|</div>|</li>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<hr\s*/?>'), '\n──────────────────────────\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return SelectableText(
      cleanText,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 13.5,
        height: 1.6,
        color: AppColors.onSurface,
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

  // ── Indicateur de progression étape 2/3 ──────────────────────────────────

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          LocationProgStep(label: 'Informations', state: LocationStepState.done),
          LocationProgConnector(active: true),
          LocationProgStep(label: 'Contrat', state: LocationStepState.active),
          LocationProgConnector(active: false),
          LocationProgStep(label: 'Paiement', state: LocationStepState.idle),
        ],
      ),
    );
  }

  // ── Contenu du contrat (fallback si le backend ne renvoie pas de HTML) ────

  Widget _buildContratPlaceholder() {
    final loc = _ctrl.location;
    if (loc == null) return const SizedBox.shrink();

    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    String fmtMontant(double v) {
      final digits = v.toInt().toString().split('');
      final buf = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u202F');
        buf.write(digits[i]);
      }
      return '${buf.toString()} FCFA';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'CONTRAT DE LOCATION',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSection('I. DÉSIGNATION DES PARTIES', [
          'Le présent contrat est conclu entre ImmoPro (plateforme) et le locataire connecté.',
        ]),
        _buildSection('II. OBJET DU CONTRAT', [
          'Bien : ${widget.property.title}',
          'Adresse : ${widget.property.location}',
        ]),
        _buildSection('III. DURÉE ET PRISE D\'EFFET', [
          'Durée : ${loc.dureeMois} mois',
          'Début : ${fmtDate(loc.dateDebut)}',
          'Fin : ${fmtDate(loc.dateFin)}',
        ]),
        _buildSection('IV. CONDITIONS FINANCIÈRES', [
          'Loyer mensuel : ${fmtMontant(loc.prixProprietaire)}',
          'Total : ${fmtMontant(loc.montantTotal)}',
        ]),
        _buildSection('V. OBLIGATIONS DU LOCATAIRE', [
          '• Payer le loyer aux termes convenus.',
          '• User paisiblement des locaux selon leur destination.',
          '• Répondre des dégradations survenant pendant le contrat.',
          '• Prendre à sa charge l\'entretien courant.',
        ]),
        _buildSection('VI. RÉSILIATION', [
          'En cas de non-respect des clauses, le présent contrat pourra être résilié '
              'par la plateforme après mise en demeure restée sans effet.',
        ]),
        const SizedBox(height: 24),
        const Text(
          'En acceptant ce contrat, vous certifiez avoir pris connaissance de l\'ensemble '
          'des clauses et conditions générales de location ImmoPro.',
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String titre, List<String> lignes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          ...lignes.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre bas ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double bottomPad) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_lu)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  const Text(
                    'Faites défiler le contrat pour activer l\'acceptation.',
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // Bouton Refuser
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _ctrl.isLoading ? null : _refuser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Refuser',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton Accepter
              Expanded(
                flex: 2,
                child: SizedBox(
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
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Accepter le contrat',
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// fin du fichier
