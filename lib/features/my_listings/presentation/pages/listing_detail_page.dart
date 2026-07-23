import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/home/domain/entities/property_entity.dart';
import '../../../../features/publish_property/presentation/pages/edit_info_page.dart';
import '../../domain/entities/listing_entity.dart';

/// Page de détail d'une annonce de l'utilisateur avec suivi du statut.
class ListingDetailPage extends StatefulWidget {
  final ListingEntity listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  late ListingEntity _listing;
  bool _uploadingMedia = false;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
  }

  // ── Logique changement de photos ─────────────────────────────────────────
  Future<void> _changePhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 85,
      limit: 10,
    );
    if (picked.isEmpty) return;

    setState(() => _uploadingMedia = true);

    try {
      final controller = ServiceLocator.instance.myListingsController;
      final updated = await controller.uploadMedia(
        _listing.id,
        picked.map((f) => f.path).toList(),
      );

      if (updated != null && mounted) {
        setState(() {
          _listing = updated;
          _uploadingMedia = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photos mises à jour avec succès.'),
            backgroundColor: Color(0xFF1A56A0),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingMedia = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour des photos.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openImageViewer(List<PropertyMedia> images, int startIndex) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ListingImageViewerPage(
          images: images,
          initialIndex: startIndex,
        ),
      ),
    );
  }

  bool get _canEditPhotos {
    return _listing.statut != 'archive';
  }

  /// Vrais si l'annonce peut encore être modifiée textuellement
  bool get _canEditInfo {
    const editableStatuts = {'en_attente', 'en_verification', 'rejete', 'brouillon'};
    return editableStatuts.contains(_listing.statut);
  }

  Future<void> _openEditPage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditInfoPage(listing: _listing),
      ),
    );
    // Si l'annonce a bien été modifiée, on recharge depuis le backend
    if (result == true && mounted) {
      final controller = ServiceLocator.instance.myListingsController;
      await controller.load();
      // Chercher la version mise à jour dans la liste
      final updated = controller.listings
          .where((l) => l.id == _listing.id)
          .firstOrNull;
      if (updated != null && mounted) {
        setState(() => _listing = updated);
      }
    }
  }

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
                      _buildHero(context),
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
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
                              const SizedBox(height: 20),
                              _StatusTracker(statut: _listing.statut),
                              const SizedBox(height: 20),
                              if (_listing.statut == 'rejete' &&
                                  _listing.rejectionReason != null)
                                _RejectionCard(
                                  reason: _listing.rejectionReason!,
                                ),
                              // Bouton modifier l'annonce (si statut modifiable)
                              if (_canEditInfo) ...[
                                _buildEditInfoButton(),
                                const SizedBox(height: 16),
                              ],
                              // Bouton publier (si statut valide)
                              if (_listing.statut == 'valide') ...[
                                _buildPublishButton(),
                                const SizedBox(height: 20),
                              ],
                              // Bouton changer photos (si statut modifiable)
                              if (_canEditPhotos) ...[
                                _buildChangePhotosButton(),
                                const SizedBox(height: 20),
                              ],
                              _buildInfoSection(),
                              const SizedBox(height: 20),
                              if (_listing.description != null &&
                                  _listing.description!.isNotEmpty)
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
      ),
    );
  }

  // ── Bouton modifier l'annonce ──────────────────────────────────────────────
  Widget _buildEditInfoButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _openEditPage,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'Modifier l\'annonce',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Bouton publier ────────────────────────────────────────────────────────
  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _publishing ? null : _publishListing,
        icon: _publishing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.rocket_launch_rounded, size: 20),
        label: Text(
          _publishing ? 'Publication...' : 'Publier l\'annonce',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _publishListing() async {
    setState(() => _publishing = true);
    try {
      final controller = ServiceLocator.instance.myListingsController;
      final updated = await controller.publishListing(_listing.id);
      if (updated != null && mounted) {
        setState(() {
          _listing = updated;
          _publishing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre bien a été publié avec succès 🎉'),
            backgroundColor: Color(0xFF1A56A0),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _publishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la publication.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Bouton changer photos ─────────────────────────────────────────────────
  Widget _buildChangePhotosButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _uploadingMedia ? null : _changePhotos,
        icon: _uploadingMedia
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryContainer,
                ),
              )
            : const Icon(Icons.photo_library_outlined, size: 20),
        label: Text(
          _uploadingMedia ? 'Envoi en cours...' : 'Changer les photos',
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Hero image ───────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    final List<PropertyMedia> images = List<PropertyMedia>.from(
      _listing.medias.where((m) => m.type == 'image'),
    );
    if (images.isEmpty && _listing.imageUrl != null && _listing.imageUrl!.isNotEmpty) {
      images.add(PropertyMedia(id: 'primary', type: 'image', url: _listing.imageUrl!));
    }

    int currentIndex = 0;

    return SizedBox(
      height: 280,
      child: StatefulBuilder(
        builder: (context, setHeroState) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Image/Carousel de couverture
              if (images.isNotEmpty)
                PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (idx) {
                    setHeroState(() {
                      currentIndex = idx;
                    });
                  },
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                      onTap: () => _openImageViewer(images, i),
                      child: Image.network(
                        images[i].url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _heroPlaceholder(),
                      ),
                    );
                  },
                )
              else
                _heroPlaceholder(),

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
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Dégradé bas (pour visibilité du bouton caméra et badges)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
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
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Bouton caméra (overlay bas droite) — visible si statut modifiable
              if (_canEditPhotos)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _uploadingMedia ? null : _changePhotos,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_uploadingMedia)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryContainer,
                              ),
                            )
                          else
                            const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: AppColors.primaryContainer,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _uploadingMedia ? 'Envoi...' : 'Changer photos',
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ],
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
                    _typeBienLabel(_listing.typeBien),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'HankenGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Compteur de photos et icône plein écran (si plusieurs images)
              if (images.isNotEmpty)
                Positioned(
                  bottom: 36,
                  right: _canEditPhotos ? 140 : 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _openImageViewer(images, currentIndex),
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
                      if (images.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'HankenGrotesk',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _heroPlaceholder() {
    return Container(
      color: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 64,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  // ── En-tête titre + prix ─────────────────────────────────────────────────
  Widget _buildHeader() {
    final pType =
        _listing.typeTransaction == 'location' ||
            _listing.typeTransaction == 'colocation'
        ? PropertyType.rent
        : PropertyType.sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _listing.title,
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
          formatPriceFcfa(_listing.price, pType),
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
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _listing.location,
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
        if (_listing.createdAt != null)
          Text(
            'Créée le ${_formatDate(_listing.createdAt!)}',
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
    if (_listing.surface != null) {
      pills.add(_Pill(Icons.square_foot_outlined, '${_listing.surface!.toInt()} m²'));
    }
    if (_listing.rooms != null) {
      pills.add(_Pill(Icons.meeting_room_outlined, '${_listing.rooms} pièces'));
    }
    if (_listing.bathrooms != null) {
      pills.add(_Pill(Icons.bathtub_outlined, '${_listing.bathrooms} SDB'));
    }

    final caracEntries = _listing.caracteristiques.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList();

    if (pills.isEmpty && caracEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Caractéristiques', style: TextStyle(
          fontFamily: 'Manrope', fontSize: 17,
          fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: 10),
        // Champs socles (surface, pièces, SDB)
        if (pills.isNotEmpty)
          Wrap(
            spacing: 10, runSpacing: 8,
            children: pills.map((p) => _buildPill(p.icon, p.label)).toList(),
          ),
        if (pills.isNotEmpty && caracEntries.isNotEmpty)
          const SizedBox(height: 12),
        // Champs dynamiques (caracteristiques JSON)
        if (caracEntries.isNotEmpty)
          _CaracteristiquesGrid(entries: caracEntries),
      ],
    );
  }

  Widget _buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'HankenGrotesk',
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
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
          _listing.description!,
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
      case 'appartement':      return 'Appartement';
      case 'villa':            return 'Villa';
      case 'maison':           return 'Maison';
      case 'terrain':          return 'Terrain';
      case 'bureau_commerce':  return 'Bureau / Commerce';
      case 'chambre_studio':   return 'Chambre / Studio';
      default:
        return raw
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
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
// Grille des caractéristiques dynamiques
// ─────────────────────────────────────────────────────────────────────────────

class _CaracteristiquesGrid extends StatelessWidget {
  final List<MapEntry<String, dynamic>> entries;
  const _CaracteristiquesGrid({required this.entries});

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'Oui' : 'Non';
    final s = value.toString();
    // Humaniser les slugs enum : bon_etat → Bon état
    return s
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  IconData _iconForKey(String key) {
    if (key.contains('chambre'))      return Icons.bed_rounded;
    if (key.contains('sdb') || key.contains('salle')) return Icons.bathtub_outlined;
    if (key.contains('salon'))        return Icons.chair_rounded;
    if (key.contains('surface') || key.contains('superficie')) return Icons.square_foot_outlined;
    if (key.contains('etage'))        return Icons.layers_rounded;
    if (key.contains('garage'))       return Icons.garage_rounded;
    if (key.contains('parking'))      return Icons.local_parking_rounded;
    if (key.contains('piscine'))      return Icons.pool_rounded;
    if (key.contains('jardin'))       return Icons.park_rounded;
    if (key.contains('meuble'))       return Icons.weekend_rounded;
    if (key.contains('eau'))          return Icons.water_drop_rounded;
    if (key.contains('electricite') || key.contains('électricité')) return Icons.bolt_rounded;
    if (key.contains('internet') || key.contains('fibre')) return Icons.wifi_rounded;
    if (key.contains('camera') || key.contains('securite')) return Icons.security_rounded;
    if (key.contains('climatisation')) return Icons.ac_unit_rounded;
    if (key.contains('etat'))         return Icons.star_outline_rounded;
    if (key.contains('ascenseur'))    return Icons.elevator_rounded;
    if (key.contains('vitrine'))      return Icons.store_outlined;
    if (key.contains('terrain') || key.contains('usage')) return Icons.landscape_rounded;
    if (key.contains('type'))         return Icons.category_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, i) {
        final entry = entries[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Icon(_iconForKey(entry.key), size: 16, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatLabel(entry.key),
                  style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 9,
                      fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.3),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(_formatValue(entry.value),
                  style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
                      fontWeight: FontWeight.w700, color: AppColors.primary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tracker de statut visuel (timeline)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusTracker extends StatelessWidget {
  final String statut;
  const _StatusTracker({required this.statut});

  static const _steps = [
    _StepDef('Soumis', 'en_attente', Icons.upload_rounded),
    _StepDef('Vérification', 'en_verification', Icons.search_rounded),
    _StepDef('Approuvé', 'valide', Icons.check_circle_outline_rounded),
    _StepDef('Publié', 'publie', Icons.verified_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isRejected = statut == 'rejete';
    final isArchived = statut == 'archive';

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
                color: isRejected
                    ? AppColors.error
                    : AppColors.primaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suivi de l\'annonce',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isRejected
                      ? AppColors.error
                      : AppColors.primaryContainer,
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
                final idx = e.key;
                final step = e.value;
                final isDone = idx < activeIndex;
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
                      color: AppColors.primaryContainer.withValues(alpha: 0.35),
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
            color: isRejected ? AppColors.error : AppColors.outline,
            size: 20,
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
              const SizedBox(height: 4),
              Text(
                isRejected
                    ? 'Votre annonce n\'a pas été validée. Veuillez corriger les problèmes indiqués.'
                    : 'Cette annonce a été archivée et n\'est plus visible par les utilisateurs.',
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
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Visionneuse plein écran avec défilement entre les images
// ─────────────────────────────────────────────────────────────────────────────
class _ListingImageViewerPage extends StatefulWidget {
  final List<PropertyMedia> images;
  final int initialIndex;

  const _ListingImageViewerPage({required this.images, required this.initialIndex});

  @override
  State<_ListingImageViewerPage> createState() => _ListingImageViewerPageState();
}

class _ListingImageViewerPageState extends State<_ListingImageViewerPage> {
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

            // Bouton fermer et compteur
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
