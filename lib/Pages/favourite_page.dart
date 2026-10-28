import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Servicse/getAllFav_services.dart';
import 'package:flat_up/components/build_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/components/apartment_card.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/Helper/themes.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});
  static String id = 'FavouritePage';

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final HomeController controller = Get.find<HomeController>();
  final GetFavoriteApartmentsService _favoritesService =
      GetFavoriteApartmentsService();
  List<ApartmentModel> _favoriteApartments = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;

      if (args != null && args['from_notification'] == true) {
        _loadFavorites(); // Refresh تلقائي
      } else {
        _loadFavorites(); // فتح عادي
      }
    });
  }

  Future<void> _loadFavorites() async {
    if (_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final List<ApartmentModel> favorites = await _favoritesService
          .getFavorites();

      setState(() {
        _favoriteApartments = favorites;
        _isLoading = false;
        _isRefreshing = false;
        _hasError = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل المفضلة: $e');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _refreshFavorites() async {
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context);
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.onPrimary,

      body: _buildBody(context, localizations, colors),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LocalizationService localizations,
    ColorScheme colors,
  ) {
    if (_isLoading) {
      return _buildLoadingState(localizations);
    }

    if (_hasError) {
      return buildErrorState(
        localizations,
        colors,
        _errorMessage,
        _loadFavorites,
      );
    }

    if (_favoriteApartments.isEmpty) {
      return _buildEmptyState(localizations, colors);
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      color: colors.primary,
      backgroundColor: colors.onPrimary,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final apartment = _favoriteApartments[index];
                return ApartmentCard(
                  apartment: apartment,
                  controller: controller,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SingleProductPage(apartmentId: apartment.id),
                      ),
                    );
                  },
                  localization: localizations,
                );
              }, childCount: _favoriteApartments.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(LocalizationService localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            localizations.translate('loading_favorites'),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    LocalizationService localizations,
    ColorScheme colors,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  localizations.translate('no_favorites'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    localizations.translate('add_properties_to_favorites'),
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
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
