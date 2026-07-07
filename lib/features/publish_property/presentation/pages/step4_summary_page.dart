import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import 'verification_page.dart';

/// Étape 4 / 4 — Récapitulatif complet avant soumission.
class Step4SummaryPage extends StatelessWidget {
  final PublishController controller;

  const Step4SummaryPage({super.key, required this.controller});

  Future<void> _submit(BuildContext context) async {
    await controller.submitProperty();
    if (!context.mounted) return;
    if (controller.status == PublishStatus.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => VerificationPage(
            propertyId: controller.submittedPropertyId ?? '',
            propertyTitle:
                controller.draft.title ?? 'Votre bien',
            propertyAddress:
                controller.draft.address ?? '',
            thumbnailPath: controller.draft.mediaPaths.isNotEmpty
                ? controller.draft.mediaPaths.first
                : null,
          ),
        ),
        // On dépile jusqu'à la home (retire tout le flow publish)
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Erreur lors de la soumission.',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PublishAppBar(
          title: 'Récapitulatif',
          currentStep: 3,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final draft = controller.draft;
            final isLoading = controller.status == PublishStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero image ─────────────────────────────────────
                  _HeroImage(
                    thumbnailPath: draft.mediaPaths.isNotEmpty
                        ? draft.mediaPaths.first
                        : null,
                    title: draft.title ?? '—',
                    address: draft.address ?? '—',
                    price: draft.price,
                    transactionType: draft.transactionType,
                  ),
                  const SizedBox(height: 16),

                  // ── Section Informations ───────────────────────────
                  _SummarySection(
                    icon: Icons.info_outline_rounded,
                    title: 'Informations',
                    onEdit: () {
                      // Retour à l'étape 1 (pop 3 fois)
                      Navigator.of(context).popUntil(
                        (r) =>
                            r.settings.name == '/' || r.isFirst ||
                            r.settings.name == '/publish/step1',
                      );
                    },
                    child: Column(
                      children: [
                        _InfoGrid(draft: draft),
                        const Divider(height: 24, color: AppColors.outlineVariant),
                        _InfoRow(
                          label: 'Description',
                          value: draft.description ?? '—',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Adresse',
                          value: draft.address ?? '—',
                        ),
                        if (draft.latitude != null) ...[
                          const SizedBox(height: 4),
                          _InfoRow(
                            label: 'Coordonnées',
                            value:
                                '${draft.latitude!.toStringAsFixed(5)}, ${draft.longitude!.toStringAsFixed(5)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Section Médias ─────────────────────────────────
                  if (draft.mediaPaths.isNotEmpty)
                    _SummarySection(
                      icon: Icons.image_outlined,
                      title: 'Médias (${draft.mediaPaths.length})',
                      onEdit: () => Navigator.of(context).pop(),
                      child: _MediaGrid(paths: draft.mediaPaths),
                    ),
                  const SizedBox(height: 12),

                  // ── Section Documents ──────────────────────────────
                  _SummarySection(
                    icon: Icons.description_outlined,
                    title: 'Documents joints',
                    onEdit: () => Navigator.of(context).pop(),
                    child: Column(
                      children: [
                        if (draft.titleDeedPath != null)
                          _DocItem(
                            icon: Icons.picture_as_pdf_rounded,
                            label: 'Titre foncier',
                            path: draft.titleDeedPath!,
                          ),
                        if (draft.idDocumentPath != null) ...[
                          const SizedBox(height: 8),
                          _DocItem(
                            icon: Icons.badge_outlined,
                            label: "Pièce d'identité",
                            path: draft.idDocumentPath!,
                          ),
                        ],
                        if (draft.cadastralPlanPath != null) ...[
                          const SizedBox(height: 8),
                          _DocItem(
                            icon: Icons.map_outlined,
                            label: 'Plan cadastral',
                            path: draft.cadastralPlanPath!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Carte sécurité ─────────────────────────────────
                  _SecurityCard(),

                  const SizedBox(height: 8),

                  // ── Délai traitement ───────────────────────────────
                  _ProcessingCard(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Condition d'utilisation
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'En publiant, vous acceptez nos Conditions Générales de Vente.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                PublishBottomBar(
                  nextLabel: 'Soumettre pour vérification',
                  isLoading: controller.status == PublishStatus.loading,
                  onBack: () => Navigator.of(context).pop(),
                  onNext: () => _submit(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String? thumbnailPath;
  final String title;
  final String address;
  final double? price;
  final String? transactionType;

  const _HeroImage({
    this.thumbnailPath,
    required this.title,
    required this.address,
    this.price,
    this.transactionType,
  });

  String _formatPrice(double p) {
    if (p >= 1000000000) {
      return '${(p / 1000000000).toStringAsFixed(1)} Mrd FCFA';
    }
    if (p >= 1000000) {
      return '${(p / 1000000).toStringAsFixed(0)} M FCFA';
    }
    if (p >= 1000) {
      return '${(p / 1000).toStringAsFixed(0)} K FCFA';
    }
    return '${p.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image ou placeholder
            if (thumbnailPath != null)
              Image.file(File(thumbnailPath!), fit: BoxFit.cover)
            else
              Container(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                child: const Center(
                  child: Icon(Icons.home_work_rounded,
                      color: AppColors.primaryContainer, size: 80),
                ),
              ),

            // Dégradé bas
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Badge aperçu
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Aperçu de la publication',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Titre + adresse
            Positioned(
              bottom: 12,
              left: 12,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Prix
            if (price != null)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatPrice(price!),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
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

class _SummarySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onEdit;
  final Widget child;

  const _SummarySection({
    required this.icon,
    required this.title,
    this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Modifier',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final draft;
  const _InfoGrid({required this.draft});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      children: [
        _GridCell(label: 'Type', value: draft.propertyType ?? '—'),
        _GridCell(
            label: 'Surface',
            value: draft.surface != null
                ? '${draft.surface!.toStringAsFixed(0)} m²'
                : '—'),
        _GridCell(label: 'Pièces', value: '${draft.rooms} pièces'),
        _GridCell(
            label: 'Salles de bain',
            value: '${draft.bathrooms} sdb'),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final String value;

  const _GridCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 13,
            color: AppColors.onSurface,
            height: 1.4,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<String> paths;
  const _MediaGrid({required this.paths});

  @override
  Widget build(BuildContext context) {
    final displayPaths = paths.take(4).toList();
    final extra = paths.length - 4;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        ...displayPaths.asMap().entries.map((e) {
          final isLast = e.key == 3 && extra > 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(e.value), fit: BoxFit.cover),
                if (isLast)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+$extra',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _DocItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  String get _fileName {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD6E3FF).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryContainer, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              Text(
                _fileName,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF004931), size: 20),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dernière vérification',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Veuillez vous assurer que toutes les informations fournies sont exactes et conformes aux documents officiels.',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF86F8C5), size: 16),
              SizedBox(width: 6),
              Text(
                'Données sécurisées SSL',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.visibility_outlined,
                  color: Color(0xFF86F8C5), size: 16),
              SizedBox(width: 6),
              Text(
                'Examen humain par nos agents',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule_rounded,
              color: AppColors.primary, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Délai de traitement',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '24h à 48h ouvrées',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Vous recevrez une notification par email dès que votre annonce sera validée.',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
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
