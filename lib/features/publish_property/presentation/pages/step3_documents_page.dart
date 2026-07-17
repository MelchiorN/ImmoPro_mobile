import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/constants/file_limits.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import 'step4_summary_page.dart';

/// Étape 3 / 3 — Documents justificatifs avec validation de taille.
class Step3DocumentsPage extends StatefulWidget {
  final PublishController controller;
  const Step3DocumentsPage({super.key, required this.controller});
  @override
  State<Step3DocumentsPage> createState() => _Step3DocumentsPageState();
}

class _Step3DocumentsPageState extends State<Step3DocumentsPage> {
  final Map<String, bool> _loading = {
    'id': false, 'justif': false, 'cadastral': false, 'other': false,
  };

  // ── Taille totale documents ───────────────────────────────────────────────
  int get _totalDocBytes {
    int total = 0;
    final draft = widget.controller.draft;
    for (final p in [
      draft.idDocumentPath,
      draft.justificatifProprietePath,
      draft.cadastralPlanPath,
      ...draft.otherDocumentPaths,
    ]) {
      if (p != null) {
        try { total += File(p).lengthSync(); } catch (_) {}
      }
    }
    return total;
  }

  // ── Sélection d'un document ───────────────────────────────────────────────
  Future<void> _pick(String type, {bool multi = false}) async {
    if (_loading[type] == true) return;
    setState(() => _loading[type] = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: FileLimit.documentExtensions,
        allowMultiple: multi,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      for (final file in result.files) {
        final path = file.path ?? '';
        if (path.isEmpty) continue;

        // 1. Format
        if (!FileLimit.isValidDocument(path)) {
          _snack('Format non accepté. Utilisez : ${FileLimit.documentExtensions.join(", ")}');
          continue;
        }
        // 2. Taille unitaire
        int size = 0;
        try { size = File(path).lengthSync(); } catch (_) {}
        if (size > FileLimit.maxDocumentBytes) {
          _snack('Document trop lourd. Max : ${FileLimit.formatSize(FileLimit.maxDocumentBytes)}');
          continue;
        }
        // 3. Taille totale
        if (_totalDocBytes + size > FileLimit.maxTotalDocumentBytes) {
          _snack('Taille totale documents dépassée. Max : '
              '${FileLimit.formatSize(FileLimit.maxTotalDocumentBytes)}');
          continue;
        }

        switch (type) {
          case 'id':       widget.controller.setIdDocument(path);           break;
          case 'justif':   widget.controller.setJustificatifPropriete(path); break;
          case 'cadastral': widget.controller.setCadastralPlan(path);       break;
          case 'other':    widget.controller.addOtherDocument(path);        break;
        }
      }
    } catch (_) {
      _snack('Impossible de sélectionner le fichier. Vérifiez les permissions.');
    } finally {
      if (mounted) setState(() => _loading[type] = false);
    }
  }

  void _remove(String type, {int? index}) {
    switch (type) {
      case 'id':       widget.controller.setIdDocument(null);            break;
      case 'justif':   widget.controller.setJustificatifPropriete(null); break;
      case 'cadastral': widget.controller.setCadastralPlan(null);        break;
      case 'other':
        if (index != null) widget.controller.removeOtherDocument(index);
        break;
    }
  }

  void _onNext() {
    final draft = widget.controller.draft;
    if (draft.idDocumentPath == null) {
      _snack('La pièce d\'identité est requise.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Step4SummaryPage(controller: widget.controller),
    ));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'HankenGrotesk')),
      backgroundColor: AppColors.error,
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
          title: 'Documents', currentStep: 2, totalSteps: 3,
          onBack: () => Navigator.of(context).pop()),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final draft = widget.controller.draft;
            final totalBytes = _totalDocBytes;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Barre de taille totale ────────────────────────────
                  _DocSizeSummary(
                    currentBytes: totalBytes,
                    maxBytes: FileLimit.maxTotalDocumentBytes,
                  ),
                  const SizedBox(height: 16),
                  // ── Règles ────────────────────────────────────────────
                  _DocRulesBanner(),
                  const SizedBox(height: 20),
                  // ── Pièce d'identité (obligatoire) ────────────────────
                  _DocumentRow(
                    icon: Icons.badge_outlined,
                    label: 'Pièce d\'identité du propriétaire',
                    isRequired: true,
                    filePath: draft.idDocumentPath,
                    isLoading: _loading['id']!,
                    onUpload: () => _pick('id'),
                    onRemove: () => _remove('id'),
                  ),
                  const SizedBox(height: 12),
                  // ── Justificatif de propriété ─────────────────────────
                  _DocumentRow(
                    icon: Icons.home_work_outlined,
                    label: 'Justificatif de propriété',
                    subtitle: 'Attestation, quittance d\'impôt, permis d\'habiter…',
                    isRequired: false,
                    filePath: draft.justificatifProprietePath,
                    isLoading: _loading['justif']!,
                    onUpload: () => _pick('justif'),
                    onRemove: () => _remove('justif'),
                  ),
                  const SizedBox(height: 12),
                  // ── Plan cadastral ────────────────────────────────────
                  _DocumentRow(
                    icon: Icons.map_outlined,
                    label: 'Plan cadastral',
                    isRequired: false,
                    filePath: draft.cadastralPlanPath,
                    isLoading: _loading['cadastral']!,
                    onUpload: () => _pick('cadastral'),
                    onRemove: () => _remove('cadastral'),
                  ),
                  const SizedBox(height: 20),
                  // ── Autres documents ──────────────────────────────────
                  Row(children: [
                    const Icon(Icons.folder_open_outlined,
                        color: AppColors.primaryContainer, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Autres documents', style: TextStyle(fontFamily: 'Manrope',
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.onBackground)),
                        Text('Optionnel — tout document utile à la vérification',
                          style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11,
                              color: AppColors.onSurfaceVariant)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 12),
                  ...draft.otherDocumentPaths.asMap().entries.map((e) =>
                    Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: _OtherDocItem(
                        path: e.value, index: e.key,
                        onRemove: () => _remove('other', index: e.key),
                      )),
                  ),
                  _AddMoreButton(
                    isLoading: _loading['other']!,
                    onTap: () => _pick('other', multi: true),
                  ),
                  const SizedBox(height: 24),
                  _InfoNote(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: PublishBottomBar(
          nextLabel: 'Récapitulatif', totalSteps: 3,
          onBack: () => Navigator.of(context).pop(),
          onNext: _onNext,
        ),
      ),
    );
  }
}

// ─── Widgets internes ─────────────────────────────────────────────────────────

class _DocSizeSummary extends StatelessWidget {
  final int currentBytes, maxBytes;
  const _DocSizeSummary({required this.currentBytes, required this.maxBytes});
  @override
  Widget build(BuildContext context) {
    final ratio = (currentBytes / maxBytes).clamp(0.0, 1.0);
    final isNearFull = ratio > 0.8;
    if (currentBytes == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isNearFull
            ? AppColors.error.withValues(alpha: 0.4) : AppColors.outlineVariant),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Taille totale documents', style: TextStyle(
              fontFamily: 'HankenGrotesk', fontSize: 13,
              fontWeight: FontWeight.w600, color: AppColors.onBackground)),
          Text('${FileLimit.formatSize(currentBytes)} / ${FileLimit.formatSize(maxBytes)}',
            style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
                color: isNearFull ? AppColors.error : AppColors.onSurfaceVariant)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio, minHeight: 6,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
                isNearFull ? AppColors.error : AppColors.primaryContainer),
          ),
        ),
      ]),
    );
  }
}

class _DocRulesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.description_outlined, color: AppColors.primaryContainer, size: 16),
          SizedBox(width: 6),
          Text('Formats et limites', style: TextStyle(fontFamily: 'Manrope', fontSize: 13,
              fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
        ]),
        const SizedBox(height: 6),
        Text('• Formats acceptés : ${FileLimit.documentExtensions.join(", ")}',
          style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
              color: Color(0xFF001B3D))),
        Text('• Taille max par fichier : ${FileLimit.formatSize(FileLimit.maxDocumentBytes)}',
          style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
              color: Color(0xFF001B3D))),
        Text('• Total max tous documents : ${FileLimit.formatSize(FileLimit.maxTotalDocumentBytes)}',
          style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
              color: Color(0xFF001B3D))),
      ]),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isRequired;
  final String? filePath;
  final bool isLoading;
  final VoidCallback onUpload, onRemove;

  const _DocumentRow({required this.icon, required this.label, this.subtitle,
      required this.isRequired, required this.filePath,
      required this.isLoading, required this.onUpload, required this.onRemove});

  bool get _has => filePath != null && filePath!.isNotEmpty;

  String get _fileName => filePath?.split(RegExp(r'[/\\]')).last ?? '';

  String get _fileSize {
    if (filePath == null) return '';
    try { return FileLimit.formatSize(File(filePath!).lengthSync()); } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _has
            ? const Color(0xFF006344).withValues(alpha: 0.5) : AppColors.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _has ? const Color(0xFF86F8C5).withValues(alpha: 0.3)
                : const Color(0xFFD6E3FF).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_has ? Icons.check_circle_outline_rounded : icon,
            color: _has ? const Color(0xFF004931) : AppColors.primaryContainer, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(
            text: label,
            style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.onBackground, height: 1.3),
            children: isRequired ? [const TextSpan(text: ' *',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800))] : [],
          )),
          if (subtitle != null && !_has) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 10,
                color: AppColors.onSurfaceVariant)),
          ],
          const SizedBox(height: 4),
          if (_has)
            Row(children: [
              const Icon(Icons.insert_drive_file_outlined,
                  color: Color(0xFF004931), size: 13),
              const SizedBox(width: 4),
              Expanded(child: Text('$_fileName${_fileSize.isNotEmpty ? " · $_fileSize" : ""}',
                style: const TextStyle(fontFamily: 'HankenGrotesk',
                    fontSize: 11, color: Color(0xFF004931)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ])
          else
            _StatusChip(label: isRequired ? 'Obligatoire' : 'Optionnel'),
        ])),
        const SizedBox(width: 8),
        if (isLoading)
          const SizedBox(width: 36, height: 36,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryContainer))
        else if (_has)
          GestureDetector(onTap: onRemove,
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18)))
        else
          GestureDetector(onTap: onUpload,
            child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.upload_rounded, color: Colors.white, size: 22))),
      ]),
    );
  }
}

class _OtherDocItem extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onRemove;
  const _OtherDocItem({required this.path, required this.index, required this.onRemove});
  String get _name => path.split(RegExp(r'[/\\]')).last;
  String get _size {
    try { return FileLimit.formatSize(File(path).lengthSync()); } catch (_) { return ''; }
  }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF006344).withValues(alpha: 0.4)),
    ),
    child: Row(children: [
      const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF004931), size: 22),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_name, style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13,
            fontWeight: FontWeight.w500, color: AppColors.onBackground),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        if (_size.isNotEmpty)
          Text(_size, style: const TextStyle(fontFamily: 'HankenGrotesk',
              fontSize: 10, color: AppColors.onSurfaceVariant)),
      ])),
      GestureDetector(onTap: onRemove,
        child: const Icon(Icons.close_rounded, color: AppColors.error, size: 20)),
    ]),
  );
}

class _AddMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _AddMoreButton({required this.isLoading, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.5)),
      ),
      child: isLoading
          ? const Center(child: SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                  color: AppColors.primaryContainer)))
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_rounded, color: AppColors.primaryContainer, size: 20),
              SizedBox(width: 8),
              Text('Ajouter un document', style: TextStyle(fontFamily: 'HankenGrotesk',
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer)),
            ]),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});
  @override
  Widget build(BuildContext context) {
    final isOblig = label == 'Obligatoire';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOblig ? const Color(0xFFFFDAD6) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOblig ? AppColors.error : AppColors.onSurfaceVariant,
          letterSpacing: 0.5)),
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
    ),
    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
      SizedBox(width: 10),
      Expanded(child: Text(
        'Vos documents sont chiffrés et uniquement accessibles à nos agents vérificateurs. '
        'Votre bien sera examiné sous 48-72h.',
        style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13,
            color: AppColors.onSurfaceVariant, height: 1.5))),
    ]),
  );
}
