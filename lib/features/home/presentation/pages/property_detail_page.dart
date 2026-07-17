import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/usecases/get_property_detail_usecase.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../location_bien/presentation/pages/location_duree_page.dart';

class PropertyDetailPage extends StatefulWidget {
  final PropertyEntity property;
  final GetPropertyDetailUseCase? getDetailUseCase;

  const PropertyDetailPage({
    super.key,
    required this.property,
    this.getDetailUseCase,
  });

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  PropertyEntity? _detail;
  bool _isLoadingDetail = false;
  int _currentIndex = 0;
  bool _descExpanded = false;
  final ScrollController _carouselController = ScrollController();

  List<PropertyMedia> get _allMedia {
    final p = _detail ?? widget.property;
    if (p.medias.isNotEmpty) return p.medias;
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      return [
        PropertyMedia(
          id: 'cover',
          type: 'image',
          url: p.imageUrl!,
          isPrimary: true,
        ),
      ];
    }
    return [];
  }

  PropertyEntity get _property => _detail ?? widget.property;

  @override
  void initState() {
    super.initState();
    _carouselController.addListener(() {
      if (!_carouselController.hasClients) return;
      // Calcule l'index courant en fonction de la position du scroll
      final w = _carouselController.position.viewportDimension;
      if (w <= 0) return;
      final i = (_carouselController.offset / w).round();
      final media = _allMedia;
      final clamped = i.clamp(0, media.isEmpty ? 0 : media.length - 1);
      if (clamped != _currentIndex) setState(() => _currentIndex = clamped);
    });
    if (widget.getDetailUseCase != null) _loadDetail();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoadingDetail = true);
    try {
      final d = await widget.getDetailUseCase!.call(widget.property.id);
      if (mounted) setState(() => _detail = d);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  // Plus utilisé — tous les types ont désormais Réserver + Louer

  @override
  Widget build(BuildContext context) {
    final media = _allMedia;
    // topPad conservé pour usage futur potentiel
    final _ = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: false,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Carousel — commence sous la status bar ────────────
                      _buildCarousel(media),
                      // ── Contenu blanc arrondi qui remonte ─────────────────
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              24,
                              16,
                              bottomPad + 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 16),
                                _buildStatsPills(),
                                const SizedBox(height: 20),
                                _buildDescription(),
                                const SizedBox(height: 20),
                                _buildLocationSection(),
                                const SizedBox(height: 20),
                                _buildSimilarProperties(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Barre bas ─────────────────────────────────────────────────
              _buildBottomBar(context, bottomPad),
            ],
          ),
        ),
      ),
    );
  }

  // ── Carousel ──────────────────────────────────────────────────────────────
  Widget _buildCarousel(List<PropertyMedia> media) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          if (media.isEmpty)
            _buildPlaceholder()
          else
            ListView.builder(
              controller: _carouselController,
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              itemCount: media.length,
              itemBuilder: (ctx, i) {
                final m = media[i];
                final w = MediaQuery.of(ctx).size.width;
                return SizedBox(
                  width: w,
                  height: 320,
                  child: m.type == 'video'
                      ? _VideoItem(url: m.url, autoPlay: i == _currentIndex)
                      : GestureDetector(
                          onTap: () => _openImageViewer(media, i),
                          child: _ImageItem(url: m.url),
                        ),
                );
              },
            ),
          // Dégradé haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 64,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bouton retour
          Positioned(
            top: 12,
            left: 12,
            child: _CircleBtn(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          // Bouton favori
          Positioned(
            top: 12,
            right: 12,
            child: _CircleBtn(icon: Icons.favorite_border, onTap: () {}),
          ),
          // Compteur + icône agrandissement
          if (media.isNotEmpty)
            Positioned(
              bottom: 42,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (media[_currentIndex].type == 'image')
                    GestureDetector(
                      onTap: () => _openImageViewer(media, _currentIndex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${media.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Spinner chargement
          if (_isLoadingDetail)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Ouvre la visionneuse plein écran sur l'image [startIndex]
  void _openImageViewer(List<PropertyMedia> media, int startIndex) {
    // Filtre seulement les images (pas les vidéos)
    final images = media.where((m) => m.type == 'image').toList();
    if (images.isEmpty) return;
    // Recalcule l'index parmi les images seulement
    final imageIndex = images.indexWhere((m) => m.id == media[startIndex].id);
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewerPage(
          images: images,
          initialIndex: imageIndex >= 0 ? imageIndex : 0,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Center(
        child: Icon(Icons.home_outlined, color: AppColors.outline, size: 80),
      ),
    );
  }

  // ── Header : titre, prix, adresse ─────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _property.title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatPriceFcfa(_property.price, _property.type),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.secondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _property.location,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Voir carte',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stats pills ────────────────────────────────────────────────────────────
  Widget _buildStatsPills() {
    final pills = <_PillData>[];
    if (_property.surface != null) {
      pills.add(
        _PillData(
          Icons.square_foot_outlined,
          '${_property.surface!.toInt()} m²',
        ),
      );
    }
    if (_property.rooms != null) {
      pills.add(
        _PillData(Icons.meeting_room_outlined, '${_property.rooms} Pièces'),
      );
    }
    if (_property.bathrooms != null) {
      pills.add(
        _PillData(Icons.bathtub_outlined, '${_property.bathrooms} SDB'),
      );
    }
    if (pills.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: pills
            .map(
              (p) => Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.icon, size: 18, color: AppColors.primary),
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
    );
  }

  // ── Description ───────────────────────────────────────────────────────────
  Widget _buildDescription() {
    final desc = _property.description;
    if (desc.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _descExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          secondChild: Text(
            desc,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _descExpanded = !_descExpanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _descExpanded ? 'Réduire' : 'Lire la suite',
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Localisation (mini-carte stylisée) ────────────────────────────────────
  Widget _buildLocationSection() {
    final location = _property.location;
    if (location.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Localisation',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              location.split(',').first.trim(),
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                CustomPaint(painter: _SimpleMapPainter(), size: Size.infinite),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.split(',').first.trim(),
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ],
    );
  }

  // ── Biens similaires ──────────────────────────────────────────────────────
  Widget _buildSimilarProperties() {
    // Section statique — sera remplacée par des données dynamiques plus tard
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biens similaires',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _SimilarCard(
                label: _property.location.split(',').first.trim(),
                title: 'Bien similaire',
                price: formatPriceFcfa(_property.price * 0.85, _property.type),
                imageUrl: _property.imageUrl,
              ),
              const SizedBox(width: 12),
              _SimilarCard(
                label: _property.category,
                title: 'Autre bien',
                price: formatPriceFcfa(_property.price * 1.1, _property.type),
                imageUrl: _property.imageUrl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Barre d'action en bas ─────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, double bottomPad) {
    void showSnack(String action) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$action — bientôt disponible.',
            style: const TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    void ouvrirTunnelLocation() {
      final sl = ServiceLocator.instance;
      final ctrl = sl.createLocationController();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LocationDureePage(
            property: _property,
            controller: ctrl,
          ),
        ),
      );
    }

    // Tous les types ont les boutons Réserver + Louer
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
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
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => showSnack('Réserver'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Réserver',
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
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: ouvrirTunnelLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Louer',
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget image réseau
// ─────────────────────────────────────────────────────────────────────────────
class _ImageItem extends StatelessWidget {
  final String url;
  const _ImageItem({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, p) => p == null
          ? child
          : Container(
              color: AppColors.surfaceContainerLow,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceContainerLow,
        child: const Center(
          child: Icon(Icons.home_outlined, color: AppColors.outline, size: 64),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget vidéo avec auto-play
// ─────────────────────────────────────────────────────────────────────────────
class _VideoItem extends StatefulWidget {
  final String url;
  final bool autoPlay;
  const _VideoItem({required this.url, this.autoPlay = false});

  @override
  State<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<_VideoItem> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _ctrl.initialize();
      _ctrl.setLooping(true);
      if (widget.autoPlay) _ctrl.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(_VideoItem old) {
    super.didUpdateWidget(old);
    if (_initialized) widget.autoPlay ? _ctrl.play() : _ctrl.pause();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white54, size: 48),
        ),
      );
    }
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }
    return GestureDetector(
      onTap: () =>
          setState(() => _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play()),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _ctrl.value.size.width,
              height: _ctrl.value.size.height,
              child: VideoPlayer(_ctrl),
            ),
          ),
          if (!_ctrl.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 64,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton circulaire flottant
// ─────────────────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte similaire horizontale
// ─────────────────────────────────────────────────────────────────────────────
class _SimilarCard extends StatelessWidget {
  final String label;
  final String title;
  final String price;
  final String? imageUrl;
  const _SimilarCard({
    required this.label,
    required this.title,
    required this.price,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56A0).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceContainerLow),
                    )
                  else
                    Container(color: AppColors.surfaceContainerLow),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
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

// ─────────────────────────────────────────────────────────────────────────────
// Visionneuse plein écran avec défilement entre les images
// ─────────────────────────────────────────────────────────────────────────────
class _ImageViewerPage extends StatefulWidget {
  final List<PropertyMedia> images;
  final int initialIndex;

  const _ImageViewerPage({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // PageView avec zoom par InteractiveViewer
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (ctx, i) {
                final img = widget.images[i];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      img.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, p) => p == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Dégradé haut pour les boutons
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bouton fermer
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    // Compteur
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_current + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Flèche gauche
            if (_current > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

            // Flèche droite
            if (_current < widget.images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

            // Indicateurs de points en bas
            if (widget.images.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _current ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _current
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini-carte stylisée pour la section localisation
// ─────────────────────────────────────────────────────────────────────────────
class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      grid,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      grid,
    );
    final park = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.45, size.height * 0.08, 70, 50),
        const Radius.circular(8),
      ),
      park,
    );
  }

  @override
  bool shouldRepaint(_SimpleMapPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Modèle interne pour les pills
// ─────────────────────────────────────────────────────────────────────────────
class _PillData {
  final IconData icon;
  final String label;
  const _PillData(this.icon, this.label);
}
