import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import 'step3_documents_page.dart';

/// Étape 2 / 4 — Ajout de photos et vidéos du bien.
class Step2MediaPage extends StatefulWidget {
  final PublishController controller;

  const Step2MediaPage({super.key, required this.controller});

  @override
  State<Step2MediaPage> createState() => _Step2MediaPageState();
}

class _Step2MediaPageState extends State<Step2MediaPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingMedia = false;

  Future<void> _pickImages() async {
    if (_isPickingMedia) return;
    setState(() => _isPickingMedia = true);
    try {
      final remaining = 10 - widget.controller.draft.mediaPaths.length;
      if (remaining <= 0) {
        _showSnack('Vous avez atteint le maximum de 10 médias.');
        return;
      }
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        limit: remaining,
      );
      for (final img in picked) {
        widget.controller.addMediaPath(img.path);
      }
    } catch (e) {
      _showSnack('Impossible d\'accéder à la galerie. Vérifiez les permissions.');
    } finally {
      setState(() => _isPickingMedia = false);
    }
  }

  Future<void> _pickVideo() async {
    if (_isPickingMedia) return;
    if (widget.controller.draft.mediaPaths.length >= 10) {
      _showSnack('Vous avez atteint le maximum de 10 médias.');
      return;
    }
    setState(() => _isPickingMedia = true);
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (video != null) {
        // Vérification du format vidéo côté client
        final path = video.path.toLowerCase();
        const formats = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp'];
        final isValid = formats.any((ext) => path.endsWith(ext));
        if (!isValid) {
          _showSnack(
              'Format non supporté. Utilisez : MP4, MOV, AVI, MKV, WEBM.');
          return;
        }
        widget.controller.addMediaPath(video.path);
      }
    } catch (e) {
      _showSnack('Impossible d\'accéder à la vidéo. Vérifiez les permissions.');
    } finally {
      setState(() => _isPickingMedia = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'HankenGrotesk')),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onNext() {
    final count = widget.controller.draft.mediaPaths.length;
    if (count < 3) {
      _showSnack('Ajoutez au moins 3 photos pour continuer.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step3DocumentsPage(controller: widget.controller),
      ),
    );
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
          title: 'Photos & Vidéos',
          currentStep: 1,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final paths = widget.controller.draft.mediaPaths;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Zone d'upload ──────────────────────────────────
                  _UploadZone(
                    isLoading: _isPickingMedia,
                    onPickImages: _pickImages,
                    onPickVideo: _pickVideo,
                    mediaCount: paths.length,
                  ),
                  const SizedBox(height: 20),

                  if (paths.isNotEmpty) ...[
                    // ── Header grille ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vos médias (${paths.length}/10)',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground,
                          ),
                        ),
                        Text(
                          'Appuyez sur × pour supprimer',
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Grille de médias ────────────────────────────────
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paths.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return _MediaCard(
                          path: paths[index],
                          isPrimary: index == 0,
                          onRemove: () =>
                              widget.controller.removeMediaAt(index),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Conseil expert ─────────────────────────────────
                  _ExpertTip(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: PublishBottomBar(
          nextLabel: 'Suivant',
          onBack: () => Navigator.of(context).pop(),
          onNext: _onNext,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _UploadZone extends StatelessWidget {
  final bool isLoading;
  final int mediaCount;
  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;

  const _UploadZone({
    required this.isLoading,
    required this.mediaCount,
    required this.onPickImages,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = mediaCount >= 10;
    return Column(
      children: [
        // Zone principale photos
        GestureDetector(
          onTap: isFull ? null : onPickImages,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: isFull
                  ? AppColors.surfaceContainer
                  : const Color(0xFFD6E3FF).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFull
                    ? AppColors.outlineVariant
                    : AppColors.primaryContainer,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primaryContainer,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isFull ? 'Maximum atteint (10/10)' : 'Ajouter des photos',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isFull
                          ? AppColors.onSurfaceVariant
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Minimum 3, maximum 10 médias',
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (!isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Parcourir la galerie',
                        style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Bouton vidéo
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isFull ? null : onPickVideo,
            icon: const Icon(Icons.videocam_rounded,
                color: AppColors.primary, size: 20),
            label: const Text(
              'Ajouter une vidéo',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryContainer),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback onRemove;

  const _MediaCard({
    required this.path,
    required this.isPrimary,
    required this.onRemove,
  });

  bool get _isVideo {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Aperçu
          if (_isVideo)
            Container(
              color: AppColors.surfaceContainer,
              child: const Center(
                child: Icon(Icons.play_circle_outline_rounded,
                    color: AppColors.primaryContainer, size: 48),
              ),
            )
          else
            Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.outline),
              ),
            ),

          // Overlay léger
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),

          // Badge "Photo principale"
          if (isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF004931),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Principale',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'HankenGrotesk',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Badge vidéo
          if (_isVideo)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIDÉO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
              ),
            ),

          // Bouton suppression
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.shade700.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.primaryContainer, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil de l\'expert',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Photos en lumière naturelle = plus de visites. Prenez vos clichés en milieu de journée pour un rendu optimal.',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 12,
                    color: Color(0xFF001B3D),
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
