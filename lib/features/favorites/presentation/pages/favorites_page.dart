import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../home/presentation/widgets/property_card.dart';
import '../../../home/presentation/pages/property_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Recharger la liste pour être sûr d'avoir les données à jour
    ServiceLocator.instance.favoritesController.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: ServiceLocator.instance.favoritesController,
        builder: (context, _) {
          final ctrl = ServiceLocator.instance.favoritesController;

          if (ctrl.isLoading && ctrl.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.error != null && ctrl.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    ctrl.error!,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: ctrl.loadFavorites,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (ctrl.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun favori',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous n\'avez pas encore ajouté\nde biens à vos favoris.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: ctrl.loadFavorites,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final property = ctrl.favorites[index];
                return SizedBox(
                  height: 330,
                  child: PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailPage(
                            property: property,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
