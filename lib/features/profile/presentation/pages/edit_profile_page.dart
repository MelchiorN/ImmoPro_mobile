import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/country_service.dart';
import '../../../../core/widgets/country_autocomplete_field.dart';
import '../../../../core/widgets/city_autocomplete_field.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final EditProfileController _controller;
  final _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  CountryModel? _selectedCountry;
  String? _selectedCity;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(
      updateProfileUseCase: ServiceLocator.instance.updateProfileUseCase,
    );
    final user = ServiceLocator.instance.currentUser;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: user?.lastName  ?? '');
    _emailCtrl     = TextEditingController(text: user?.email     ?? '');
    _phoneCtrl     = TextEditingController(text: user?.telephone ?? '');
    _selectedCity  = user?.city ?? '';
    if (user?.country != null && user!.country.isNotEmpty) {
      CountryService.instance.findByName(user.country).then((m) {
        if (m != null && mounted) setState(() => _selectedCountry = m);
      });
    }
    _listener = () {
      if (!mounted) return;
      if (_controller.status == EditProfileStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    };
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _isUploadingPhoto = true);
    try {
      final url = await ServiceLocator.instance.updatePhotoUseCase(picked.path);
      final u = ServiceLocator.instance.currentUser;
      if (u != null && url.isNotEmpty) {
        ServiceLocator.instance.currentUser = UserEntity(
          id: u.id, firstName: u.firstName, lastName: u.lastName,
          email: u.email, telephone: u.telephone, country: u.country,
          city: u.city, profilePicture: url, role: u.role,
          status: u.status, emailVerifiedAt: u.emailVerifiedAt, token: u.token,
        );
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Impossible de mettre à jour la photo.'),
            backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName:  _lastNameCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        phone:     _phoneCtrl.text.trim(),
        country:   _selectedCountry?.name ?? '',
        city:      _selectedCity ?? '',
      );
    }
  }

  Widget _avatar(UserEntity? user) {
    final pic = user?.profilePicture;
    if (pic != null && pic.isNotEmpty) {
      return Image.network(pic, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(user));
    }
    return _initials(user);
  }

  Widget _initials(UserEntity? user) {
    final name = user?.fullName ?? '';
    return Container(
      color: AppColors.primaryContainer,
      child: Center(child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: _isUploadingPhoto ? null : () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back,
            color: _isUploadingPhoto ? Colors.white.withValues(alpha: 0.4) : Colors.white),
          tooltip: 'Retour',
        ),
        title: const Text('Modifier le profil',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: PopScope(
        canPop: !_isUploadingPhoto,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final isLoading = _controller.status == EditProfileStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ────────────────────────────────────────────
                    Center(child: Column(children: [
                      Stack(children: [
                        Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ClipOval(
                            child: _isUploadingPhoto
                                ? Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
                                : _avatar(ServiceLocator.instance.currentUser),
                          ),
                        ),
                        Positioned(bottom: 0, right: 0,
                          child: GestureDetector(onTap: _isUploadingPhoto ? null : _pickPhoto,
                            child: Container(width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: _isUploadingPhoto ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isUploadingPhoto ? null : _pickPhoto,
                        child: Text(_isUploadingPhoto ? 'Envoi…' : 'Changer la photo',
                          style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 13, fontWeight: FontWeight.w600,
                            color: _isUploadingPhoto ? AppColors.outline : AppColors.primary)),
                      ),
                    ])),
                    const SizedBox(height: 20),

                    // ── Prénom + Nom ──────────────────────────────────────
                    Row(children: [
                      Expanded(child: _field(label: 'PRÉNOM', ctrl: _firstNameCtrl, hint: 'Prénom',
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(label: 'NOM', ctrl: _lastNameCtrl, hint: 'Nom',
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                    ]),
                    const SizedBox(height: 16),
                    // ── Email ─────────────────────────────────────────────
                    _field(
                      label: 'EMAIL', ctrl: _emailCtrl,
                      hint: 'prenom@example.com',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      const Expanded(child: Text(
                        'Une vérification sera requise si vous changez l\'email.',
                        style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                      )),
                    ]),
                    const SizedBox(height: 16),
                    // ── Téléphone ─────────────────────────────────────────
                    _field(
                      label: 'TÉLÉPHONE', ctrl: _phoneCtrl, hint: '+225 07 00 00 00 00',
                      keyboard: TextInputType.phone, prefix: Icons.phone_outlined,
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    // ── Pays ──────────────────────────────────────────────
                    const _FieldLabel('PAYS'),
                    const SizedBox(height: 8),
                    CountryAutocompleteField(
                      initialValue: _selectedCountry?.name ?? ServiceLocator.instance.currentUser?.country,
                      onCountrySelected: (m) => setState(() => _selectedCountry = m),
                      hintText: 'Rechercher un pays…',
                    ),
                    const SizedBox(height: 16),
                    // ── Ville ─────────────────────────────────────────────
                    const _FieldLabel('VILLE'),
                    const SizedBox(height: 8),
                    CityAutocompleteField(
                      countryName: _selectedCountry?.name,
                      initialValue: _selectedCity,
                      onCitySelected: (c) => setState(() => _selectedCity = c),
                      hintText: 'Rechercher une ville…',
                    ),
                    const SizedBox(height: 28),

                    // ── Erreur ────────────────────────────────────────────
                    if (_controller.status == EditProfileStatus.failure && _controller.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: Color(0xFFBA1A1A), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_controller.errorMessage!,
                            style: const TextStyle(color: Color(0xFF93000A), fontSize: 13, fontFamily: 'HankenGrotesk'))),
                        ]),
                      ),
                    // ── Bouton Enregistrer ────────────────────────────────
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Enregistrer',
                                style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ── Bouton Annuler ────────────────────────────────────
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          backgroundColor: AppColors.surfaceContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Annuler',
                          style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Champ formulaire avec label intégré
  Widget _field({
    required String label, required TextEditingController ctrl, required String hint,
    TextInputType keyboard = TextInputType.text, IconData? prefix,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FieldLabel(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        style: const TextStyle(fontFamily: 'HankenGrotesk', fontSize: 15, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.outlineVariant),
          prefixIcon: prefix != null ? Icon(prefix, color: AppColors.outline, size: 18) : null,
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        ),
      ),
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      fontFamily: 'HankenGrotesk', fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 0.8, color: AppColors.outline));
  }
}
