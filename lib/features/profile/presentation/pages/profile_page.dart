import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';
import 'historique_paiements_page.dart';
import 'statistiques_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import 'aide_support_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    // Si déconnecté → retour au login
    if (_controller.user == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    // Toast sur erreur photo
    if (_controller.photoStatus == ProfilePhotoStatus.error &&
        _controller.photoError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.photoError!,
              style: const TextStyle(fontFamily: 'HankenGrotesk')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _controller.resetPhotoStatus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  // ── Sélectionner et uploader la photo ─────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    await _controller.uploadPhoto(picked.path);
    if (mounted) setState(() {});
  }

  // ── Confirmer déconnexion ─────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Déconnexion',
                style: TextStyle(fontFamily: 'HankenGrotesk')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF003E7E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final user = _controller.user;

          if (user == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          final isUploadingPhoto =
              _controller.photoStatus == ProfilePhotoStatus.uploading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: const Color(0xFF003E7E),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      tooltip: 'Retour',
                    )
                  : null,
              title: const Text(
                'Mon profil',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SecurityPage()),
                  ),
                  icon: const Icon(Icons.shield_outlined, color: Colors.white),
                  tooltip: 'Sécurité',
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── En-tête dégradé ──────────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Fond dégradé
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 28, bottom: 68, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF003E7E), Color(0xFF1A56A0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          children: [
                            // ── Avatar avec badge caméra ──────────────────
                            GestureDetector(
                              onTap:
                                  isUploadingPhoto ? null : _pickAndUploadPhoto,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.18),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: isUploadingPhoto
                                          ? Container(
                                              color: Colors.black26,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                            )
                                          : _UserAvatar(user: user),
                                    ),
                                  ),
                                  // Badge caméra
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.photo_camera_rounded,
                                        color: Color(0xFF003E7E),
                                        size: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Nom ──────────────────────────────────────
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ── Badge rôle supprimé ───────────────────────
                          ],
                        ),
                      ),

                      // ── Carte stats flottante ──────────────────────────
                      Positioned(
                        bottom: -38,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                  value: _controller.propertyCount.toString(),
                                  label: 'Biens'),
                              _Divider(),
                              _StatItem(
                                  value: _controller.visitCount.toString(),
                                  label: 'Visites'),
                              _Divider(),
                              // Favoris — données en temps réel depuis FavoritesController
                              ListenableBuilder(
                                listenable: ServiceLocator.instance.favoritesController,
                                builder: (_, __) => _StatItem(
                                  value: ServiceLocator.instance.favoritesController.favorites.length.toString(),
                                  label: 'Favoris',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // ── Informations du compte ─────────────────────
                        _InfoCard(user: user),
                        const SizedBox(height: 20),

                        // ── Compte & Paramètres ────────────────────────
                        _SectionLabel(label: 'Compte & Paramètres'),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.person_outline_rounded,
                          color: const Color(0xFF003E7E),
                          title: 'Modifier le profil',
                          subtitle: 'Nom, email, téléphone, ville',
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const EditProfilePage()),
                            );
                            setState(() {}); // refresh après retour
                          },
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.shield_outlined,
                          color: const Color(0xFF576065),
                          title: 'Sécurité & 2FA',
                          subtitle: 'Mot de passe, double authentification',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SecurityPage()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          color: const Color(0xFF004931),
                          title: 'Notifications',
                          subtitle: 'Gérer les alertes et emails',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Mon Activité ───────────────────────────────
                        _SectionLabel(label: 'Mon Activité'),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.bar_chart_rounded,
                          color: const Color(0xFF6A4C93),
                          title: 'Statistiques',
                          subtitle: 'Dépenses, locations, activité',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatistiquesPage()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFF0077B6),
                          title: 'Historique des paiements',
                          subtitle: 'Toutes vos transactions',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HistoriquePaiementsPage()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.favorite_outline_rounded,
                          color: const Color(0xFFB5251C),
                          title: 'Mes Favoris',
                          subtitle: 'Biens que vous suivez',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FavoritesPage()),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Aide & Support ───────────────────────────
                        _SectionLabel(label: 'Aide & Support'),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.help_outline_rounded,
                          color: const Color(0xFF3A5F95),
                          title: 'Aide & Support',
                          subtitle: "FAQ, contacter l'équipe",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AideSupportPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Bouton déconnexion ─────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: _confirmLogout,
                            icon: const Icon(Icons.logout_rounded,
                                color: AppColors.error, size: 20),
                            label: const Text(
                              'Déconnexion',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.error, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Version ────────────────────────────────────
                        Text(
                          'ImmoPro v1.0.0',
                          style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets privés
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final dynamic user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final pic = user.profilePicture as String?;
    if (pic != null && pic.isNotEmpty) {
      return Image.network(
        pic,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Initials(name: user.fullName as String),
      );
    }
    return _Initials(name: user.fullName as String);
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFF1A56A0),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003E7E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  final dynamic user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Email',
            value: user.email as String,
            verified: user.isEmailVerified as bool,
          ),
          const Divider(height: 1, color: Color(0xFFECEEF0)),
          _InfoRow(
            label: 'Téléphone',
            value: user.telephone as String,
          ),
          const Divider(height: 1, color: Color(0xFFECEEF0)),
          _InfoRow(
            label: 'Localisation',
            value: [user.city, user.country]
                .where((s) => (s as String).isNotEmpty)
                .join(', '),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool verified;

  const _InfoRow({
    required this.label,
    required this.value,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (verified)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 13, color: Color(0xFF003E7E)),
                  SizedBox(width: 4),
                  Text(
                    'VÉRIFIÉ',
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003E7E),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
