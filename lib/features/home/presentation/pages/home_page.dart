import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/property_card.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_recent_properties_usecase.dart';
import '../../domain/usecases/get_properties_by_category_usecase.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_property_detail_usecase.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'property_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final GetPropertyDetailUseCase _getDetailUseCase;
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final remoteDataSource = HomeRemoteDataSourceImpl();
    final repository = HomeRepositoryImpl(remoteDataSource: remoteDataSource);

    _getDetailUseCase = GetPropertyDetailUseCase(repository);

    _controller = HomeController(
      getRecentPropertiesUseCase: GetRecentPropertiesUseCase(repository),
      getPropertiesByCategoryUseCase: GetPropertiesByCategoryUseCase(repository),
      searchPropertiesUseCase: SearchPropertiesUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryContainer,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _controller.init();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
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
        // HomeAppBar comme vrai appBar du Scaffold → status bar gérée automatiquement
        appBar: HomeAppBar(
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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  Expanded(
                    child: _buildBody(context),
                  ),
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
            controller: _searchTextController,
            hasActiveFilters: _controller.hasActiveFilters,
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
      ],
    );
  }

  Widget _buildPropertiesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _controller.hasActiveFilters ||
                          _searchTextController.text.isNotEmpty
                      ? 'Résultats'
                      : 'Biens récents',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                if (_controller.hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      _searchTextController.clear();
                      _controller.clearFilters();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.clear, color: AppColors.error, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
                        Icon(Icons.chevron_right,
                            color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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

  Widget _buildPropertyList() {
    if (_controller.properties.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, color: AppColors.outline, size: 48),
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
          const Icon(Icons.wifi_off_rounded, color: AppColors.outline, size: 48),
          const SizedBox(height: 12),
          Text(
            _controller.errorMessage ??
                'Impossible de charger les biens',
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailPage(
          property: property,
          getDetailUseCase: _getDetailUseCase,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialTypeTransaction: _controller.filterTypeTransaction,
        initialPrixMin: _controller.filterPrixMin,
        initialPrixMax: _controller.filterPrixMax,
        initialSurfaceMin: _controller.filterSurfaceMin,
        onApply: (typeTransaction, prixMin, prixMax, surfaceMin) {
          _controller.applyFilters(
            typeTransaction: typeTransaction,
            prixMin: prixMin,
            prixMax: prixMax,
            surfaceMin: surfaceMin,
            currentQuery: _searchTextController.text,
          );
        },
        onClear: () {
          _searchTextController.clear();
          _controller.clearFilters();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

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
                color: const Color(0xFF1A56A0).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Row(children: [
                      _shimmerBox(60, 12),
                      const SizedBox(width: 12),
                      _shimmerBox(60, 12),
                      const SizedBox(width: 12),
                      _shimmerBox(60, 12),
                    ]),
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

// ─────────────────────────────────────────────────────────────────────────────
// Filtre bottom sheet (fonctionnel)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBottomSheet extends StatefulWidget {
  final String? initialTypeTransaction;
  final double? initialPrixMin;
  final double? initialPrixMax;
  final double? initialSurfaceMin;
  final void Function(
    String? typeTransaction,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
  ) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    this.initialTypeTransaction,
    this.initialPrixMin,
    this.initialPrixMax,
    this.initialSurfaceMin,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _typeTransaction;
  final _prixMinController = TextEditingController();
  final _prixMaxController = TextEditingController();
  final _surfaceMinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _typeTransaction = widget.initialTypeTransaction;
    if (widget.initialPrixMin != null) {
      _prixMinController.text = widget.initialPrixMin!.toInt().toString();
    }
    if (widget.initialPrixMax != null) {
      _prixMaxController.text = widget.initialPrixMax!.toInt().toString();
    }
    if (widget.initialSurfaceMin != null) {
      _surfaceMinController.text =
          widget.initialSurfaceMin!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _prixMinController.dispose();
    _prixMaxController.dispose();
    _surfaceMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  child: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Type de transaction
            const Text(
              'TYPE DE TRANSACTION',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _TypeChip(
                    label: 'Vente',
                    value: 'vente',
                    selected: _typeTransaction == 'vente',
                    onTap: () => setState(() => _typeTransaction =
                        _typeTransaction == 'vente' ? null : 'vente')),
                _TypeChip(
                    label: 'Location',
                    value: 'location',
                    selected: _typeTransaction == 'location',
                    onTap: () => setState(() => _typeTransaction =
                        _typeTransaction == 'location' ? null : 'location')),
                _TypeChip(
                    label: 'Colocation',
                    value: 'colocation',
                    selected: _typeTransaction == 'colocation',
                    onTap: () => setState(() => _typeTransaction =
                        _typeTransaction == 'colocation'
                            ? null
                            : 'colocation')),
              ],
            ),
            const SizedBox(height: 20),

            // Fourchette de prix
            const Text(
              'PRIX (€)',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterTextField(
                    controller: _prixMinController,
                    hint: 'Min',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                Expanded(
                  child: _FilterTextField(
                    controller: _prixMaxController,
                    hint: 'Max',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Surface minimale
            const Text(
              'SURFACE MINIMALE (m²)',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            _FilterTextField(
              controller: _surfaceMinController,
              hint: 'Ex: 50',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClear();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Effacer',
                      style: TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      final prixMin = double.tryParse(
                          _prixMinController.text.replaceAll(' ', ''));
                      final prixMax = double.tryParse(
                          _prixMaxController.text.replaceAll(' ', ''));
                      final surfaceMin = double.tryParse(
                          _surfaceMinController.text.replaceAll(' ', ''));
                      Navigator.pop(context);
                      widget.onApply(
                          _typeTransaction, prixMin, prixMax, surfaceMin);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(
                        fontFamily: 'HankenGrotesk',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FilterTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'HankenGrotesk',
        fontSize: 15,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.outlineVariant, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
