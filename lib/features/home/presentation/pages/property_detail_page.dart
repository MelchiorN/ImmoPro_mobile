import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/usecases/get_property_detail_usecase.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../widgets/property_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../location_bien/presentation/pages/location_duree_page.dart';
import 'property_map_navigation_page.dart';

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

  List<PropertyEntity> _similarProperties = [];
  bool _isLoadingSimilar = false;

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
    _loadSimilarProperties();
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

  Future<void> _loadSimilarProperties() async {
    setState(() => _isLoadingSimilar = true);
    try {
      final ds = HomeRemoteDataSourceImpl();
      final list = await ds.getProperties(
        typeBien: _property.category,
        perPage: 6,
      );
      if (mounted) {
        setState(() {
          _similarProperties = list.where((p) => p.id != _property.id).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingSimilar = false);
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
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
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
                                const SizedBox(height: 16),
                                _buildAgentContactSection(),
                                const SizedBox(height: 20),
                                _buildCaracteristiquesSection(),
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
            height: MediaQuery.of(context).padding.top + 64,
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
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _CircleBtn(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          // Bouton favori
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: ListenableBuilder(
              listenable: ServiceLocator.instance.favoritesController,
              builder: (context, _) {
                final ctrl = ServiceLocator.instance.favoritesController;
                final isFav = ctrl.isFavorite(_property.id);
                return _CircleBtn(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  iconColor: isFav ? AppColors.error : AppColors.primary,
                  onTap: () => ctrl.toggleFavorite(_property.id),
                );
              },
            ),
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

  // ── Contact Agent Vérificateur (Nous contacter) ───────────────────────────
  Widget _buildAgentContactSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBE0F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Un conseiller à votre écoute',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Notre équipe est à votre disposition pour répondre à toutes vos questions.',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _contactAgent,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
            label: const Text('Nous contacter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _contactAgent() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Un accompagnement personnalisé',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Messagerie instantanée & assistance',
                        style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Vous serez mis en relation directe avec l\'agent ImmoPro responsable de la vérification et de l\'inspection physique de ce bien.',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture de la discussion avec l\'agent... (Messagerie style WhatsApp bientôt disponible)'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Démarrer la discussion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Équipements & Caractéristiques ───────────────────────────────────────
  Widget _buildCaracteristiquesSection() {
    final carac = _property.caracteristiques;
    if (carac.isEmpty) return const SizedBox.shrink();

    final items = <Map<String, dynamic>>[];
    carac.forEach((key, val) {
      if (val != null && val != false && val != '' && val != 0) {
        final label = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');

        IconData icon = Icons.check_circle_outline_rounded;
        if (key.contains('eau')) {
          icon = Icons.water_drop_outlined;
        } else if (key.contains('electricite')) {
          icon = Icons.bolt_outlined;
        } else if (key.contains('wifi') || key.contains('internet') || key.contains('fibre')) {
          icon = Icons.wifi_rounded;
        } else if (key.contains('clima')) {
          icon = Icons.ac_unit_rounded;
        } else if (key.contains('piscine')) {
          icon = Icons.pool_rounded;
        } else if (key.contains('jardin')) {
          icon = Icons.park_outlined;
        } else if (key.contains('garage') || key.contains('parking')) {
          icon = Icons.directions_car_rounded;
        } else if (key.contains('meuble')) {
          icon = Icons.chair_outlined;
        } else if (key.contains('camera') || key.contains('securite')) {
          icon = Icons.security_rounded;
        } else if (key.contains('etat')) {
          icon = Icons.info_outline_rounded;
        }

        String valueText = '';
        if (val is bool && val == true) {
          valueText = 'Oui';
        } else {
          valueText = val.toString();
        }

        items.add({
          'label': label,
          'value': valueText,
          'icon': icon,
        });
      }
    });

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements & Caractéristiques',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, size: 16, color: AppColors.primaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    '${item['label']}: ${item['value']}',
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Localisation (Carte interactive OpenStreetMap) ────────────────────────
  Widget _buildLocationSection() {
    final location = _property.location;
    final lat = (_property.latitude != null && _property.latitude != 0)
        ? _property.latitude!
        : 5.3599;
    final lng = (_property.longitude != null && _property.longitude != 0)
        ? _property.longitude!
        : -4.0083;

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
            if (location.isNotEmpty)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyMapNavigationPage(
                  property: _property,
                ),
              ),
            );
          },
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 15.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.immopro.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 50,
                            height: 50,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Badge Adresse Exacte en Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.isNotEmpty ? location : 'Abidjan, Côte d\'Ivoire',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  '${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° W',
                                  style: TextStyle(
                                    fontFamily: 'HankenGrotesk',
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
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
        ),
      ],
    );
  }

  // ── Biens similaires (Dynamiques depuis l'API) ───────────────────────────
  Widget _buildSimilarProperties() {
    if (_isLoadingSimilar) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
      );
    }
    if (_similarProperties.isEmpty) return const SizedBox.shrink();

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
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _similarProperties.length,
            itemBuilder: (context, index) {
              final prop = _similarProperties[index];
              return Container(
                width: 272,
                margin: const EdgeInsets.only(right: 14),
                child: PropertyCard(
                  property: prop,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailPage(
                          property: prop,
                          getDetailUseCase: widget.getDetailUseCase,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Barre d'action en bas ─────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, double bottomPad) {
    bool checkOwner(String actionName) {
      final currentUser = ServiceLocator.instance.currentUser;
      final currentUserId = currentUser?.id;
      final ownerId = _property.userId;

      if (currentUserId != null && ownerId != null && currentUserId.toString() == ownerId.toString()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous êtes le propriétaire de ce bien. Vous ne pouvez pas $actionName votre propre bien.',
              style: const TextStyle(fontFamily: 'HankenGrotesk'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return true;
      }
      return false;
    }

    void showSnack(String action) {
      if (checkOwner('réserver')) return;
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
      if (checkOwner('louer')) return;
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
  final Color? iconColor;

  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});

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
        child: Icon(icon, color: iconColor ?? AppColors.onSurface, size: 20),
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
// Modèle interne pour les pills
// ─────────────────────────────────────────────────────────────────────────────
class _PillData {
  final IconData icon;
  final String label;
  const _PillData(this.icon, this.label);
}
