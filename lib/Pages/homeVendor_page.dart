import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flat_up/Pages/conversations_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:flat_up/Pages/addEditApartmentPage.dart';
import 'package:flat_up/Pages/favourite_page.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Pages/myFlat_page.dart';
import 'package:flat_up/Pages/my_booking_page.dart';
import 'package:flat_up/Servicse/get_all_apartment_services.dart';
import 'package:flat_up/Servicse/getallprovines_services.dart';
import 'package:flat_up/Servicse/postLogout_services.dart';
import 'package:flat_up/components/appBar.dart';
import 'package:flat_up/components/bottom_nav_bar.dart';
import 'package:flat_up/components/build_error_state.dart';
import 'package:flat_up/components/drawer.dart';
import 'package:flat_up/components/filter_bottom_sheet.dart';
import 'package:flat_up/components/home_vendor_body.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomevendorPage extends StatefulWidget {
  HomevendorPage({super.key});
  static String id = 'HomevendorPage';

  @override
  State<HomevendorPage> createState() => _HomeState();
}

class _HomeState extends State<HomevendorPage> {
  final HomeController controller = Get.find<HomeController>();

  // متغيرات الـ Pagination والبحث
  List<ApartmentModel> _allApartments = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  String? _searchQuery;
  TextEditingController _searchController = TextEditingController();
  bool isLoading = false;

  // متغيرات الفلترة
  RangeValues _priceRange = const RangeValues(0, 1000000);
  ProvinesModels? _selectedProvince;
  String? _selectedPropertyType;
  int? _selectedRoomsCount;
  String? _selectedRentType;
  bool _filtersApplied = false;

  // قائمة المحافظات من الخادم
  List<ProvinesModels> _backendProvinces = [];
  bool _loadingProvinces = false;

  // متغيرات التحكم في حالة الخطأ
  bool _hasError = false;
  String _errorMessage = '';

  // متغيرات التحكم في عرض مؤشر التحميل عند تغيير اللغة
  bool _isChangingLanguage = false;

 @override
void initState() {
  super.initState();

  _initHome();
}
Future<void> _initHome() async {
  await _loadUserStatus(); // أول شي نحدد tenant أو landlord

  // بعد ما نعرف نوع المستخدم نحدد الصفحة الافتراضية
  if (controller.userStatus.value == 'tenant') {
    controller.changePage(3); // Home للـ tenant
  } else {
    controller.changePage(4); // Home للـ landlord
  }

  _loadInitialApartments();
  _loadProvincesFromBackend();

  // الاستماع لتغيير اللغة (متل ما عندك)
  controller.currentLanguage.listen((_) {
    if (mounted) {
      _refreshOnLanguageChange();
    }
  });
}


  void openTabFromOutside(int index) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.changePage(index);
  });
}

  // دالة خاصة لتحديث البيانات عند تغيير اللغة
  Future<void> _refreshOnLanguageChange() async {
    // عرض مؤشر التحميل
    setState(() {
      _isChangingLanguage = true;
    });

    try {
      // تحديث المحافظات أولاً
      await _refreshProvinces();

      // ثم تحديث الشقق
      await _refreshApartments();

      // إخفاء مؤشر التحميل بعد الانتهاء
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في تحديث البيانات بعد تغيير اللغة: $e');
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
        });
      }
    }
  }

  Future<void> _refreshProvinces() async {
    if (!mounted) return;

    try {
      setState(() {
        _loadingProvinces = true;
      });

      // جلب المحافظات باللغة الحالية
      final list = await GetallprovinesServices().getProvines();

      if (mounted) {
        setState(() {
          _backendProvinces = list;
          _loadingProvinces = false;
          // إذا كانت هناك محافظة محفوظة، البحث عنها في القائمة الجديدة
          if (_selectedProvince != null) {
            final updatedProvince = list.firstWhere(
              (province) => province.id == _selectedProvince!.id,
              orElse: () => _selectedProvince!,
            );
            _selectedProvince = updatedProvince;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvinces = false;
        });
      }
    }
  }

  // دالة لتحميل حالة المستخدم من SharedPreferences
  Future<void> _loadUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? status = prefs.getString('role');
      controller.updateUserStatus(status ?? 'tenant');
      print('✅ حالة المستخدم: ${controller.userStatus.value}');
    } catch (e) {
      print('❌ خطأ في تحميل حالة المستخدم: $e');
      controller.updateUserStatus('tenant');
    }
  }

  // دالة لتحميل المحافظات من الخادم عبر API
  Future<void> _loadProvincesFromBackend() async {
    try {
      setState(() {
        _loadingProvinces = true;
      });

      // جلب المحافظات باللغة الحالية
      final list = await GetallprovinesServices().getProvines();

      setState(() {
        _backendProvinces = list;
      });
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      // if (mounted) {
      //   final localizations = LocalizationService.of(context);
      //   SnackBarWidget(
      //     context,
      //     localizations.translate('loading_provinces_error'),
      //     SnackType.error,
      //   );
      // }
    } finally {
      setState(() {
        _loadingProvinces = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة مساعدة للتحقق من الفلترات النشطة
  bool _hasActiveFilters() {
    bool hasActiveFilter = false;

    // تحقق من فلترة السعر (للمستأجر فقط)
    if (controller.userStatus.value == 'tenant') {
      if (_priceRange.start > 0 || _priceRange.end < 1000000) {
        hasActiveFilter = true;
      }
    }

    // تحقق من فلترة المحافظة
    if (_selectedProvince != null) {
      hasActiveFilter = true;
    }

    // تحقق من فلترة نوع العقار
    if (_selectedPropertyType != null && _selectedPropertyType!.isNotEmpty) {
      hasActiveFilter = true;
    }

    // تحقق من فلترة عدد الغرف
    if (_selectedRoomsCount != null) {
      hasActiveFilter = true;
    }

    // تحقق من فلترة نوع الإيجار (للمستأجر فقط)
    if (controller.userStatus.value == 'tenant' &&
        _selectedRentType != null &&
        _selectedRentType!.isNotEmpty) {
      hasActiveFilter = true;
    }

    return hasActiveFilter;
  }

  // تحميل الصفحة الأولى مع الفلترة
  Future<void> _loadInitialApartments() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _hasError = false;
        _errorMessage = '';
      });

      List<ApartmentModel> firstPage = await GetAllApartment()
          .getApartmentsByPage(
            1,
            q: _searchQuery,
            minPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.start
                : null,
            maxPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.end
                : null,
            provinceId: _selectedProvince?.id,
            propertyType: _selectedPropertyType,
            roomsCount: _selectedRoomsCount,
            rentType: controller.userStatus.value == 'tenant'
                ? _selectedRentType
                : null,
          );

      setState(() {
        _allApartments = firstPage;
        _hasMoreData = firstPage.isNotEmpty && firstPage.length >= 10;
        _isInitialLoading = false;
        _currentPage = 1;
        _filtersApplied = _hasActiveFilters();
        _hasError = false;
      });

      print("✅ تم تحميل ${firstPage.length} شقة");
    } catch (e) {
      print("❌ خطأ في تحميل الصفحة الأولى: $e");
      setState(() {
        _isInitialLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // تحميل المزيد من البيانات (الصفحة التالية)
  Future<void> _loadMoreApartments() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      int nextPage = _currentPage + 1;

      List<ApartmentModel> newApartments = await GetAllApartment()
          .getApartmentsByPage(
            nextPage,
            q: _searchQuery,
            minPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.start
                : null,
            maxPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.end
                : null,
            provinceId: _selectedProvince?.id,
            propertyType: _selectedPropertyType,
            roomsCount: _selectedRoomsCount,
            rentType: controller.userStatus.value == 'tenant'
                ? _selectedRentType
                : null,
          );

      setState(() {
        if (newApartments.isNotEmpty) {
          _allApartments.addAll(newApartments);
          _currentPage = nextPage;
          _hasMoreData = newApartments.length >= 10;
          print("✅ تم إضافة ${newApartments.length} شقة جديدة");
        } else {
          _hasMoreData = false;
          print("🏁 تم الوصول لنهاية البيانات");
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      print("❌ خطأ في تحميل المزيد: $e");
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // تحديث الصفحة (سحب للتحديث)
  Future<void> _refreshApartments() async {
    if (_isRefreshing) return;

    print("🔄 بدء تحديث الشقق...");

    setState(() {
      _isRefreshing = true;
      _hasError = false;
      _errorMessage = '';
    });

    await Future.delayed(Duration(milliseconds: 300));

    try {
      // إعادة تعيين المتغيرات
      _allApartments.clear();
      _currentPage = 1;
      _hasMoreData = true;

      // تحميل البيانات الجديدة
      List<ApartmentModel> firstPage = await GetAllApartment()
          .getApartmentsByPage(
            1,
            q: _searchQuery,
            minPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.start
                : null,
            maxPrice: controller.userStatus.value == 'tenant'
                ? _priceRange.end
                : null,
            provinceId: _selectedProvince?.id,
            propertyType: _selectedPropertyType,
            roomsCount: _selectedRoomsCount,
            rentType: controller.userStatus.value == 'tenant'
                ? _selectedRentType
                : null,
          );

      setState(() {
        _allApartments = firstPage;
        _hasMoreData = firstPage.isNotEmpty && firstPage.length >= 10;
        _isInitialLoading = false;
        _currentPage = 1;
        _filtersApplied = _hasActiveFilters();
        _hasError = false;
        _isRefreshing = false;
      });

      print("✅ تم تحديث الشقق بنجاح - ${firstPage.length} شقة");
    } catch (e) {
      print("❌ خطأ في تحديث الشقق: $e");
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isRefreshing = false;
      });
    }
  }

  // دالة البحث
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.isNotEmpty ? query : null;
      _filtersApplied = _hasActiveFilters();
    });
    _loadInitialApartments();
  }

  // دالة لمسح البحث
  void _clearSearch() {
    print("🗑️ مسح البحث");
    setState(() {
      _searchQuery = null;
      _searchController.clear();
    });
    _loadInitialApartments();
  }

  // دالة للحصول على اسم نوع العقار بلغة التطبيق
  String _getPropertyTypeName(String type) {
    final localizations = LocalizationService.of(context);
    Map<String, String> propertyTypeNames = {
      'shop': localizations.translate('shop') ?? 'متجر',
      'apartment': localizations.translate('apartment') ?? 'شقة',
      'warehouse': localizations.translate('warehouse') ?? 'مستودع',
      'house': localizations.translate('house') ?? 'منزل',
      'villa': localizations.translate('villa') ?? 'فيلا',
      'studio': localizations.translate('studio') ?? 'ستوديو',
      'office': localizations.translate('office') ?? 'مكتب',
    };

    return propertyTypeNames[type] ?? type;
  }

  // دالة للحصول على اسم نوع الإيجار بلغة التطبيق
  String _getRentTypeName(String type) {
    final localizations = LocalizationService.of(context);
    Map<String, String> rentTypeNames = {
      'monthly': localizations.translate('monthly') ?? 'شهري',
      'yearly': localizations.translate('yearly') ?? 'سنوي',
    };

    return rentTypeNames[type] ?? type;
  }

  // دالة لتغيير الصفحة مع عمل ريفرش عند الانتقال للهوم
  void _changePageWithRefresh(int index) {
    final bool isHomePage =
        (controller.userStatus.value == 'landlord' && index == 4) ||
        (controller.userStatus.value == 'tenant' && index == 3);

    if (isHomePage) {
      print("🔄 تحديث الصفحة الرئيسية عند الانتقال إليها");
      _refreshApartments();
    }

    controller.changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context);
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;

    return ModalProgressHUD(
      inAsyncCall: isLoading || _isChangingLanguage,
      progressIndicator: Center(
        child: CircularProgressIndicator(color: colors.primary, strokeWidth: 4),
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: colors.onPrimary,
          appBar: buildAppBar(
            context,
            localizations,
            onSearch: _performSearch,
            onClearSearch: _clearSearch,
            searchController: _searchController,
            colors: colors,
          ),
          endDrawer: buildDrawer(
            context,
            localizations,
            themeController,
            isDark,
            () {
              Get.defaultDialog(
                title: localizations.translate('logOut'),
                middleText: localizations.translate('confirmLogout'),
                textConfirm: localizations.translate('logOut'),
                textCancel: localizations.translate('cancel'),
                onConfirm: () async {
                  Get.back();
                  setState(() => isLoading = true);
                  try {
                    final result = await PostlogoutServices().logoutUser();
                    final message = result['message']?.toString() ?? '';
                    if (message.isNotEmpty) {
                      SnackBarWidget(context, message, SnackType.success);
                      final prefs = await SharedPreferences.getInstance();
                      await DefaultCacheManager().emptyCache();
                      await prefs.clear();
                      await prefs.setBool('has_seen_get_started', true);
                    }
                    Navigator.pushReplacementNamed(context, LoginPage.id);
                  } catch (e) {
                    SnackBarWidget(
                      context,
                      e.toString().replaceAll('Exception: ', ''),
                      SnackType.error,
                    );
                  }
                  setState(() => isLoading = false);
                },
              );
            },
            colors,
          ),
          body: Obx(() {
            return _buildCurrentPage(
              controller.currentIndex.value,
              localizations,
            );
          }),
          bottomNavigationBar: Obx(() {
            return buildBottomNavigationBar(
              context,
              localizations,
              controller.currentIndex.value,
              _changePageWithRefresh,
              controller.userStatus.value,
            );
          }),
          floatingActionButton: Obx(() {
            return controller.userStatus.value == 'landlord'
                ? _buildFloatingActionButton(context)
                : const SizedBox.shrink();
          }),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  // بناء الصفحة الحالية
  Widget _buildCurrentPage(int index, LocalizationService localizations) {
    final colors = Theme.of(context).colorScheme;

    _filtersApplied = _hasActiveFilters();

    // إذا كان هناك خطأ في تحميل البيانات، عرض حالة الخطأ للصفحة الرئيسية فقط
    if (_hasError &&
        ((controller.userStatus.value == 'landlord' && index == 4) ||
            (controller.userStatus.value == 'tenant' && index == 3))) {
      return buildErrorState(
        localizations,
        colors,
        _errorMessage,
        _loadInitialApartments,
      );
    }

    // إذا كان في حالة refreshing، عرض مؤشر تحميل
    if (_isRefreshing &&
        ((controller.userStatus.value == 'landlord' && index == 4) ||
            (controller.userStatus.value == 'tenant' && index == 3))) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.primary, strokeWidth: 4),
            SizedBox(height: 16),
            Text(
              localizations.translate('loading_data'),
              style: TextStyle(
                color: colors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.userStatus.value == 'landlord') {
      switch (index) {
        case 0:
          return ConversationsPage();
        case 1:
          return MyflatPage();
        case 3:
          return FavouritePage();
        case 4:
          return HomeVendorBody(
            localization: localizations,
            controller: controller,
            allApartments: _allApartments,
            isInitialLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMoreData: _hasMoreData,
            searchQuery: _searchQuery,
            priceRange: _priceRange,
            selectedProvince: _selectedProvince,
            selectedPropertyType: _selectedPropertyType,
            selectedRoomsCount: _selectedRoomsCount,
            selectedRentType: _selectedRentType,
            filtersApplied: _filtersApplied,
            backendProvinces: _backendProvinces,
            loadingProvinces: _loadingProvinces,
            onRefresh: _refreshApartments,
            onLoadMore: _loadMoreApartments,
            onClearSearch: _clearSearch,
            onClearFilters: () {
              setState(() {
                _priceRange = const RangeValues(0, 1000000);
                _selectedProvince = null;
                _selectedPropertyType = null;
                _selectedRoomsCount = null;
                _selectedRentType = null;
                _filtersApplied = false;
              });
              _loadInitialApartments();
            },
            showFilterBottomSheet: () => _showFilterBottomSheet(),
            getPropertyTypeName: _getPropertyTypeName,
            getRentTypeName: _getRentTypeName,
          );
        default:
          return HomeVendorBody(
            localization: localizations,
            controller: controller,
            allApartments: _allApartments,
            isInitialLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMoreData: _hasMoreData,
            searchQuery: _searchQuery,
            priceRange: _priceRange,
            selectedProvince: _selectedProvince,
            selectedPropertyType: _selectedPropertyType,
            selectedRoomsCount: _selectedRoomsCount,
            selectedRentType: _selectedRentType,
            filtersApplied: _filtersApplied,
            backendProvinces: _backendProvinces,
            loadingProvinces: _loadingProvinces,
            onRefresh: _refreshApartments,
            onLoadMore: _loadMoreApartments,
            onClearSearch: _clearSearch,
            onClearFilters: () {
              setState(() {
                _priceRange = const RangeValues(0, 1000000);
                _selectedProvince = null;
                _selectedPropertyType = null;
                _selectedRoomsCount = null;
                _selectedRentType = null;
                _filtersApplied = false;
              });
              _loadInitialApartments();
            },
            showFilterBottomSheet: () => _showFilterBottomSheet(),
            getPropertyTypeName: _getPropertyTypeName,
            getRentTypeName: _getRentTypeName,
          );
      }
    } else {
      switch (index) {
        case 0:
          return ConversationsPage();
        case 1:
          return MyBookingPage();
        case 2:
          return FavouritePage();
        case 3:
          return HomeVendorBody(
            localization: localizations,
            controller: controller,
            allApartments: _allApartments,
            isInitialLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMoreData: _hasMoreData,
            searchQuery: _searchQuery,
            priceRange: _priceRange,
            selectedProvince: _selectedProvince,
            selectedPropertyType: _selectedPropertyType,
            selectedRoomsCount: _selectedRoomsCount,
            selectedRentType: _selectedRentType,
            filtersApplied: _filtersApplied,
            backendProvinces: _backendProvinces,
            loadingProvinces: _loadingProvinces,
            onRefresh: _refreshApartments,
            onLoadMore: _loadMoreApartments,
            onClearSearch: _clearSearch,
            onClearFilters: () {
              setState(() {
                _priceRange = const RangeValues(0, 1000000);
                _selectedProvince = null;
                _selectedPropertyType = null;
                _selectedRoomsCount = null;
                _selectedRentType = null;
                _filtersApplied = false;
              });
              _loadInitialApartments();
            },
            showFilterBottomSheet: () => _showFilterBottomSheet(),
            getPropertyTypeName: _getPropertyTypeName,
            getRentTypeName: _getRentTypeName,
          );
        default:
          return HomeVendorBody(
            localization: localizations,
            controller: controller,
            allApartments: _allApartments,
            isInitialLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMoreData: _hasMoreData,
            searchQuery: _searchQuery,
            priceRange: _priceRange,
            selectedProvince: _selectedProvince,
            selectedPropertyType: _selectedPropertyType,
            selectedRoomsCount: _selectedRoomsCount,
            selectedRentType: _selectedRentType,
            filtersApplied: _filtersApplied,
            backendProvinces: _backendProvinces,
            loadingProvinces: _loadingProvinces,
            onRefresh: _refreshApartments,
            onLoadMore: _loadMoreApartments,
            onClearSearch: _clearSearch,
            onClearFilters: () {
              setState(() {
                _priceRange = const RangeValues(0, 1000000);
                _selectedProvince = null;
                _selectedPropertyType = null;
                _selectedRoomsCount = null;
                _selectedRentType = null;
                _filtersApplied = false;
              });
              _loadInitialApartments();
            },
            showFilterBottomSheet: () => _showFilterBottomSheet(),
            getPropertyTypeName: _getPropertyTypeName,
            getRentTypeName: _getRentTypeName,
          );
      }
    }
  }

  // عرض Bottom Sheet للفلترة
  void _showFilterBottomSheet() {
    final colors = Theme.of(context).colorScheme;
    final localizations = LocalizationService.of(context);

    print('🔄 عرض FilterBottomSheet');

    Get.bottomSheet(
      FilterBottomSheet(
        localizations: localizations,
        priceRange: _priceRange,
        selectedProvince: _selectedProvince,
        selectedPropertyType: _selectedPropertyType,
        selectedRoomsCount: _selectedRoomsCount,
        selectedRentType: _selectedRentType,
        filtersApplied: _filtersApplied,
        backendProvinces: _backendProvinces,
        loadingProvinces: _loadingProvinces,
        userStatus: controller.userStatus.value,
        searchQuery: _searchQuery,
        onApplyFilters:
            (
              RangeValues newPriceRange,
              ProvinesModels? newProvince,
              String? newPropertyType,
              int? newRoomsCount,
              String? newRentType,
            ) {
              print('✅ تطبيق الفلترات الجديدة');

              setState(() {
                _priceRange = newPriceRange;
                _selectedProvince = newProvince;
                _selectedPropertyType = newPropertyType;
                _selectedRoomsCount = newRoomsCount;
                _selectedRentType = newRentType;
                _filtersApplied = _hasActiveFilters();
              });

              _loadInitialApartments();
            },
        getPropertyTypeName: _getPropertyTypeName,
        getRentTypeName: _getRentTypeName,
      ),
      backgroundColor: colors.onPrimary,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      enableDrag: true,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Transform.translate(
      offset: const Offset(0, 9),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.secondary],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AddEditApartmentPage.id);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
