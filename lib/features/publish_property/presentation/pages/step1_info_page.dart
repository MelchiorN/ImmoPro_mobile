import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/category_schema_entity.dart';
import '../controllers/publish_controller.dart';
import '../widgets/publish_app_bar.dart';
import '../widgets/publish_bottom_bar.dart';
import '../widgets/location_picker_widget.dart';
import '../widgets/dynamic_field_widget.dart';
import 'step2_media_page.dart';

/// Types de biens sans pièces/salles de bain
const _typesWithoutRooms = {'Terrain', 'Bureau / Commerce', 'Chambre / Studio'};

/// Étape 1 / 3 — Infos de base + champs dynamiques de la catégorie.
class Step1InfoPage extends StatefulWidget {
  const Step1InfoPage({super.key});
  @override
  State<Step1InfoPage> createState() => _Step1InfoPageState();
}

class _Step1InfoPageState extends State<Step1InfoPage> {
  final _formKey       = GlobalKey<FormState>();
  late final PublishController _controller;
  final _titleCtrl    = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _surfaceCtrl  = TextEditingController();
  final _superficieCtrl = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _roomsCtrl    = TextEditingController(text: '1');
  final _bathCtrl     = TextEditingController(text: '1');
  int  _descLength    = 0;
  String _selectedType        = 'Appartement';
  // ignore: prefer_final_fields
  String _selectedTransaction = 'location'; // Hardcodé à 'location' comme convenu

  List<String> _propertyTypes = [
    'Appartement', 'Maison', 'Villa', 'Terrain',
    'Bureau / Commerce', 'Chambre / Studio',
  ];
  Map<String, String> _typeToSlugMap = {};
  // ignore: unused_field
  final List<String> _transactions = ['Vente', 'Location', 'Colocation'];

  /// Slug API correspondant au type sélectionné
  String get _slug {
    if (_typeToSlugMap.containsKey(_selectedType)) {
      return _typeToSlugMap[_selectedType]!;
    }
    switch (_selectedType) {
      case 'Appartement':       return 'appartement';
      case 'Maison':            return 'maison';
      case 'Villa':             return 'villa';
      case 'Terrain':           return 'terrain';
      case 'Bureau / Commerce': return 'bureau_commerce';
      case 'Chambre / Studio':  return 'chambre_studio';
      default:                  return _selectedType.toLowerCase().replaceAll(' ', '_');
    }
  }

  bool get _showRooms => !_typesWithoutRooms.contains(_selectedType);

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.instance.createPublishController();
    _descCtrl.addListener(() =>
        setState(() => _descLength = _descCtrl.text.length));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetched = await _controller.fetchCategories();
      if (fetched.isNotEmpty && mounted) {
        setState(() {
          _propertyTypes = fetched.map((c) => c['nom']!).toList();
          _typeToSlugMap = { for (var c in fetched) c['nom']! : c['slug']! };
          if (!_propertyTypes.contains(_selectedType)) {
            _selectedType = _propertyTypes.first;
          }
        });
      }
      _controller.loadCategorySchema(_slug);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _priceCtrl.dispose();
    _surfaceCtrl.dispose(); _superficieCtrl.dispose();
    _addressCtrl.dispose(); _descCtrl.dispose();
    _roomsCtrl.dispose(); _bathCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? v) {
    if (v == null) return;
    setState(() => _selectedType = v);
    _controller.updatePropertyType(_slug);
    _controller.loadCategorySchema(_slug);
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ── Validation croisée : étage de l'appartement ≤ nombre d'étages ──
    final nbEtages = _controller.getCaracteristique('nombre_etages');
    final etageAppart = _controller.getCaracteristique('etage_appartement');
    if (nbEtages != null && etageAppart != null) {
      final total = (nbEtages is num) ? nbEtages.toInt() : int.tryParse(nbEtages.toString()) ?? 0;
      final etage = (etageAppart is num) ? etageAppart.toInt() : int.tryParse(etageAppart.toString()) ?? 0;
      if (etage > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'L\'étage de l\'appartement ($etage) ne peut pas dépasser le nombre d\'étages de l\'immeuble ($total).',
              style: const TextStyle(fontFamily: 'HankenGrotesk'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    _controller.updatePropertyType(_slug);
    _controller.updateTransactionType(_selectedTransaction);
    _controller.updateTitle(_titleCtrl.text.trim());
    _controller.updatePrice(_priceCtrl.text.trim());
    _controller.updateAddress(_addressCtrl.text.trim());
    if (_showRooms == false || _surfaceCtrl.text.trim().isNotEmpty) {
      _controller.updateSurface(_surfaceCtrl.text.trim());
    }
    if (_superficieCtrl.text.trim().isNotEmpty) {
      _controller.updateSuperficie(_superficieCtrl.text.trim());
    }
    _controller.updateDescription(_descCtrl.text.trim());

    // Mettre à jour rooms / bathrooms depuis les champs texte
    if (_showRooms) {
      final rooms = int.tryParse(_roomsCtrl.text.trim()) ?? 1;
      final baths = int.tryParse(_bathCtrl.text.trim()) ?? 1;
      _controller.updateRooms(rooms);
      _controller.updateBathrooms(baths);
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Step2MediaPage(controller: _controller),
    ));
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
          totalSteps: 3,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoBanner(),
                  const SizedBox(height: 20),
                  _SectionLabel('Type de bien'),
                  const SizedBox(height: 8),
                  _CustomDropdown(
                    value: _selectedType,
                    items: _propertyTypes,
                    onChanged: _onTypeChanged,
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel("Titre de l'annonce"),
                  const SizedBox(height: 8),
                  _AppTextField(
                    controller: _titleCtrl,
                    hint: _titleHint,
                    prefixIcon: Icons.title_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Le titre est requis';
                      if (v.trim().length < 5) return 'Minimum 5 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Prix + Surface
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Prix'),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: _priceCtrl,
                          hint: '0',
                          suffixText: 'FCFA',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requis';
                            if (double.tryParse(v) == null) return 'Nombre invalide';
                            return null;
                          },
                        ),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Surface habitable'),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: _surfaceCtrl,
                          hint: '0',
                          suffixText: 'm²',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Superficie terrain'),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: _superficieCtrl,
                          hint: '0',
                          suffixText: 'm²',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    )),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()), // Placeholder for alignment
                  ]),
                  // Pièces + SDB (masqués selon le type)
                  if (_showRooms) ...[
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Pièces'),
                          const SizedBox(height: 8),
                          _AppTextField(
                            controller: _roomsCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requis';
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return 'Min. 1';
                              return null;
                            },
                          ),
                        ],
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Salles de bain'),
                          const SizedBox(height: 8),
                          _AppTextField(
                            controller: _bathCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requis';
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return 'Min. 1';
                              return null;
                            },
                          ),
                        ],
                      )),
                    ]),
                  ],
                  // Description
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        _SectionLabel('Description'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Optionnel',
                            style: TextStyle(fontFamily: 'HankenGrotesk',
                                fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ),
                      ]),
                      Text('$_descLength / 2000',
                        style: const TextStyle(fontFamily: 'HankenGrotesk',
                            fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLength: 2000,
                    maxLines: 4,
                    buildCounter: (_, {required currentLength,
                        required isFocused, maxLength}) => null,
                    style: const TextStyle(fontFamily: 'HankenGrotesk',
                        fontSize: 14, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: _descHint,
                      hintStyle: const TextStyle(color: AppColors.outlineVariant,
                          fontFamily: 'HankenGrotesk', fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.all(14),
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 16),
                  _SectionLabel('Adresse complète'),
                  const SizedBox(height: 8),
                  _AppTextField(
                    controller: _addressCtrl,
                    hint: 'Ex: Cocody Angré, 8ème Tranche',
                    prefixIcon: Icons.location_city_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'L\'adresse est requise';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Localisation
                  LocationPickerWidget(
                    initialLatitude: _controller.draft.latitude,
                    initialLongitude: _controller.draft.longitude,
                    onLocationChanged: (lat, lng) => _controller.updateCoordinates(lat, lng),
                  ),
                  const SizedBox(height: 24),
                  // ── Champs dynamiques ─────────────────────────────────────────
                  if (_controller.schemaStatus == SchemaStatus.loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_controller.schema != null &&
                      _controller.schema!.attributs.isNotEmpty) ...[
                    _DynamicSectionHeader(nom: _controller.schema!.nom),
                    const SizedBox(height: 12),
                    // Afficher les champs dynamiques par paires côte à côte
                    ..._buildDynamicFieldRows(),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PublishBottomBar(
          showBack: false,
          totalSteps: 3,
          nextLabel: 'Suivant',
          onNext: _onNext,
        ),
      ),
    );
  }

  String get _titleHint {
    switch (_selectedType) {
      case 'Terrain':           return 'Ex : Terrain viabilisé 500m² à Cocody';
      case 'Villa':             return 'Ex : Villa 5 pièces avec piscine à Abidjan';
      case 'Bureau / Commerce': return 'Ex : Local commercial 80m² au Plateau';
      case 'Chambre / Studio':  return 'Ex : Studio meublé à Yopougon';
      default:                  return 'Ex : Bel appartement F4 à Cocody';
    }
  }

  String get _descHint {
    switch (_selectedType) {
      case 'Terrain':           return 'Décrivez le terrain : accès, viabilisation, clôture…';
      case 'Bureau / Commerce': return 'Décrivez le local : état, équipements, accès…';
      default:                  return 'Décrivez les atouts de votre bien…';
    }
  }

  /// Construit les champs dynamiques en paires côte à côte.
  /// Les booléens et textes restent en pleine largeur,
  /// les nombre/enum/date sont groupés 2 par ligne.
  List<Widget> _buildDynamicFieldRows() {
    final filteredAttrs = _controller.schema!.attributs.where((attr) {
      // Logique conditionnelle pour le parking et garage
      if (attr.nomChamp == 'type_parking' ||
          attr.nomChamp == 'capacite_parking' ||
          attr.nomChamp == 'parking_partage') {
        return _controller.getCaracteristique('parking_disponible') == true;
      }
      if (attr.nomChamp == 'capacite_garage') {
        return _controller.getCaracteristique('garage_disponible') == true;
      }
      return true;
    }).toList();

    // Séparer les champs "pleine largeur" (booleen, texte) des "compacts" (nombre, enum, date)
    final List<Widget> rows = [];
    final List<AttributDefinitionEntity> compactQueue = [];

    void flushCompactQueue() {
      while (compactQueue.length >= 2) {
        final a = compactQueue.removeAt(0);
        final b = compactQueue.removeAt(0);
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DynamicFieldWidget(
                  attribut: a,
                  value: _controller.getCaracteristique(a.nomChamp),
                  onChanged: (v) => _controller.setCaracteristique(a.nomChamp, v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DynamicFieldWidget(
                  attribut: b,
                  value: _controller.getCaracteristique(b.nomChamp),
                  onChanged: (v) => _controller.setCaracteristique(b.nomChamp, v),
                ),
              ),
            ],
          ),
        ));
      }
      // S'il reste un champ impair
      if (compactQueue.isNotEmpty) {
        final a = compactQueue.removeAt(0);
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: DynamicFieldWidget(
                  attribut: a,
                  value: _controller.getCaracteristique(a.nomChamp),
                  onChanged: (v) => _controller.setCaracteristique(a.nomChamp, v),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ));
      }
    }

    for (final attr in filteredAttrs) {
      final isFullWidth = attr.typeChamp == 'booleen' || attr.typeChamp == 'texte';

      if (isFullWidth) {
        // D'abord vider la file de champs compacts
        flushCompactQueue();
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DynamicFieldWidget(
            attribut: attr,
            value: _controller.getCaracteristique(attr.nomChamp),
            onChanged: (v) => _controller.setCaracteristique(attr.nomChamp, v),
          ),
        ));
      } else {
        compactQueue.add(attr);
      }
    }
    // Vider le reste
    flushCompactQueue();

    return rows;
  }
}

// ─── Widgets internes ─────────────────────────────────────────────────────────

class _DynamicSectionHeader extends StatelessWidget {
  final String nom;
  const _DynamicSectionHeader({required this.nom});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.tune_rounded, color: AppColors.primaryContainer, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text('Caractéristiques — $nom',
        style: const TextStyle(fontFamily: 'Manrope', fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.onBackground))),
    ]);
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA9C7FF).withValues(alpha: 0.6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.home_work_rounded, color: AppColors.primaryContainer, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text(
            'En publiant, vous devenez Propriétaire sur ImmoPro. Profitez d\'outils de gestion exclusifs.',
            style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13,
                color: Color(0xFF001B3D), height: 1.5),
          )),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(text.toUpperCase(),
      style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 0.8,
          color: AppColors.onSurfaceVariant)),
  );
}

class _CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;
  const _CustomDropdown({required this.value, required this.items, required this.onChanged});
  
  IconData _icon(String t) {
    switch (t) {
      case 'Appartement':      return Icons.apartment_rounded;
      case 'Maison':           return Icons.house_rounded;
      case 'Villa':            return Icons.villa_rounded;
      case 'Terrain':          return Icons.landscape_rounded;
      case 'Bureau / Commerce': return Icons.business_rounded;
      case 'Chambre / Studio': return Icons.bed_rounded;
      case 'Vente':            return Icons.sell_rounded;
      case 'Location':         return Icons.key_rounded;
      case 'Colocation':       return Icons.group_rounded;
      default:                 return Icons.label_rounded;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant),
          items: items.map((t) => DropdownMenuItem(
            value: t,
            child: Row(
              children: [
                Icon(_icon(t), size: 16, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
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
  const _AppTextField({required this.controller, required this.hint,
      this.suffixText, this.prefixIcon,
      this.keyboardType = TextInputType.text,
      this.inputFormatters, this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 15, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.outlineVariant, fontFamily: 'HankenGrotesk', fontSize: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.outline, size: 20) : null,
        suffix: suffixText != null ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(4)),
          child: Text(suffixText!, style: const TextStyle(fontFamily: 'HankenGrotesk',
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        ) : null,
        filled: true, fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
    );
  }
}
