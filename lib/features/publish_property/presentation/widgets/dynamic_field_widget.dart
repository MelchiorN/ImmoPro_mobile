import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category_schema_entity.dart';

/// Widget générique qui affiche le bon composant de saisie selon le type du champ.
/// Chaque type valide en temps réel et affiche l'erreur en rouge sous le champ.
class DynamicFieldWidget extends StatefulWidget {
  final AttributDefinitionEntity attribut;
  final dynamic value;
  final void Function(dynamic) onChanged;

  const DynamicFieldWidget({
    super.key,
    required this.attribut,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DynamicFieldWidget> createState() => _DynamicFieldWidgetState();
}

class _DynamicFieldWidgetState extends State<DynamicFieldWidget> {
  late final TextEditingController _textCtrl;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur texte avec la valeur existante
    final initial = widget.value?.toString() ?? '';
    _textCtrl = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _validate(dynamic value) {
    final error = widget.attribut.validate(value);
    setState(() => _errorText = error);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildInput(),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          _ErrorHint(message: _errorText!),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.attribut.labelAffiche.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk', fontSize: 10,
              fontWeight: FontWeight.w600, letterSpacing: 0.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        if (widget.attribut.obligatoire) ...const [
          SizedBox(width: 3),
          Text('*', style: TextStyle(color: AppColors.error,
              fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }

  Widget _buildInput() {
    switch (widget.attribut.typeChamp) {
      case 'nombre':  return _buildNombreField();
      case 'booleen': return _buildBooleanField();
      case 'enum':    return _buildEnumField();
      case 'date':    return _buildDateField();
      default:        return _buildTexteField();
    }
  }

  // ── Texte ─────────────────────────────────────────────────────────────────

  Widget _buildTexteField() {
    return TextFormField(
      controller: _textCtrl,
      style: const TextStyle(fontFamily: 'HankenGrotesk',
          fontSize: 15, color: AppColors.onSurface),
      decoration: _inputDecoration(
        hintText: 'Saisir ${widget.attribut.labelAffiche.toLowerCase()}…',
        hasError: _errorText != null,
      ),
      textInputAction: TextInputAction.next,
      onChanged: (v) {
        widget.onChanged(v.trim().isEmpty ? null : v.trim());
        _validate(v.trim().isEmpty ? null : v.trim());
      },
      validator: (_) => widget.attribut.validate(
          _textCtrl.text.trim().isEmpty ? null : _textCtrl.text.trim()),
    );
  }

  // ── Nombre ────────────────────────────────────────────────────────────────

  Widget _buildNombreField() {
    return TextFormField(
      controller: _textCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: TextStyle(
        fontFamily: 'HankenGrotesk', fontSize: 15,
        color: _errorText != null ? AppColors.error : AppColors.onSurface,
      ),
      decoration: _inputDecoration(
        hintText: '0',
        hasError: _errorText != null,
      ),
      textInputAction: TextInputAction.next,
      onChanged: (v) {
        final n = num.tryParse(v.replaceAll(' ', ''));
        widget.onChanged(n);
        _validate(n);
      },
      validator: (_) {
        final v = _textCtrl.text.trim();
        if (v.isEmpty) return widget.attribut.validate(null);
        final n = num.tryParse(v);
        if (n == null) return 'Doit être un nombre (ex: 3 ou 45.5)';
        return widget.attribut.validate(n);
      },
    );
  }

  // ── Booléen ───────────────────────────────────────────────────────────────

  Widget _buildBooleanField() {
    final current = widget.value as bool? ?? false;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errorText != null ? AppColors.error : AppColors.outlineVariant,
        ),
      ),
      child: Row(children: [
        const SizedBox(width: 16),
        Expanded(child: Text(widget.attribut.labelAffiche,
          style: const TextStyle(fontFamily: 'HankenGrotesk',
              fontSize: 15, color: AppColors.onSurface))),
        Switch(
          value: current,
          activeThumbColor: AppColors.primaryContainer,
          onChanged: (v) {
            widget.onChanged(v);
            _validate(v);
          },
        ),
        const SizedBox(width: 8),
      ]),
    );
  }

  // ── Enum (liste déroulante) ────────────────────────────────────────────────

  Widget _buildEnumField() {
    final options = widget.attribut.optionsEnum;
    final current = widget.value as String?;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errorText != null ? AppColors.error : AppColors.outlineVariant,
          width: _errorText != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(current) ? current : null,
          hint: Text('Choisir…',
            style: const TextStyle(color: AppColors.outlineVariant,
                fontFamily: 'HankenGrotesk', fontSize: 15)),
          isExpanded: true,
          icon: Icon(Icons.expand_more_rounded,
            color: _errorText != null ? AppColors.error : AppColors.onSurfaceVariant),
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(_formatEnumLabel(opt),
              style: const TextStyle(fontFamily: 'HankenGrotesk',
                  fontSize: 15, color: AppColors.onSurface)),
          )).toList(),
          onChanged: (v) {
            widget.onChanged(v);
            _validate(v);
          },
        ),
      ),
    );
  }

  // ── Date ──────────────────────────────────────────────────────────────────

  Widget _buildDateField() {
    final current = widget.value as String?;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: current != null
              ? (DateTime.tryParse(current) ?? DateTime.now())
              : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primaryContainer),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          final formatted = picked.toIso8601String().split('T').first;
          widget.onChanged(formatted);
          _validate(formatted);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _errorText != null ? AppColors.error : AppColors.outlineVariant,
            width: _errorText != null ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, size: 18,
            color: _errorText != null ? AppColors.error : AppColors.outline),
          const SizedBox(width: 10),
          Expanded(child: Text(
            current != null ? _formatDateDisplay(current) : 'Sélectionner une date…',
            style: TextStyle(
              fontFamily: 'HankenGrotesk', fontSize: 15,
              color: current != null
                  ? AppColors.onSurface
                  : AppColors.outlineVariant,
            ),
          )),
          const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 20),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hintText,
    required bool hasError,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.outlineVariant,
          fontFamily: 'HankenGrotesk', fontSize: 15),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon,
              color: hasError ? AppColors.error : AppColors.outline, size: 18)
          : null,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.outlineVariant,
            width: hasError ? 1.5 : 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      // On gère l'erreur manuellement sous le widget → pas d'errorText ici
      errorText: null,
    );
  }

  /// Convertit un slug enum en label lisible (neuf → Neuf, bon_etat → Bon état)
  String _formatEnumLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDateDisplay(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

/// Affichage de l'erreur sous le champ — rouge avec icône.
class _ErrorHint extends StatelessWidget {
  final String message;
  const _ErrorHint({required this.message});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(message,
        style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 12,
            color: AppColors.error))),
    ]);
  }
}
