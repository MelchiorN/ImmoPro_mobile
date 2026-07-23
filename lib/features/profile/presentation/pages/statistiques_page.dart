import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadStats();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getAuth('/mobile/statistiques');
      if (mounted) {
        setState(() {
          _stats = res['data'] as Map<String, dynamic>?;
          _loading = false;
        });
        _animCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF003E7E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003E7E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Mes Statistiques',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _loadStats,
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Impossible de charger les statistiques',
              style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStats, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final s = _stats ?? {};
    final totalLoc = s['total_locations'] ?? 0;
    final locActives = s['locations_actives'] ?? 0;
    final depenses = (s['total_depenses'] as num?)?.toDouble() ?? 0.0;
    final favoris = s['total_favoris'] ?? 0;
    final biensPublies = s['total_biens_publies'] ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Résumé en haut ───────────────────────────────────────────────
          _buildHeroCard(depenses),
          const SizedBox(height: 24),

          const Text(
            'Aperçu de votre activité',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 14),

          // ── Grille de stats ─────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                icon: Icons.home_work_outlined,
                label: 'Locations totales',
                value: '$totalLoc',
                color: const Color(0xFF1A56A0),
                animation: _animCtrl,
                delay: 0.0,
              ),
              _StatCard(
                icon: Icons.check_circle_outline_rounded,
                label: 'Locations actives',
                value: '$locActives',
                color: const Color(0xFF006B3C),
                animation: _animCtrl,
                delay: 0.1,
              ),
              _StatCard(
                icon: Icons.favorite_outline_rounded,
                label: 'Biens en favoris',
                value: '$favoris',
                color: const Color(0xFFB5251C),
                animation: _animCtrl,
                delay: 0.2,
              ),
              _StatCard(
                icon: Icons.apartment_outlined,
                label: 'Annonces publiées',
                value: '$biensPublies',
                color: const Color(0xFF6A4C93),
                animation: _animCtrl,
                delay: 0.3,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Section conseils ─────────────────────────────────────────────
          _buildTips(locActives, favoris),
        ],
      ),
    );
  }

  Widget _buildHeroCard(double depenses) {
    final montantStr = depenses >= 1000000
        ? '${(depenses / 1000000).toStringAsFixed(1)}M'
        : depenses >= 1000
            ? '${(depenses / 1000).toStringAsFixed(0)}K'
            : depenses.toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003E7E), Color(0xFF1A56A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003E7E).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total des dépenses',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$montantStr FCFA',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Montant total des loyers payés',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(int locActives, int favoris) {
    if (locActives == 0 && favoris == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBE0F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: Color(0xFF1A56A0), size: 18),
              SizedBox(width: 8),
              Text(
                'Conseils personnalisés',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A56A0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (favoris > 0)
            _TipRow(
              '🏠',
              'Vous avez $favoris bien(s) en favoris. Pensez à contacter le propriétaire !',
            ),
          if (locActives > 0)
            _TipRow(
              '📋',
              'Vous avez $locActives location(s) active(s). Consultez votre historique.',
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AnimationController animation;
  final double delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.animation,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: color.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TipRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _TipRow(this.emoji, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
