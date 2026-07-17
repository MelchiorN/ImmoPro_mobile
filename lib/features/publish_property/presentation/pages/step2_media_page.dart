import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/constants/file_limits.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import 'step3_documents_page.dart';

/// Étape 2 / 3 — Ajout de photos et vidéos avec validation de format et taille.
class Step2MediaPage extends StatefulWidget {
  final PublishController controller;
  const Step2MediaPage({super.key, required this.controller});
  @override
  State<Step2MediaPage> createState() => _Step2MediaPageState();
}

class _Step2MediaPageState extends State<Step2MediaPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  // ── Taille totale actuelle ────────────────────────────────────────────────
  int get _totalBytes {
    int total = 0;
    for (final path in widget.controller.draft.mediaPaths) {
      try { total += File(path).lengthSync(); } catch (_) {}
    }
    return total;
  }

  // ── Pick photos ───────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    if (_isPicking) return;
    final remaining = FileLimit.maxMediaCount -
        widget.controller.draft.mediaPaths.length;
    if (remaining <= 0) {
      _snack('Maximum ${FileLimit.maxMediaCount} médias atteint.');
      return;
    }
    setState(() => _isPicking = true);
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85, limit: remaining);
      for (final img in picked) {
        _addMediaWithValidation(img.path, isVideo: false);
      }
    } catch (_) {
      _snack('Impossible d\'accéder à la galerie.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ── Pick vidéo ────────────────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    if (_isPicking) return;
    if (widget.controller.draft.mediaPaths.length >= FileLimit.maxMediaCount) {
      _snack('Maximum ${FileLimit.maxMediaCount} médias atteint.');
      return;
    }
    setState(() => _isPicking = true);
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (video != null) _addMediaWithValidation(video.path, isVideo: true);
    } catch (_) {
      _snack('Impossible d\'accéder à la vidéo.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ── Validation + ajout ────────────────────────────────────────────────────
  void _addMediaWithValidation(String path, {required bool isVideo}) {
    // 1. Vérifier le format
    if (isVideo && !FileLimit.isValidVideo(path)) {
      _snack('Format vidéo non supporté. Acceptés : ${FileLimit.videoExtensions.join(', ')}');
      return;
    }
    if (!isVideo && !FileLimit.isValidPhoto(path)) {
      _snack('Format photo non supporté. Acceptés : ${FileLimit.photoExtensions.join(', ')}');
      return;
    }

    // 2. Vérifier la taille unitaire
    int fileSize = 0;
    try { fileSize = File(path).lengthSync(); } catch (_) {}
    final maxUnit = isVideo ? FileLimit.maxVideoBytes : FileLimit.maxPhotoBytes;
    if (fileSize > maxUnit) {
      _snack('${isVideo ? "Vidéo" : "Photo"} trop lourde. Max : ${FileLimit.formatSize(maxUnit)}');
      return;
    }

    // 3. Vérifier la taille totale
    if (_totalBytes + fileSize > FileLimit.maxTotalMediaBytes) {
      _snack('Taille totale dépassée. Max : ${FileLimit.formatSize(FileLimit.maxTotalMediaBytes)}');
      return;
    }

    widget.controller.addMediaPath(path);
  }

  void _onNext() {
    final count = widget.controller.draft.mediaPaths.length;
    if (count < FileLimit.minMediaCount) {
      _snack('Ajoutez au moins ${FileLimit.minMediaCount} médias pour continuer.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Step3DocumentsPage(controller: widget.controller),
    ));
  }

  void _snack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'HankenGrotesk')),
      backgroundColor: isError ? AppColors.error : AppColors.primaryContainer,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PublishAppBar(
          title: 'Photos & Vidéos', currentStep: 1, totalSteps: 3,
          onBack: () => Navigator.of(context).pop()),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final paths = widget.controller.draft.mediaPaths;
            final totalBytes = _totalBytes;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Résumé taille totale ──────────────────────────────
                  _SizeSummaryBar(
                    currentBytes: totalBytes,
                    maxBytes: FileLimit.maxTotalMediaBytes,
                    count: paths.length,
                    maxCount: FileLimit.maxMediaCount,
                  ),
                  const SizedBox(height: 16),
                  // ── Règles ────────────────────────────────────────────
                  _RulesBanner(),
                  const SizedBox(height: 16),
                  // ── Zone d'upload ─────────────────────────────────────
                  _UploadZone(
                    isLoading: _isPicking,
                    mediaCount: paths.length,
                    onPickImages: _pickImages,
                    onPickVideo: _pickVideo,
                  ),
                  const SizedBox(height: 20),
                  // ── Grille de médias ──────────────────────────────────
                  if (paths.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vos médias (${paths.length}/${FileLimit.maxMediaCount})',
                          style: const TextStyle(fontFamily: 'Manrope', fontSize: 16,
                              fontWeight: FontWeight.w700, color: AppColors.onBackground)),
                        Text(FileLimit.formatSize(totalBytes),
                          style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
                              color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paths.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10,
                        mainAxisSpacing: 10, childAspectRatio: 1),
                      itemBuilder: (context, i) => _MediaCard(
                        path: paths[i],
                        isPrimary: i == 0,
                        onRemove: () => widget.controller.removeMediaAt(i),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _ExpertTip(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: PublishBottomBar(
          nextLabel: 'Suivant', totalSteps: 3,
          onBack: () => Navigator.of(context).pop(),
          onNext: _onNext,
        ),
      ),
    );
  }
}

// ─── Widgets internes ─────────────────────────────────────────────────────────

class _SizeSummaryBar extends StatelessWidget {
  final int currentBytes, maxBytes, count, maxCount;
  const _SizeSummaryBar({required this.currentBytes, required this.maxBytes,
      required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final ratio = (currentBytes / maxBytes).clamp(0.0, 1.0);
    final isNearFull = ratio > 0.8;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isNearFull
            ? AppColors.error.withValues(alpha: 0.4)
            : AppColors.outlineVariant),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$count / $maxCount médias',
              style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.onBackground)),
            Text('${FileLimit.formatSize(currentBytes)} / ${FileLimit.formatSize(maxBytes)}',
              style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
                  color: isNearFull ? AppColors.error : AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
                isNearFull ? AppColors.error : AppColors.primaryContainer),
          ),
        ),
        if (isNearFull) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.error),
            const SizedBox(width: 4),
            Text('Espace presque épuisé',
              style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11,
                  color: AppColors.error)),
          ]),
        ],
      ]),
    );
  }
}

class _RulesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primaryContainer, size: 16),
            SizedBox(width: 6),
            Text('Règles des médias', style: TextStyle(fontFamily: 'Manrope',
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
          ]),
          const SizedBox(height: 6),
          _Rule('Photos : max ${FileLimit.formatSize(FileLimit.maxPhotoBytes)} / fichier '
              '(${FileLimit.photoExtensions.join(", ")})'),
          _Rule('Vidéos : max ${FileLimit.formatSize(FileLimit.maxVideoBytes)} / fichier '
              '(${FileLimit.videoExtensions.join(", ")})'),
          _Rule('Total : max ${FileLimit.formatSize(FileLimit.maxTotalMediaBytes)} '
              '— min ${FileLimit.minMediaCount} médias requis'),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;
  const _Rule(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(color: AppColors.primaryContainer, fontSize: 12)),
      Expanded(child: Text(text, style: const TextStyle(fontFamily: 'HankenGrotesk',
          fontSize: 12, color: Color(0xFF001B3D)))),
    ]),
  );
}

class _UploadZone extends StatelessWidget {
  final bool isLoading;
  final int mediaCount;
  final VoidCallback onPickImages, onPickVideo;
  const _UploadZone({required this.isLoading, required this.mediaCount,
      required this.onPickImages, required this.onPickVideo});

  @override
  Widget build(BuildContext context) {
    final isFull = mediaCount >= FileLimit.maxMediaCount;
    return Column(children: [
      GestureDetector(
        onTap: isFull ? null : onPickImages,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: isFull ? AppColors.surfaceContainer
                : const Color(0xFFD6E3FF).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFull ? AppColors.outlineVariant : AppColors.primaryContainer,
              width: 1.5,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_camera_rounded, size: 36,
                      color: isFull ? AppColors.onSurfaceVariant : AppColors.primaryContainer),
                  ),
                  const SizedBox(height: 12),
                  Text(isFull ? 'Maximum atteint ($mediaCount/${FileLimit.maxMediaCount})'
                      : 'Ajouter des photos',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isFull ? AppColors.onSurfaceVariant : AppColors.primary)),
                  if (!isFull) ...[
                    const SizedBox(height: 6),
                    Text('Min ${FileLimit.minMediaCount} · max ${FileLimit.maxMediaCount} médias',
                      style: const TextStyle(fontFamily: 'HankenGrotesk',
                          fontSize: 13, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(24)),
                      child: const Text('Parcourir la galerie',
                        style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 14,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ]),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: isFull ? null : onPickVideo,
          icon: const Icon(Icons.videocam_rounded, color: AppColors.primary, size: 20),
          label: Text('Ajouter une vidéo (max ${FileLimit.formatSize(FileLimit.maxVideoBytes)})',
            style: const TextStyle(fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w600, color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryContainer),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    ]);
  }
}

class _MediaCard extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback onRemove;
  const _MediaCard({required this.path, required this.isPrimary, required this.onRemove});

  bool get _isVideo {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  String get _fileSize {
    try { return FileLimit.formatSize(File(path).lengthSync()); } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(fit: StackFit.expand, children: [
        _isVideo
            ? Container(color: AppColors.surfaceContainer,
                child: const Center(child: Icon(Icons.play_circle_outline_rounded,
                    color: AppColors.primaryContainer, size: 48)))
            : Image.file(File(path), fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.outline))),
        Container(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.3)]))),
        if (isPrimary)
          Positioned(top: 8, left: 8, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF004931),
                borderRadius: BorderRadius.circular(24)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star_rounded, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text('Principale', style: TextStyle(color: Colors.white,
                  fontFamily: 'HankenGrotesk', fontSize: 10, fontWeight: FontWeight.w700)),
            ]),
          )),
        // Taille du fichier
        if (_fileSize.isNotEmpty)
          Positioned(bottom: 8, left: 8, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: Text(_fileSize, style: const TextStyle(color: Colors.white,
                fontSize: 9, fontWeight: FontWeight.w600, fontFamily: 'HankenGrotesk')),
          )),
        if (_isVideo)
          Positioned(bottom: 8, right: 36, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: const Text('VIDÉO', style: TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'HankenGrotesk')),
          )),
        Positioned(top: 6, right: 6, child: GestureDetector(
          onTap: onRemove,
          child: Container(width: 28, height: 28,
            decoration: BoxDecoration(color: Colors.red.shade700.withValues(alpha: 0.9),
                shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16)),
        )),
      ]),
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
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryContainer, size: 22),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Conseil de l\'expert', style: TextStyle(fontFamily: 'Manrope', fontSize: 13,
              fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
          SizedBox(height: 4),
          Text('Photos en lumière naturelle = plus de visites. Prenez vos clichés en milieu de journée.',
            style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
                color: Color(0xFF001B3D), height: 1.5)),
        ])),
      ]),
    );
  }
}
