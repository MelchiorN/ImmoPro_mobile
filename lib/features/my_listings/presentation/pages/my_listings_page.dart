import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../features/home/domain/entities/property_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../controllers/my_listings_controller.dart';
import 'listing_detail_page.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage>
    with SingleTickerProviderStateMixin {
  late final MyListingsController _controller;
  late final TabController _tabController;

  // Filtre statut courant pour l'onglet "Mes Annonces"
  String? _filterStatut;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = ServiceLocator.instance.myListingsController;
    _controller.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryContainer,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AnnonceTab(
                      controller: _controller,
                      filterStatut: _filterStatut,
                      onFilterChanged: (s) => setState(() => _filterStatut = s),
                    ),
                    const _LocationTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
        },
        tooltip: 'Retour',
      ),
      title: const Text(
        'Mes Biens',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, __) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _controller.status == MyListingsStatus.loading
                ? null
                : _controller.load,
            tooltip: 'Actualiser',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          labelStyle: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondary,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Mes Annonces'),
            Tab(text: 'Mes Locations'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglet "Mes Annonces"
// ─────────────────────────────────────────────────────────────────────────────

class _AnnonceTab extends StatelessWidget {
  final MyListingsController controller;
  final String? filterStatut;
  final void Function(String?) onFilterChanged;

  static const _statusFilters = [
    ('Tous', null),
    ('En attente', 'en_attente'),
    ('En vérification', 'en_verification'),
    ('Validé', 'valide'),
    ('Publié', 'publie'),
    ('Rejeté', 'rejete'),
  ];

  const _AnnonceTab({
    required this.controller,
    required this.filterStatut,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return switch (controller.status) {
          MyListingsStatus.initial ||
          MyListingsStatus.loading => _buildShimmer(),
          MyListingsStatus.error => _buildError(context),
          MyListingsStatus.empty => _buildNeverPublished(context),
          MyListingsStatus.loaded => _buildContent(context),
        };
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final items = filterStatut == null
        ? controller.listings
        : controller.listings.where((l) => l.statut == filterStatut).toList();

    return RefreshIndicator(
      onRefresh: controller.load,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Filtre + titre ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Annonces actives',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (controller.listings.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${items.length} bien${items.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Filtres pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusFilters.map((f) {
                        final isActive = filterStatut == f.$2;
                        return GestureDetector(
                          onTap: () => onFilterChanged(f.$2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryContainer
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primaryContainer
                                    : AppColors.outlineVariant.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                            child: Text(
                              f.$1,
                              style: TextStyle(
                                fontFamily: 'HankenGrotesk',
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Liste ou état vide ──────────────────────────────────────
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                hasFilter: filterStatut != null,
                onClearFilter: () => onFilterChanged(null),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ListingCard(
                      listing: items[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailPage(listing: items[i]),
                        ),
                      ),
                    ),
                  ),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Erreur de chargement',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeverPublished(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFD6E3FF).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_home_work_outlined,
                size: 48,
                color: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune annonce publiée',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              controller.emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/publish'),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Publier un bien',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglet "Mes Locations" (placeholder)
// ─────────────────────────────────────────────────────────────────────────────

class _LocationTab extends StatelessWidget {
  const _LocationTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 40,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mes séjours & réservations',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vos réservations et locations en cours apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte d'annonce — design inspiré du design.md
// ─────────────────────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final ListingEntity listing;
  final VoidCallback onTap;

  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56A0).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child:
                      listing.imageUrl != null && listing.imageUrl!.isNotEmpty
                      ? Image.network(
                          listing.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),

              // ── Infos ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + badge statut
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusBadge(statut: listing.statut),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Prix
                    Text(
                      _formatPrice(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Localisation
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _shortLocation(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Date
                    if (_dateLabel().isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 12,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _dateLabel(),
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 10,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Flèche
              const Padding(
                padding: EdgeInsets.only(top: 36),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.outlineVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.surfaceContainerLow,
    child: const Center(
      child: Icon(Icons.home_outlined, color: AppColors.outline, size: 28),
    ),
  );

  String _formatPrice() {
    final pType =
        listing.typeTransaction == 'location' ||
            listing.typeTransaction == 'colocation'
        ? PropertyType.rent
        : PropertyType.sale;
    return formatPriceFcfa(listing.price, pType);
  }

  String _shortLocation() {
    final parts = listing.location.split(',');
    return parts.first.trim();
  }

  String _dateLabel() {
    final raw = listing.publishedAt ?? listing.createdAt;
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return 'Créé le ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge de statut
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String statut;
  const _StatusBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cfg.label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: cfg.fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _BadgeCfg _config() {
    switch (statut) {
      case 'publie':
        return _BadgeCfg(
          label: 'Publié',
          bg: const Color(0xFF86F8C5).withValues(alpha: 0.4),
          fg: const Color(0xFF002114),
        );
      case 'en_verification':
        return _BadgeCfg(
          label: 'En vérif.',
          bg: const Color(0xFFD6E3FF),
          fg: const Color(0xFF00468C),
        );
      case 'en_attente':
        return _BadgeCfg(
          label: 'En attente',
          bg: const Color(0xFFE8F0FE),
          fg: AppColors.primaryContainer,
        );
      case 'rejete':
        return _BadgeCfg(
          label: 'Rejeté',
          bg: const Color(0xFFFFDAD6),
          fg: const Color(0xFF93000A),
        );
      case 'valide':
        return _BadgeCfg(
          label: 'À Publier',
          bg: const Color(0xFFFDF6B2),
          fg: const Color(0xFF723B13),
        );
      case 'archive':
        return _BadgeCfg(
          label: 'Archivé',
          bg: AppColors.surfaceContainer,
          fg: AppColors.onSurfaceVariant,
        );
      default:
        return _BadgeCfg(
          label: statut,
          bg: AppColors.surfaceContainer,
          fg: AppColors.onSurfaceVariant,
        );
    }
  }
}

class _BadgeCfg {
  final String label;
  final Color bg;
  final Color fg;
  const _BadgeCfg({required this.label, required this.bg, required this.fg});
}

// ─────────────────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilter;
  const _EmptyState({required this.hasFilter, required this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 36,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'Aucune annonce pour ce statut'
                  : 'Aucune annonce publiée',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Essayez un autre filtre.'
                  : 'Publiez votre premier bien via le bouton + ci-dessous.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onClearFilter,
                child: const Text(
                  'Afficher toutes les annonces',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment(_anim.value - 1, 0),
                    end: Alignment(_anim.value, 0),
                    colors: const [
                      Color(0xFFECEEF0),
                      Color(0xFFF7F9FB),
                      Color(0xFFECEEF0),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _box(double.infinity, 12),
                    const SizedBox(height: 8),
                    _box(100, 18),
                    const SizedBox(height: 8),
                    _box(80, 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double w, double h) => Container(
    width: w,
    height: h,
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFECEEF0),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
