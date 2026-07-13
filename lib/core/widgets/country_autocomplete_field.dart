import 'package:flutter/material.dart';
import '../services/country_service.dart';
import '../theme/app_theme.dart';

/// Widget d'autocomplétion pour la sélection d'un pays.
///
/// - Déclenche la recherche dès 1 caractère
/// - Filtre par préfixe insensible à la casse
/// - Valide que le pays saisi existe au moment de la soumission du formulaire
/// - Fallback sur liste statique si l'API est inaccessible
class CountryAutocompleteField extends StatefulWidget {
  /// Valeur initiale (nom du pays)
  final String? initialValue;

  /// Callback déclenché à chaque sélection ou modification valide
  final void Function(CountryModel?) onCountrySelected;

  /// Label affiché au-dessus (optionnel, géré par le parent si null)
  final String hintText;

  const CountryAutocompleteField({
    super.key,
    this.initialValue,
    required this.onCountrySelected,
    this.hintText = 'Rechercher un pays…',
  });

  @override
  State<CountryAutocompleteField> createState() =>
      _CountryAutocompleteFieldState();
}

class _CountryAutocompleteFieldState extends State<CountryAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  CountryModel? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
      // Pré-charger le modèle correspondant en protégeant le setState
      CountryService.instance
          .findByName(widget.initialValue!)
          .then((model) {
        // Double vérification mounted pour éviter le crash après dispose
        if (!mounted) return;
        if (model != null) {
          setState(() => _selected = model);
          widget.onCountrySelected(model);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSelected(CountryModel country) {
    _controller.text = country.name;
    setState(() {
      _selected = country;
    });
    widget.onCountrySelected(country);
    _focusNode.unfocus();
  }

  /// Appelé par le Form parent via la clé du Form pour valider.
  String? _validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Pays requis';
    if (_selected == null || _selected!.name.toLowerCase() != v.toLowerCase()) {
      return 'Pays non reconnu. Sélectionnez un pays dans la liste.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<CountryModel>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) async {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return const [];
        // Dès 1 caractère
        return CountryService.instance.search(query);
      },
      displayStringForOption: (c) => c.name,
      onSelected: _onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return FormField<String>(
          initialValue: controller.text,
          validator: _validate,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 16,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.outlineVariant,
                      fontFamily: 'HankenGrotesk',
                      fontSize: 16,
                    ),
                    prefixIcon: _selected != null
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _selected!.flagEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          )
                        : const Icon(Icons.flag_outlined,
                            color: AppColors.outline, size: 22),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.outline, size: 18),
                            onPressed: () {
                              controller.clear();
                              setState(() {
                                _selected  = null;
                              });
                              widget.onCountrySelected(null);
                            },
                          )
                        : null,
                    errorText: state.errorText,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.outlineVariant, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.outlineVariant, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 1.5),
                    ),
                  ),
                  onChanged: (_) {
                    // Désélectionner si l'utilisateur modifie manuellement
                    if (_selected != null &&
                        controller.text.trim().toLowerCase() !=
                            _selected!.name.toLowerCase()) {
                      setState(() => _selected = null);
                      widget.onCountrySelected(null);
                    }
                  },
                  validator: _validate,
                ),
              ],
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final country = options.elementAt(i);
                  return InkWell(
                    onTap: () => onSelected(country),
                    borderRadius: i == 0
                        ? const BorderRadius.vertical(
                            top: Radius.circular(12))
                        : i == options.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(12))
                            : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(country.flagEmoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country.name,
                              style: const TextStyle(
                                fontFamily: 'HankenGrotesk',
                                fontSize: 15,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: const TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
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
