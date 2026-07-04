import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/property_card.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/map_section.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_recent_properties_usecase.dart';
import '../../domain/usecases/get_properties_by_category_usecase.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();

    // Injection manuelle des dépendances (Clean Architecture)
    final datasource = HomeLocalDatasourceImpl();
    final repository = HomeRepositoryImpl(localDatasource: datasource);

    _controller = HomeController(
      getRecentPropertiesUseCase: GetRecentPropertiesUseCase(repository),
      getPropertiesByCategoryUseCase:
          GetPropertiesByCategoryUseCase(repository),
      searchPropertiesUseCase: SearchPropertiesUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
    );

    // Changement de la couleur de la barre de statut
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryContainer,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryContainer,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        // SafeArea pour éviter le débordement sur la barre de notification
        body: SafeArea(
          top: false, // On gère nous-même pour que la AppBar touche le haut
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  // AppBar avec fond couleur qui inclut le StatusBar
                  HomeAppBar(
                    userName: _controller.userName,
                    onNotificationTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onProfileTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  // Contenu scrollable
                  Expanded(
                    child: _buildBody(context),
                  ),
                  // Bottom Navigation Bar
                  HomeBottomNavBar(
                    currentIndex: _controller.currentNavIndex,
                    onTap: _controller.changeNavIndex,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Section Recherche
        SliverToBoxAdapter(
          child: SearchSection(
            onSearch: _controller.search,
            onFilterTap: () => _showFilterSheet(context),
          ),
        ),

        // Chips catégories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => CategoryChips(
                categories: _controller.categories,
                selectedCategory: _controller.selectedCategory,
                onCategorySelected: _controller.selectCategory,
              ),
            ),
          ),
        ),

        // Section "Biens récents"
        SliverToBoxAdapter(
          child: _buildPropertiesSection(context),
        ),

        // Section "Près de vous"
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: MapSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biens récents',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // État de chargement / erreur / données
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return switch (_controller.status) {
                HomeStatus.loading || HomeStatus.initial =>
                  _buildLoadingShimmer(),
                HomeStatus.error => _buildErrorWidget(),
                HomeStatus.loaded => _buildPropertyList(),
              };
            },
          ),
        ],
      ),
    );
  }

  /// Liste horizontale des biens
  Widget _buildPropertyList() {
    if (_controller.properties.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                color: AppColors.outline,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Aucun bien trouvé',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _controller.properties.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return PropertyCard(
            property: _controller.properties[index],
            onTap: () => _onPropertyTap(context, index),
          );
        },
      ),
    );
  }

  /// Skeleton loader animé pendant le chargement
  Widget _buildLoadingShimmer() {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _ShimmerCard(),
      ),
    );
  }

  /// Widget d'erreur avec bouton retry
  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.outline,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Impossible de charger les biens',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _controller.init,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPropertyTap(BuildContext context, int index) {
    final property = _controller.properties[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture : ${property.title}'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryContainer,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(),
    );
  }
}

/// Carte skeleton animée pour le chargement
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 272,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56A0).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value, 0),
                      colors: const [
                        Color(0xFFECEEF0),
                        Color(0xFFF7F9FB),
                        Color(0xFFECEEF0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120, 16),
                    const SizedBox(height: 10),
                    _shimmerBox(double.infinity, 12),
                    const SizedBox(height: 6),
                    _shimmerBox(180, 12),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _shimmerBox(60, 12),
                        const SizedBox(width: 12),
                        _shimmerBox(60, 12),
                        const SizedBox(width: 12),
                        _shimmerBox(60, 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Bottom sheet pour les filtres
class _FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Type de transaction',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: ['Vente', 'Location', 'Colocation'].map((label) {
              return FilterChip(
                label: Text(label),
                selected: label == 'Vente',
                onSelected: (_) {},
                selectedColor: AppColors.primaryContainer,
                labelStyle: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 13,
                ),
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Appliquer les filtres',
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
