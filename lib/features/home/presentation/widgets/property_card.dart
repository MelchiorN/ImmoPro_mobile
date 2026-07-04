import 'package:flutter/material.dart';
import '../../domain/entities/property_entity.dart';
import '../../../../core/theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  String _formatPrice(double price, PropertyType type) {
    final formatted = price >= 1000
        ? '${(price / 1000).toStringAsFixed(0)} k€'
        : '${price.toStringAsFixed(0)} €';
    return type == PropertyType.rent ? '$formatted/mois' : formatted;
  }

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
              color: const Color(0xFF1A56A0).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Vidéo avec badges
            _PropertyCardMedia(property: property),
            // Infos
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
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    property.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Caractéristiques
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.bed_outlined,
                        label: '${property.rooms}',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.straighten_outlined,
                        label: '${property.surface.toInt()}m²',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: property.location,
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
}

class _PropertyCardMedia extends StatelessWidget {
  final PropertyEntity property;

  const _PropertyCardMedia({required this.property});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de couverture
            Image.network(
              property.imageUrl,
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
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.outline,
                  size: 40,
                ),
              ),
            ),
            // Badge vidéo si disponible
            if (property.videoUrl != null)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 14,
                      ),
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
            // Badge Vérifié
            if (property.isVerified)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006344),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: Color(0xFF6FE1AF),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Vérifié ✓',
                        style: TextStyle(
                          color: Color(0xFF6FE1AF),
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
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
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
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
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
