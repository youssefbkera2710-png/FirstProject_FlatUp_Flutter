import 'package:flat_up/Pages/addEditApartmentPage.dart';
import 'package:flat_up/Servicse/delet_my_flat_services.dart';
import 'package:flat_up/Servicse/get_my_apartment_services.dart';
import 'package:flat_up/components/build_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';

class MyflatPage extends StatefulWidget {
  MyflatPage({super.key});
  static String id = 'MyflatPage';

  @override
  State<MyflatPage> createState() => _MyflatPageState();
}

class _MyflatPageState extends State<MyflatPage> {
  List<ApartmentModel> _myApartments = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  String? _searchQuery;
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialMyApartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMyApartments() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _hasError = false;
        _errorMessage = '';
      });

      final service = GetMyApartments();
      List<ApartmentModel> firstPage = await service.getMyApartmentsByPage(
        1,
        q: _searchQuery,
      );

      setState(() {
        _myApartments = firstPage;
        _hasMoreData = firstPage.isNotEmpty && firstPage.length >= 10;
        _isInitialLoading = false;
        _currentPage = 1;
        _hasError = false;
      });
    } catch (e) {
      print("❌ خطأ في تحميل الشقق الخاصة بالمستخدم: $e");
      setState(() {
        _isInitialLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreMyApartments() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      int nextPage = _currentPage + 1;
      final service = GetMyApartments();
      List<ApartmentModel> newApartments = await service.getMyApartmentsByPage(
        nextPage,
        q: _searchQuery,
      );

      setState(() {
        if (newApartments.isNotEmpty) {
          _myApartments.addAll(newApartments);
          _currentPage = nextPage;
          _hasMoreData = newApartments.length >= 10;
        } else {
          _hasMoreData = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      print("❌ خطأ في تحميل المزيد من الشقق الخاصة: $e");
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshMyApartments() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _hasError = false;
      _errorMessage = '';
    });

    await _loadInitialMyApartments();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.isNotEmpty ? query : null;
    });
    _loadInitialMyApartments();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _searchController.clear();
    });
    _loadInitialMyApartments();
  }

  String _getPropertyTypeName(String type, LocalizationService localizations) {
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

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';

    // معالجة الرابط بشكل صحيح
    if (url.startsWith('https://flatup.next99.net/storage/')) {
      // الرابط صحيح بالفعل
      return url;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/storage/')) {
      return 'https://flatup.next99.net$url';
    }

    // إذا كان الرابط يبدأ بـ 'storage/' بدون المائل الأول
    if (url.startsWith('storage/')) {
      return 'https://flatup.next99.net/$url';
    }

    // أي رابط آخر، نضيف المسار الأساسي
    return 'https://flatup.next99.net/storage/$url';
  }

  Map<String, dynamic> _getStatusInfo(
    String? status,
    LocalizationService localizations,
  ) {
    if (status == null || status.isEmpty) {
      return {
        'text': localizations.translate('unknown') ?? 'غير معروف',
        'color': Colors.grey,
        'icon': Icons.help_outline,
      };
    }

    String statusLower = status.toLowerCase();

    if (statusLower.contains('approved') || statusLower.contains('مقبول')) {
      return {
        'text': localizations.translate('approved'),
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    } else if (statusLower.contains('pending') ||
        statusLower.contains('قيد الانتظار')) {
      return {
        'text': localizations.translate('pending'),
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      };
    } else if (statusLower.contains('available') ||
        statusLower.contains('متاح')) {
      return {
        'text': localizations.translate('available'),
        'color': Colors.blue,
        'icon': Icons.visibility,
      };
    } else if (statusLower.contains('rejected') ||
        statusLower.contains('مرفوض')) {
      return {
        'text': localizations.translate('rejected'),
        'color': Colors.red,
        'icon': Icons.cancel,
      };
    } else if (statusLower.contains('draft') || statusLower.contains('مسودة')) {
      return {
        'text': localizations.translate('draft'),
        'color': Colors.grey,
        'icon': Icons.drafts,
      };
    } else if (statusLower.contains('rented') || statusLower.contains('مؤجر')) {
      return {
        'text': localizations.translate('rented') ?? 'مؤجر',
        'color': Colors.purple,
        'icon': Icons.attach_money,
      };
    } else if (statusLower.contains('expired') ||
        statusLower.contains('منتهي')) {
      return {
        'text': localizations.translate('expired'),
        'color': Colors.brown,
        'icon': Icons.timelapse,
      };
    } else {
      return {
        'text': status,
        'color': Colors.blueGrey,
        'icon': Icons.info_outline,
      };
    }
  }

  Future<void> _deleteApartment(ApartmentModel apartment, int index) async {
    final localizations = LocalizationService.of(context);

    if (!mounted) return;

    await Future.delayed(Duration.zero);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.translate('confirmDelete')),
          content: Text(localizations.translate('deleteApartmentConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                localizations.translate('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool deleteSuccess = await DeleteMyFlatServices().deleteMyApartment(
          apartment.id,
        );

        if (deleteSuccess) {
          setState(() {
            _myApartments.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('deleteSuccess')),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('deleteError')),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print("❌ خطأ غير متوقع في حذف الشقة: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ غير متوقع: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _editApartment(ApartmentModel apartment) {
    Navigator.pushNamed(
      context,
      AddEditApartmentPage.id,
      arguments: {'apartment': apartment},
    ).then((value) {
      // عند العودة من التعديل، تحديث القائمة
      if (value == true) {
        _refreshMyApartments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context);
    final themeController = Provider.of<Themes>(context);
    final colors = Theme.of(context).colorScheme;

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: colors.onPrimary,
        body: _buildBody(localizations, colors),
      ),
    );
  }

  Widget _buildBody(LocalizationService localizations, ColorScheme colors) {
    if (_hasError) {
      return buildErrorState(
        localizations,
        colors,
        _errorMessage,
        _loadMoreMyApartments,
      );
    }

    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              localizations.translate('loading_my_apartment'),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_myApartments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 80,
              color: colors.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              localizations.translate('noApartmentsAdded'),
              style: TextStyle(fontSize: 16, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                localizations.translate('addYourFirstApartment'),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMyApartments,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _myApartments.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _myApartments.length) {
            return _buildLoadMoreIndicator(localizations);
          }

          ApartmentModel apartment = _myApartments[index];
          return _buildApartmentCard(apartment, context, localizations, index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(LocalizationService localizations) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator()
            : Text(
                localizations.translate('pull_to_load_more'),
                style: TextStyle(color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildApartmentCard(
    ApartmentModel apartment,
    BuildContext context,
    LocalizationService localizations,
    int index,
  ) {
    final colors = Theme.of(context).colorScheme;

    // إصلاح: الحصول على الصورة الرئيسية بشكل صحيح
    String mainImageUrl = '';

    // إذا كان هناك صورة رئيسية، استخدمها
    if (apartment.mainImage != null && apartment.mainImage!.isNotEmpty) {
      mainImageUrl = _fixImageUrl(apartment.mainImage!);
    }
    // وإلا إذا كان هناك صور، استخدم الصورة الأولى
    else if (apartment.images != null && apartment.images!.isNotEmpty) {
      mainImageUrl = _fixImageUrl(apartment.images![0].path);
    }

    var statusInfo = _getStatusInfo(apartment.status, localizations);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: apartment.status == "rejected"
            ? null
            : () {
                _navigateToSingleProduct(context, apartment);
              },

        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colors.primary.withOpacity(0.1),
                    ),
                    child: mainImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              mainImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.apartment,
                                    size: 50,
                                    color: colors.primary.withOpacity(0.5),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.apartment,
                              size: 50,
                              color: colors.primary.withOpacity(0.5),
                            ),
                          ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo['icon'],
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'edit') {
                            _editApartment(apartment);
                          } else if (value == 'delete') {
                            _deleteApartment(apartment, index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: colors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(localizations.translate('edit')),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  localizations.translate('delete'),
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.more_vert,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Text(
                apartment.title ?? localizations.translate('noTitle'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (apartment.status == "rejected" &&
                  apartment.reject_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    apartment.reject_message!,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ),

              SizedBox(height: 8),

              if (apartment.description != null &&
                  apartment.description!.isNotEmpty)
                Text(
                  apartment.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              SizedBox(height: 8),

              Row(
                children: [
                  if (apartment.price != null)
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${apartment.price} ${localizations.translate('currency')}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  Spacer(),
                  if (apartment.propertyType != null)
                    Chip(
                      label: Text(
                        _getPropertyTypeName(
                          apartment.propertyType!,
                          localizations,
                        ),
                        style: TextStyle(fontSize: 12),
                      ),
                      backgroundColor: colors.primary.withOpacity(0.1),
                    ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  if (apartment.roomsCount != null)
                    Row(
                      children: [
                        Icon(
                          Icons.bed_outlined,
                          size: 14,
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${apartment.roomsCount} ${localizations.translate('rooms')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(width: 16),

                  if (apartment.bathroomsCount != null)
                    Row(
                      children: [
                        Icon(
                          Icons.bathtub_outlined,
                          size: 14,
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${apartment.bathroomsCount} ${localizations.translate('bathroom')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              if (apartment.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${localizations.translate('added_since')}: ${apartment.createdAt}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة جديدة للانتقال إلى صفحة تفاصيل الشقة
  void _navigateToSingleProduct(
    BuildContext context,
    ApartmentModel apartment,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleProductPage(
          apartmentId: apartment.id,
          status: apartment.status,
        ),
      ),
    );
  }
}
