import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import 'step4_summary_page.dart';

/// Étape 3 / 4 — Chargement des documents justificatifs.
///
/// Corrections :
/// - Chaque bouton a son propre état de chargement (pas de spinner global)
/// - PDF uniquement pour tous les documents
/// - Multi-fichiers possibles par type (liste de fichiers)
/// - Champ "Autres documents" pour fichiers libres
class Step3DocumentsPage extends StatefulWidget {
  final PublishController controller;

  const Step3DocumentsPage({super.key, required this.controller});

  @override
  State<Step3DocumentsPage> createState() => _Step3DocumentsPageState();
}

class _Step3DocumentsPageState extends State<Step3DocumentsPage> {
  // Chaque clé correspond à un champ de document — état de chargement indépendant
  final Map<String, bool> _loadingStates = {
    'titleDeed':   false,
    'idDocument':  false,
    'cadastral':   false,
    'other':       false,
  };

  Future<void> _pickDocument(String type, {bool allowMultiple = false}) async {
    if (_loadingStates[type] == true) return;
    setState(() => _loadingStates[type] = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        // PDF uniquement pour tous les documents
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: allowMultiple,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;

      final paths = result.files
          .map((f) => f.path ?? '')
          .where((p) => p.isNotEmpty)
          .toList();

      switch (type) {
        case 'titleDeed':
          // Remplace ou ajoute le premier fichier (un seul titre foncier)
          widget.controller.setTitleDeed(paths.first);
        case 'idDocument':
          widget.controller.setIdDocument(paths.first);
        case 'cadastral':
          widget.controller.setCadastralPlan(paths.first);
        case 'other':
          // Ajoute tous les fichiers sélectionnés aux "autres documents"
          for (final path in paths) {
            widget.controller.addOtherDocument(path);
          }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de sélectionner le fichier. Vérifiez les permissions.',
              style: TextStyle(fontFamily: 'HankenGrotesk'),
            ),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingStates[type] = false);
    }
  }

  void _removeDocument(String type, {int? index}) {
    switch (type) {
      case 'titleDeed':
        widget.controller.setTitleDeed(null);
      case 'idDocument':
        widget.controller.setIdDocument(null);
      case 'cadastral':
        widget.controller.setCadastralPlan(null);
      case 'other':
        if (index != null) widget.controller.removeOtherDocument(index);
    }
  }

  void _onNext() {
    final draft = widget.controller.draft;
    if (draft.titleDeedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le titre foncier (PDF) est requis.',
            style: TextStyle(fontFamily: 'HankenGrotesk'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step4SummaryPage(controller: widget.controller),
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
          title: 'Documents',
          currentStep: 2,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final draft = widget.controller.draft;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Bandeau de progression 75% ─────────────────────
                  _ProgressHeader(),
                  const SizedBox(height: 24),

                  // ── Note format ────────────────────────────────────
                  _FormatBanner(),
                  const SizedBox(height: 20),

                  // ── Titre foncier ──────────────────────────────────
                  _DocumentRow(
                    icon: Icons.description_outlined,
                    label: 'Titre foncier / Acte de propriété',
                    isRequired: true,
                    filePath: draft.titleDeedPath,
                    isLoading: _loadingStates['titleDeed']!,
                    onUpload: () => _pickDocument('titleDeed'),
                    onRemove: () => _removeDocument('titleDeed'),
                  ),
                  const SizedBox(height: 12),

                  // ── Pièce d'identité ───────────────────────────────
                  _DocumentRow(
                    icon: Icons.badge_outlined,
                    label: "Pièce d'identité du propriétaire",
                    isRequired: true,
                    filePath: draft.idDocumentPath,
                    isLoading: _loadingStates['idDocument']!,
                    onUpload: () => _pickDocument('idDocument'),
                    onRemove: () => _removeDocument('idDocument'),
                  ),
                  const SizedBox(height: 12),

                  // ── Plan cadastral ────────────────────────────────
                  _DocumentRow(
                    icon: Icons.map_outlined,
                    label: 'Plan cadastral (optionnel)',
                    isRequired: false,
                    filePath: draft.cadastralPlanPath,
                    isLoading: _loadingStates['cadastral']!,
                    onUpload: () => _pickDocument('cadastral'),
                    onRemove: () => _removeDocument('cadastral'),
                  ),
                  const SizedBox(height: 20),

                  // ── Autres documents (multi-sélection) ─────────────
                  _SectionTitle(
                    icon: Icons.folder_open_outlined,
                    title: 'Autres documents',
                    subtitle: 'Optionnel — ajoutez autant de fichiers que nécessaire',
                  ),
                  const SizedBox(height: 12),

                  // Liste des autres fichiers déjà ajoutés
                  ...draft.otherDocumentPaths.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _OtherDocItem(
                        path: e.value,
                        index: e.key,
                        onRemove: () => _removeDocument('other', index: e.key),
                      ),
                    );
                  }),

                  // Bouton ajouter d'autres fichiers
                  _AddMoreButton(
                    isLoading: _loadingStates['other']!,
                    onTap: () => _pickDocument('other', allowMultiple: true),
                  ),
                  const SizedBox(height: 24),

                  // ── Note délai ─────────────────────────────────────
                  _InfoNote(),
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

class _ProgressHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documents justificatifs',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Étape 3 sur 4',
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                '75%',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded,
              color: AppColors.primaryContainer, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Format accepté : PDF uniquement.',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF001B3D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryContainer, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRequired;
  final String? filePath;
  final bool isLoading;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocumentRow({
    required this.icon,
    required this.label,
    required this.isRequired,
    required this.filePath,
    required this.isLoading,
    required this.onUpload,
    required this.onRemove,
  });

  bool get _hasFile => filePath != null && filePath!.isNotEmpty;

  String get _fileName {
    if (filePath == null) return '';
    return filePath!.split(RegExp(r'[/\\]')).last;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasFile
              ? const Color(0xFF006344).withValues(alpha: 0.5)
              : AppColors.outlineVariant,
        ),
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
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hasFile
                  ? const Color(0xFF86F8C5).withValues(alpha: 0.3)
                  : const Color(0xFFD6E3FF).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _hasFile ? Icons.check_circle_outline_rounded : icon,
              color: _hasFile
                  ? const Color(0xFF004931)
                  : AppColors.primaryContainer,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Label + statut
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                if (_hasFile)
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded,
                          color: Color(0xFF004931), size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _fileName,
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            color: Color(0xFF004931),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  _StatusChip(label: isRequired ? 'À fournir' : 'Optionnel'),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action button — état de chargement indépendant
          if (isLoading)
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (_hasFile)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 18),
              ),
            )
          else
            GestureDetector(
              onTap: onUpload,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.upload_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
        ],
      ),
    );
  }
}

/// Item pour un fichier de la liste "Autres documents"
class _OtherDocItem extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onRemove;

  const _OtherDocItem({
    required this.path,
    required this.index,
    required this.onRemove,
  });

  String get _fileName => path.split(RegExp(r'[/\\]')).last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF006344).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded,
              color: Color(0xFF004931), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _fileName,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onBackground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Bouton "Ajouter d'autres documents"
class _AddMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AddMoreButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded,
                      color: AppColors.primaryContainer, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter un autre document (PDF)',
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isOptional = label == 'Optionnel';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOptional
            ? AppColors.surfaceContainer
            : const Color(0xFFDCE4EB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOptional
              ? AppColors.onSurfaceVariant
              : AppColors.primaryContainer,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: const BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Votre bien sera examiné sous 48-72h par notre équipe après la soumission finale.',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
