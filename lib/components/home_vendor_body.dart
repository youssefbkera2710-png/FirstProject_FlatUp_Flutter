import 'package:flat_up/components/active_filters_indicator.dart';
import 'package:flat_up/components/active_search_indeicator.dart';
import 'package:flat_up/components/apartment_card.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:flat_up/components/section_header.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';
import 'package:get/get.dart';

class HomeVendorBody extends StatelessWidget {
  final LocalizationService localization;
  final HomeController controller;
  final List<ApartmentModel> allApartments;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String? searchQuery;
  final RangeValues priceRange;
  final ProvinesModels? selectedProvince;
  final String? selectedPropertyType;
  final int? selectedRoomsCount;
  final String? selectedRentType;
  final bool filtersApplied;
  final List<ProvinesModels> backendProvinces;
  final bool loadingProvinces;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final Function() onClearSearch;
  final Function() onClearFilters;
  final Function() showFilterBottomSheet;
  final String Function(String) getPropertyTypeName;
  final String Function(String) getRentTypeName;

  const HomeVendorBody({
    Key? key,
    required this.localization,
    required this.controller,
    required this.allApartments,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    this.searchQuery,
    required this.priceRange,
    this.selectedProvince,
    this.selectedPropertyType,
    this.selectedRoomsCount,
    this.selectedRentType,
    required this.filtersApplied,
    required this.backendProvinces,
    required this.loadingProvinces,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onClearSearch,
    required this.onClearFilters,
    required this.showFilterBottomSheet,
    required this.getPropertyTypeName,
    required this.getRentTypeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // مؤشر حالة المستخدم

                // مؤشر البحث النشط
                if (searchQuery != null && searchQuery!.isNotEmpty)
                  ActiveSearchIndicator(
                    searchQuery: searchQuery!,
                    onClear: onClearSearch,
                  ),

                // مؤشر الفلترة النشطة
                if (filtersApplied)
                  ActiveFiltersIndicator(
                    localizations: localizations,
                    priceRange: priceRange,
                    selectedProvince: selectedProvince,
                    selectedPropertyType: selectedPropertyType,
                    selectedRoomsCount: selectedRoomsCount,
                    selectedRentType: selectedRentType,
                    filtersApplied: filtersApplied,
                    userStatus: controller.userStatus.value,
                    onClearFilters: onClearFilters,
                    getPropertyTypeName: getPropertyTypeName,
                    getRentTypeName: getRentTypeName,
                  ),

                SectionHeader(
                  title: localizations.translate('recentProperties'),
                  onSeeAll: showFilterBottomSheet,
                  localizations: localizations,
                ),
              ],
            ),
          ),
          _buildPropertiesGrid(context),
          SliverToBoxAdapter(child: _buildLoadMoreSection(context)),
        ],
      ),
    );
  }

  Widget _buildPropertiesGrid(BuildContext context) {
    if (isInitialLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(localization.translate('loading_data')),
              ],
            ),
          ),
        ),
      );
    }

    if (allApartments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, color: Colors.grey, size: 50),
                SizedBox(height: 10),
                Text(
                  searchQuery != null && searchQuery!.isNotEmpty
                      ? '${localization.translate('no_results_for')} "$searchQuery" ${localization.translate('within_applied_filters')}'
                      : filtersApplied
                      ? localization.translate('no_results_for_filters')
                      : localization.translate('no_apartments_available'),
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                if (filtersApplied)
                  ElevatedButton(
                    onPressed: onClearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(localization.translate('reset_filter')),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ApartmentCard(
            apartment: allApartments[index],

            controller: controller,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleProductPage(
                    apartmentId: allApartments[index].id,
                    statusLandLordFromHome: allApartments[index].status ?? null,
                  ),
                ),
              );
            },
            localization: localization,
          ),
        );
      }, childCount: allApartments.length),
    );
  }

  Widget _buildLoadMoreSection(BuildContext context) {
    // أثناء التحميل الأولي: لا نعرض أي شيء
    if (isInitialLoading) {
      return SizedBox.shrink();
    }

    // أثناء تحميل المزيد: نعرض مؤشر التحميل
    if (isLoadingMore) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(localization.translate('load_more')),
            ],
          ),
        ),
      );
    }

    // إذا لم يكن هناك المزيد من البيانات: نعرض رسالة النهاية
    if (!hasMoreData) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(height: 8),
              Text(
                localization.translate('all_apartments_shown'),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 5),
              Text(
                " ${localization.translate('total_apartments')} ${allApartments.length}",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // إذا كان هناك المزيد من البيانات: نعرض زر "عرض المزيد"
    if (hasMoreData && allApartments.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: onLoadMore,
            icon: Icon(Icons.add),
            label: Text(localization.translate('show_more')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}
