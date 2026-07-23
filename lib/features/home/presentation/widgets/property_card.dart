import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/property_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/di/service_locator.dart';

class PropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  String _formatPrice(double price, PropertyType type) =>
      formatPriceFcfa(price, type);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 272,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56A0).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PropertyCardMedia(property: property),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix
                  Text(
                    _formatPrice(property.price, property.type),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Titre
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    property.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Caractéristiques
                  Row(
                    children: [
                      if (property.rooms != null)
                        _InfoChip(
                          icon: Icons.bed_outlined,
                          label: '${property.rooms}',
                        ),
                      if (property.rooms != null) const SizedBox(width: 10),
                      if (property.surface != null)
                        _InfoChip(
                          icon: Icons.straighten_outlined,
                          label: '${property.surface!.toInt()}m²',
                        ),
                      if (property.surface != null) const SizedBox(width: 10),
                      Flexible(
                        child: _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: _shortLocation(property.location),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortLocation(String location) {
    // Affiche seulement la ville (avant la première virgule ou les 20 premiers caractères)
    final parts = location.split(',');
    final first = parts.first.trim();
    return first.length > 20 ? '${first.substring(0, 18)}…' : first;
  }
}

class _PropertyCardMedia extends StatefulWidget {
  final PropertyEntity property;

  const _PropertyCardMedia({required this.property});

  @override
  State<_PropertyCardMedia> createState() => _PropertyCardMediaState();
}

class _PropertyCardMediaState extends State<_PropertyCardMedia> {
  late PageController _pageController;
  Timer? _timer;
  int _absolutePage = 0;
  int _currentPage = 0;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    
    // Extraire les images
    _imageUrls = widget.property.medias
        .where((m) => m.type == 'image')
        .map((m) => m.url)
        .toList();

    // Si pas de médias trouvés mais imageUrl est présent (fallback)
    if (_imageUrls.isEmpty &&
        widget.property.imageUrl != null &&
        widget.property.imageUrl!.isNotEmpty) {
      _imageUrls.add(widget.property.imageUrl!);
    }

    // On commence à un index très grand pour permettre le défilement infini dans les deux sens (si le swipe est activé)
    _absolutePage = _imageUrls.isNotEmpty ? _imageUrls.length * 1000 : 0;
    _pageController = PageController(initialPage: _absolutePage);

    if (_imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _absolutePage++;
          _pageController.animateToPage(
            _absolutePage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = widget.property.videoUrl != null && widget.property.videoUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image(s) de couverture
            if (_imageUrls.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Désactiver le scroll manuel pour ne pas interférer avec le swipe de la carte
                onPageChanged: (index) {
                  setState(() {
                    _absolutePage = index;
                    _currentPage = index % _imageUrls.length;
                  });
                },
                itemBuilder: (context, index) {
                  final realIndex = index % _imageUrls.length;
                  return Image.network(
                    _imageUrls[realIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(),
                  );
                },
              )
            else
              _placeholder(),

            // Indicateurs de page (points) si plus d'une image
            if (_imageUrls.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_imageUrls.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      width: _currentPage == index ? 16 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

            // Badge vidéo
            if (hasVideo)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Vidéo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bouton favori
            Positioned(
              top: 8,
              right: 8,
              child: ListenableBuilder(
                listenable: ServiceLocator.instance.favoritesController,
                builder: (context, _) {
                  final ctrl = ServiceLocator.instance.favoritesController;
                  final isFav = ctrl.isFavorite(widget.property.id);

                  return GestureDetector(
                    onTap: () => ctrl.toggleFavorite(widget.property.id),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.error : AppColors.primary,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Badge catégorie
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.property.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Icon(
        Icons.home_outlined,
        color: AppColors.outline,
        size: 40,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
