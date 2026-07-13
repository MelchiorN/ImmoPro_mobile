import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../features/home/domain/entities/property_entity.dart';
import '../../domain/entities/listing_entity.dart';

/// Page de détail d'une annonce de l'utilisateur avec suivi du statut.
class ListingDetailPage extends StatelessWidget {
  final ListingEntity listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                        padding: EdgeInsets.fromLTRB(
                            16, 24, 16, bottomPad + 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _StatusTracker(statut: listing.statut),
                            const SizedBox(height: 20),
                            if (listing.statut == 'rejete' &&
                                listing.rejectionReason != null)
                              _RejectionCard(reason: listing.rejectionReason!),
                            _buildInfoSection(),
                            const SizedBox(height: 20),
                            if (listing.description != null &&
                                listing.description!.isNotEmpty)
                              _buildDescription(),
                          ],
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
    );
  }

  // ── Hero image ───────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de couverture
          if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty)
            Image.network(
              listing.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroPlaceholder(),
            )
          else
            _heroPlaceholder(),

          // Dégradé haut
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),

          // Bouton retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ),

          // Badge type de bien
          Positioned(
            bottom: 36,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _typeBienLabel(listing.typeBien),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'HankenGrotesk',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPlaceholder() {
    return Container(
      color: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.home_work_outlined,
            size: 64, color: AppColors.primaryContainer),
      ),
    );
  }

  // ── En-tête titre + prix ─────────────────────────────────────────────────
  Widget _buildHeader() {
    // Construit un PropertyType factice pour le formateur de prix
    final pType = listing.typeTransaction == 'location' ||
            listing.typeTransaction == 'colocation'
        ? PropertyType.rent
        : PropertyType.sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatPriceFcfa(listing.price, pType),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 14, color: AppColors.secondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                listing.location,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Date de création
        if (listing.createdAt != null)
          Text(
            'Créée le ${_formatDate(listing.createdAt!)}',
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              color: AppColors.outline,
            ),
          ),
      ],
    );
  }

  // ── Section caractéristiques ─────────────────────────────────────────────
  Widget _buildInfoSection() {
    final pills = <_Pill>[];
    if (listing.surface != null) {
      pills.add(_Pill(Icons.square_foot_outlined,
          '${listing.surface!.toInt()} m²'));
    }
    if (listing.rooms != null) {
      pills.add(_Pill(Icons.meeting_room_outlined, '${listing.rooms} pièces'));
    }
    if (listing.bathrooms != null) {
      pills.add(_Pill(Icons.bathtub_outlined, '${listing.bathrooms} SDB'));
    }
    if (pills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Caractéristiques',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: pills
              .map(
                (p) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(p.icon, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        p.label,
                        style: const TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── Description ───────────────────────────────────────────────────────────
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listing.description!,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  String _typeBienLabel(String raw) {
    switch (raw) {
      case 'appartement':  return 'Appartement';
      case 'villa':        return 'Villa';
      case 'maison':       return 'Maison';
      case 'terrain':      return 'Terrain';
      case 'bureau_commerce': return 'Bureau / Commerce';
      default:             return raw;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _Pill {
  final IconData icon;
  final String label;
  const _Pill(this.icon, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tracker de statut visuel (timeline)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusTracker extends StatelessWidget {
  final String statut;
  const _StatusTracker({required this.statut});

  static const _steps = [
    _StepDef('Soumis',        'en_attente',      Icons.upload_rounded),
    _StepDef('Vérification',  'en_verification', Icons.search_rounded),
    _StepDef('Visite',        'visite',          Icons.calendar_month_outlined),
    _StepDef('Publié',        'publie',          Icons.verified_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isRejected = statut == 'rejete';
    final isArchived  = statut == 'archive';

    // Index de l'étape courante dans le pipeline normal
    int activeIndex = _steps.indexWhere((s) => s.key == statut);
    if (activeIndex == -1) activeIndex = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRejected
            ? const Color(0xFFFFE4E4)
            : isArchived
                ? AppColors.surfaceContainerLow
                : const Color(0xFFE8F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRejected
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primaryContainer.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected
                    ? Icons.cancel_rounded
                    : isArchived
                        ? Icons.archive_rounded
                        : Icons.track_changes_rounded,
                color: isRejected ? AppColors.error : AppColors.primaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suivi de l\'annonce',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isRejected ? AppColors.error : AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isRejected || isArchived)
            // État terminal simple
            _TerminalStatus(statut: statut)
          else
            // Timeline de progression
            Row(
              children: _steps.asMap().entries.expand((e) {
                final idx  = e.key;
                final step = e.value;
                final isDone   = idx < activeIndex;
                final isActive = idx == activeIndex;

                return [
                  Expanded(
                    child: _StepNode(
                      step: step,
                      isDone: isDone,
                      isActive: isActive,
                    ),
                  ),
                  if (idx < _steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.primaryContainer
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _StepDef {
  final String label;
  final String key;
  final IconData icon;
  const _StepDef(this.label, this.key, this.icon);
}

class _StepNode extends StatelessWidget {
  final _StepDef step;
  final bool isDone;
  final bool isActive;

  const _StepNode({
    required this.step,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 42 : 30,
          height: isActive ? 42 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isActive
                ? AppColors.primaryContainer
                : AppColors.surfaceContainer,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer
                          .withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            step.icon,
            color: isDone || isActive ? Colors.white : AppColors.outline,
            size: isActive ? 20 : 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isDone || isActive
                ? AppColors.primaryContainer
                : AppColors.outline,
          ),
        ),
      ],
    );
  }
}

class _TerminalStatus extends StatelessWidget {
  final String statut;
  const _TerminalStatus({required this.statut});

  @override
  Widget build(BuildContext context) {
    final isRejected = statut == 'rejete';
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRejected
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.surfaceContainer,
          ),
          child: Icon(
            isRejected ? Icons.cancel_rounded : Icons.archive_rounded,
            color: isRejected ? AppColors.error : AppColors.onSurfaceVariant,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRejected ? 'Annonce rejetée' : 'Annonce archivée',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isRejected ? AppColors.error : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isRejected
                    ? 'Votre annonce n\'a pas été validée.'
                    : 'Cette annonce n\'est plus visible.',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  color: isRejected
                      ? AppColors.error.withValues(alpha: 0.7)
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte raison de rejet
// ─────────────────────────────────────────────────────────────────────────────

class _RejectionCard extends StatelessWidget {
  final String reason;
  const _RejectionCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motif du rejet',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 13,
                    color: AppColors.error,
                    height: 1.5,
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
