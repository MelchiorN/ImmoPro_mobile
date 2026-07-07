import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import '../widgets/location_picker_widget.dart';
import 'step2_media_page.dart';

/// Types de biens qui n'ont PAS de pièces/salles de bain
const _typesWithoutRooms = {'Terrain'};

/// Types de biens qui n'ont PAS de surface bâtie (m²)
const _typesWithoutSurface = <String>{};

/// Étape 1 / 4 — Informations de base, champs adaptatifs selon le type de bien.
class Step1InfoPage extends StatefulWidget {
  const Step1InfoPage({super.key});

  @override
  State<Step1InfoPage> createState() => _Step1InfoPageState();
}

class _Step1InfoPageState extends State<Step1InfoPage> {
  final _formKey = GlobalKey<FormState>();

  late final PublishController _controller;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Appartement';
  String _selectedTransaction = 'Vente';
  int _descLength = 0;

  final List<String> _propertyTypes = [
    'Appartement',
    'Maison',
    'Villa',
    'Terrain',
    'Bureau / Commerce',
  ];

  final List<String> _transactionTypes = ['Vente', 'Location', 'Colocation'];

  bool get _showRooms => !_typesWithoutRooms.contains(_selectedType);
  bool get _showSurface => !_typesWithoutSurface.contains(_selectedType);

  @override
  void initState() {
    super.initState();
    // Utilise le ServiceLocator — injection propre, plus de dépendances directes
    _controller = ServiceLocator.instance.createPublishController();

    _descriptionController.addListener(() {
      setState(() => _descLength = _descriptionController.text.length);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? v) {
    if (v == null) return;
    setState(() => _selectedType = v);
    _controller.updatePropertyType(v);
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _controller.updatePropertyType(_selectedType);
      _controller.updateTransactionType(_selectedTransaction);
      _controller.updateTitle(_titleController.text.trim());
      _controller.updatePrice(_priceController.text.trim());
      if (_showSurface) _controller.updateSurface(_surfaceController.text.trim());
      _controller.updateDescription(_descriptionController.text.trim());

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Step2MediaPage(controller: _controller),
        ),
      );
    }
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
          title: 'Publier un bien',
          currentStep: 0,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoBanner(),
                    const SizedBox(height: 20),

                    // ── Type de bien ───────────────────────────────────
                    _SectionLabel('Type de bien'),
                    const SizedBox(height: 8),
                    _PropertyTypeDropdown(
                      value: _selectedType,
                      items: _propertyTypes,
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 16),

                    // ── Type de transaction ────────────────────────────
                    _SectionLabel('Type de transaction'),
                    const SizedBox(height: 8),
                    _TransactionChips(
                      selected: _selectedTransaction,
                      types: _transactionTypes,
                      onSelected: (t) =>
                          setState(() => _selectedTransaction = t),
                    ),
                    const SizedBox(height: 16),

                    // ── Titre ──────────────────────────────────────────
                    _SectionLabel("Titre de l'annonce"),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: _titleController,
                      hint: _titleHint,
                      prefixIcon: Icons.title_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Le titre est requis';
                        if (v.trim().length < 5) return 'Minimum 5 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Prix & Surface (conditionnelle) ────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel('Prix'),
                              const SizedBox(height: 8),
                              _AppTextField(
                                controller: _priceController,
                                hint: '0',
                                suffixText: 'FCFA',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requis';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_showSurface) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Surface'),
                                const SizedBox(height: 8),
                                _AppTextField(
                                  controller: _surfaceController,
                                  hint: '0',
                                  suffixText: 'm²',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Requis';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // ── Pièces & SDB (masqués pour Terrain) ────────────
                    if (_showRooms) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Pièces'),
                                const SizedBox(height: 8),
                                _StepperField(
                                  value: _controller.draft.rooms,
                                  onDecrement: _controller.decrementRooms,
                                  onIncrement: _controller.incrementRooms,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Salles de bain'),
                                const SizedBox(height: 8),
                                _StepperField(
                                  value: _controller.draft.bathrooms,
                                  onDecrement: _controller.decrementBathrooms,
                                  onIncrement: _controller.incrementBathrooms,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── Description (optionnelle) ──────────────────────
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _SectionLabel('Description'),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Optionnel',
                                style: TextStyle(
                                  fontFamily: 'HankenGrotesk',
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_descLength / 2000',
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLength: 2000,
                      maxLines: 4,
                      buildCounter: (_, {required currentLength,
                          required isFocused, maxLength}) => null,
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: _descHint,
                        hintStyle: const TextStyle(
                          color: AppColors.outlineVariant,
                          fontFamily: 'HankenGrotesk',
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      // Pas de validator → optionnel
                    ),
                    const SizedBox(height: 20),

                    // ── Localisation ───────────────────────────────────
                    LocationPickerWidget(
                      initialAddress: _controller.draft.address,
                      initialLatitude: _controller.draft.latitude,
                      initialLongitude: _controller.draft.longitude,
                      onLocationChanged: (address, lat, lng) {
                        _controller.updateLocation(
                          address: address,
                          latitude: lat,
                          longitude: lng,
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: PublishBottomBar(
          showBack: false,
          nextLabel: 'Suivant',
          onNext: _onNext,
        ),
      ),
    );
  }

  String get _titleHint {
    switch (_selectedType) {
      case 'Terrain':
        return 'Ex : Terrain viabilisé 500m² à Cocody';
      case 'Villa':
        return 'Ex : Villa 5 pièces avec piscine à Abidjan';
      case 'Bureau / Commerce':
        return 'Ex : Local commercial 80m² au Plateau';
      default:
        return 'Ex : Bel appartement F4 à Cocody';
    }
  }

  String get _descHint {
    switch (_selectedType) {
      case 'Terrain':
        return 'Décrivez le terrain : accès, viabilisation, clôture, orientation…';
      case 'Bureau / Commerce':
        return 'Décrivez le local : état, équipements, parking, accès…';
      default:
        return 'Décrivez les atouts de votre bien (luminosité, calme, travaux récents…)';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets utilitaires
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFA9C7FF).withValues(alpha: 0.6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.home_work_rounded,
              color: AppColors.primaryContainer, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'En publiant, vous devenez Propriétaire sur ImmoPro. Profitez d\'outils de gestion exclusifs.',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                color: Color(0xFF001B3D),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'HankenGrotesk',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PropertyTypeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _PropertyTypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.onSurfaceVariant),
          items: items
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(_typeIcon(t),
                            size: 18, color: AppColors.primaryContainer),
                        const SizedBox(width: 10),
                        Text(
                          t,
                          style: const TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Appartement':
        return Icons.apartment_rounded;
      case 'Maison':
        return Icons.house_rounded;
      case 'Villa':
        return Icons.villa_rounded;
      case 'Terrain':
        return Icons.landscape_rounded;
      case 'Bureau / Commerce':
        return Icons.business_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}

class _TransactionChips extends StatelessWidget {
  final String selected;
  final List<String> types;
  final void Function(String) onSelected;

  const _TransactionChips({
    required this.selected,
    required this.types,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((t) {
        final isActive = t == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelected(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                t,
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffixText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.suffixText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 15,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.outlineVariant,
          fontFamily: 'HankenGrotesk',
          fontSize: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.outline, size: 20)
            : null,
        suffix: suffixText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  suffixText!,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _StepperField({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove_rounded, onTap: onDecrement),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          _StepBtn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: 48,
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
