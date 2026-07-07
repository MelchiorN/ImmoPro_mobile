import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';

/// Écran de confirmation — "En cours de vérification".
/// Affiché après soumission réussie du bien.
class VerificationPage extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final String? thumbnailPath;

  const VerificationPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyAddress,
    this.thumbnailPath,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {},
          ),
          title: const Text(
            'ImmoPro',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          child: Column(
            children: [
              // ── Illustration flottante ─────────────────────────────
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnim.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppColors.primary,
                      size: 68,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Titre & sous-titre ──────────────────────────────────
              const Text(
                'En cours de vérification',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Nos experts analysent les documents et informations fournis pour assurer la qualité de notre service.',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // ── Timeline de progression ─────────────────────────────
              _ProgressTimeline(),
              const SizedBox(height: 24),

              // ── Carte résumé du bien ───────────────────────────────
              _PropertySummaryCard(
                title: widget.propertyTitle,
                address: widget.propertyAddress,
                thumbnailPath: widget.thumbnailPath,
              ),
              const SizedBox(height: 24),

              // ── Boutons ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: naviguer vers le suivi du statut
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fonctionnalité de suivi à venir.',
                          style: TextStyle(fontFamily: 'HankenGrotesk'),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.track_changes_rounded, size: 20),
                  label: const Text('Suivre le statut'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Retour à l'accueil et déclencher un nouveau flow
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 20, color: AppColors.primary),
                  label: const Text(
                    'Publier un autre bien',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppColors.primaryContainer),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Note notification ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE4EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primaryContainer, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vous recevrez une notification par SMS et Email dès que l\'étape de vérification sera complétée. Habituellement sous 24-48h.',
                        style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentIndex: 3, // "Mes Biens" actif après soumission
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline();

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
          icon: Icons.check_rounded,
          label: 'Soumis',
          isDone: true,
          isActive: false),
      _TimelineStep(
          icon: Icons.search_rounded,
          label: 'Vérification',
          isDone: false,
          isActive: true),
      _TimelineStep(
          icon: Icons.calendar_month_outlined,
          label: 'Visite',
          isDone: false,
          isActive: false),
      _TimelineStep(
          icon: Icons.verified_outlined,
          label: 'Validé',
          isDone: false,
          isActive: false),
    ];

    return Row(
      children: steps.asMap().entries.expand((e) {
        final i = e.key;
        final step = e.value;
        return [
          Expanded(child: _TimelineNode(step: step)),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i < 1 ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ];
      }).toList(),
    );
  }
}

class _TimelineStep {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
  });
}

class _TimelineNode extends StatelessWidget {
  final _TimelineStep step;
  const _TimelineNode({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: step.isActive ? 44 : 32,
          height: step.isActive ? 44 : 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.isDone || step.isActive
                ? AppColors.primaryContainer
                : AppColors.surfaceContainer,
            boxShadow: step.isActive
                ? [
                    BoxShadow(
                      color:
                          AppColors.primaryContainer.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            step.icon,
            color: step.isDone || step.isActive
                ? Colors.white
                : AppColors.onSurfaceVariant,
            size: step.isActive ? 20 : 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 10,
            fontWeight:
                step.isActive ? FontWeight.w700 : FontWeight.w500,
            color: step.isDone || step.isActive
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PropertySummaryCard extends StatelessWidget {
  final String title;
  final String address;
  final String? thumbnailPath;

  const _PropertySummaryCard({
    required this.title,
    required this.address,
    this.thumbnailPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Miniature
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: thumbnailPath != null
                  ? Image.file(File(thumbnailPath!), fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primaryContainer
                          .withValues(alpha: 0.15),
                      child: const Icon(Icons.home_work_rounded,
                          color: AppColors.primaryContainer, size: 36),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF86F8C5).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002114),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


