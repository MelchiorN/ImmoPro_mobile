import 'package:flutter/material.dart';
import '../services/city_service.dart';
import '../theme/app_theme.dart';

/// Widget d'autocomplétion pour la sélection d'une ville.
/// - Désactivé tant qu'aucun pays n'est sélectionné
/// - Se réinitialise automatiquement si le pays change
/// - Charge les villes via CityService (API countriesnow.space)
/// - Affiche les suggestions dès le focus (même sans saisie)
class CityAutocompleteField extends StatefulWidget {
  final String? countryName;
  final String? initialValue;
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
  final _layerLink  = LayerLink();

  bool _isLoadingCities  = false;
  bool _showSuggestions  = false;
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) _controller.text = widget.initialValue!;

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    if (widget.countryName != null && widget.countryName!.isNotEmpty) {
      _loadCities(widget.countryName!);
    }
  }

  @override
  void didUpdateWidget(CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryName != widget.countryName) {
      _controller.clear();
      _closeSuggestions();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCitySelected(null);
      });
      if (widget.countryName != null && widget.countryName!.isNotEmpty) {
        _loadCities(widget.countryName!);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _closeSuggestions();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Charger les villes ──────────────────────────────────────────────────
  Future<void> _loadCities(String countryName) async {
    if (CityService.instance.hasCachedCities(countryName)) {
      _updateSuggestions(_controller.text);
      return;
    }
    if (mounted) setState(() => _isLoadingCities = true);
    await CityService.instance.fetchCities(countryName);
    if (mounted && widget.countryName == countryName) {
      setState(() => _isLoadingCities = false);
      _updateSuggestions(_controller.text);
    }
  }

  // ── Mettre à jour la liste des suggestions ──────────────────────────────
  void _updateSuggestions(String query) {
    if (widget.countryName == null || widget.countryName!.isEmpty) return;
    final results = CityService.instance.searchSync(widget.countryName!, query);
    setState(() => _suggestions = results);
    if (_focusNode.hasFocus && results.isNotEmpty) {
      _showOverlay();
    } else {
      _closeSuggestions();
    }
  }

  // ── Listeners ────────────────────────────────────────────────────────────
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateSuggestions(_controller.text);
    } else {
      // Petit délai pour permettre le tap sur une suggestion
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) _closeSuggestions();
      });
    }
  }

  void _onTextChange() {
    final v = _controller.text;
    widget.onCitySelected(v.isEmpty ? null : v);
    _updateSuggestions(v);
  }

  // ── Overlay (dropdown suggestions) ──────────────────────────────────────
  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: StatefulBuilder(
                builder: (_, setStateOverlay) => ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (_, i) {
                    final city = _suggestions[i];
                    return InkWell(
                      onTap: () {
                        _controller.text = city;
                        widget.onCitySelected(city);
                        _focusNode.unfocus();
                        _closeSuggestions();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.outline,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                city,
                                style: const TextStyle(
                                  fontFamily: 'HankenGrotesk',
                                  fontSize: 15,
                                  color: AppColors.onSurface,
                                ),
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
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool get _isEnabled =>
      widget.countryName != null && widget.countryName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: _isEnabled,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 16,
          color: _isEnabled ? AppColors.onSurface : AppColors.outline,
        ),
        decoration: InputDecoration(
          hintText: _isEnabled
              ? widget.hintText
              : 'Sélectionnez d\'abord un pays',
          hintStyle: TextStyle(
            color: _isEnabled
                ? AppColors.outlineVariant
                : AppColors.outline.withValues(alpha: 0.5),
            fontFamily: 'HankenGrotesk',
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.location_city_outlined,
            color: AppColors.outline,
            size: 22,
          ),
          suffixIcon: _isLoadingCities
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : (_controller.text.isNotEmpty && _isEnabled
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.outline,
                        size: 18,
                      ),
                      onPressed: () {
                        _controller.clear();
                        widget.onCitySelected(null);
                        _closeSuggestions();
                      },
                    )
                  : null),
          filled: true,
          fillColor: _isEnabled
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
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
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
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
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Ville requise' : null,
      ),
    );
  }
}
