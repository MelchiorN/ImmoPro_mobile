import 'package:flutter/material.dart';
import '../services/city_service.dart';
import '../theme/app_theme.dart';

/// Widget d'autocomplétion pour la sélection d'une ville.
///
/// - Désactivé tant qu'aucun pays n'est sélectionné
/// - Se réinitialise automatiquement si le pays change
/// - Charge les villes via CityService (API countriesnow.space)
class CityAutocompleteField extends StatefulWidget {
  /// Nom du pays sélectionné (null = champ désactivé)
  final String? countryName;

  /// Valeur initiale (nom de la ville)
  final String? initialValue;

  /// Callback déclenché à chaque sélection ou modification
  final void Function(String?) onCitySelected;

  final String hintText;

  const CityAutocompleteField({
    super.key,
    required this.countryName,
    required this.onCitySelected,
    this.initialValue,
    this.hintText = 'Rechercher une ville…',
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset quand le pays change
    if (oldWidget.countryName != widget.countryName) {
      _controller.clear();
      widget.onCitySelected(null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.countryName != null && widget.countryName!.isNotEmpty;

  InputDecoration _buildDecoration({String? errorText}) {
    return InputDecoration(
      hintText: _isEnabled ? widget.hintText : 'Sélectionnez d\'abord un pays',
      hintStyle: TextStyle(
        color: _isEnabled
            ? AppColors.outlineVariant
            : AppColors.outline.withOpacity(0.5),
        fontFamily: 'HankenGrotesk',
        fontSize: 16,
      ),
      prefixIcon: const Icon(Icons.location_city_outlined,
          color: AppColors.outline, size: 22),
      suffixIcon: _controller.text.isNotEmpty && _isEnabled
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.outline, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onCitySelected(null);
              },
            )
          : null,
      errorText: errorText,
      filled: true,
      fillColor: _isEnabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLow.withOpacity(0.5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) {
      return TextFormField(
        enabled: false,
        decoration: _buildDecoration(),
        style: const TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 16,
          color: AppColors.outline,
        ),
      );
    }

    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) async {
        final query = textEditingValue.text.trim();
        return CityService.instance.search(widget.countryName!, query);
      },
      displayStringForOption: (city) => city,
      onSelected: (city) {
        _controller.text = city;
        widget.onCitySelected(city);
        _focusNode.unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: _buildDecoration(),
          onChanged: (v) => widget.onCitySelected(v.isEmpty ? null : v),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ville requise' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxHeight: 200, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final city = options.elementAt(i);
                  return InkWell(
                    onTap: () => onSelected(city),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.outline, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            city,
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 15,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
