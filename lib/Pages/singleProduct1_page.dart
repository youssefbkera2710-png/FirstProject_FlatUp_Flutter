import 'package:flat_up/Controller/chat_controller.dart';
import 'package:flat_up/Models/conversation_model.dart';
import 'package:flat_up/Pages/chat_page.dart';
import 'package:flat_up/Pages/conversations_page.dart';
import 'package:flat_up/Servicse/chat_api.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Helper/localization_service.dart'; // أضف هذا الاستيراد
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Pages/apartmentBookings_page.dart';
import 'package:flat_up/Pages/completeBooking_page.dart';
import 'package:flat_up/Pages/review_page.dart';
import 'package:flat_up/Servicse/getCheckFavApartment.dart';
import 'package:flat_up/Servicse/getSingleProduct_services.dart';
import 'package:flat_up/Servicse/postToggleFav_services.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flat_up/widget/starRating_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleProductPage extends StatefulWidget {
  final int? apartmentId;
  final String? status;
  final String? statusBooking;
  final String? statusLandLordFromHome;
  const SingleProductPage({
    Key? key,
    this.apartmentId,
    this.status,
    this.statusBooking,
    this.statusLandLordFromHome,
  }) : super(key: key);

  static String id = 'SingleProductPage';

  @override
  State<SingleProductPage> createState() => _SingleProductPageState();
}

class _SingleProductPageState extends State<SingleProductPage> {
  bool isLoading = false;
  ApartmentModel? apartment;
  int _currentImageIndex = 0;
  bool isFavorite = false;
  String? role;

  @override
  void initState() {
    super.initState();
    chechFavApartment();
    _loadApartmentDetails();
    loadRole();
  }

  Future<void> chechFavApartment() async {
    try {
      final result = await Getcheckfavapartment().getCheckFav(
        apartmentId: widget.apartmentId!,
      );
      setState(() {
        isFavorite = result['data']['is_favorite'];
      });
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'user';
    });
  }

  Future<void> _loadApartmentDetails() async {
    isLoading = true;
    setState(() {});
    try {
      final data = await GetsingleproductServices().getSingleProduct(
        apartmentId: widget.apartmentId!,
      );
      setState(() {
        apartment = data;
      });
    } catch (e) {
      final localizations = LocalizationService.of(context);
      SnackBarWidget(
        context,
        '${localizations.translate('error')}: ${e.toString().replaceAll("Exception: ", "")}',
        SnackType.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> _getAllImageUrls() {
    if (apartment == null) return [];

    final Set<String> images = {};

    if (apartment!.mainImage.isNotEmpty) {
      images.add(apartment!.mainImage);
    }

    for (var image in apartment!.images) {
      if (image.path.isNotEmpty) {
        images.add(image.path);
      }
    }

    return images.toList();
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('https://flatup.next99.net/storage/http')) {
      return url.replaceFirst('https://flatup.next99.net/storage/', '');
    }

    if (url.startsWith('https://flatup.next99.net/storage/https')) {
      return url.replaceFirst('https://flatup.next99.net/storage/', '');
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/storage/')) {
      return 'https://flatup.next99.net$url';
    }

    if (!url.startsWith('http')) {
      return 'https://flatup.next99.net/storage/$url';
    }

    return url;
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: kPrimaryColorLight1),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanFeature(bool value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: value ? Colors.green : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: value ? Colors.green[800] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _getPropertyTypeName(String type, LocalizationService localizations) {
    Map<String, String> propertyTypeNames = {
      'shop': localizations.translate('shop'),
      'apartment': localizations.translate('apartment'),
      'warehouse': localizations.translate('warehouse'),
      'house': localizations.translate('house'),
      'villa': localizations.translate('villa'),
      'studio': localizations.translate('studio'),
      'office': localizations.translate('office'),
    };

    return propertyTypeNames[type] ?? type;
  }

  String _getRentTypeName(String? type) {
    final localizations = LocalizationService.of(context);
    Map<String, String> rentTypeNames = {
      'monthly': localizations.translate('monthly') ?? 'شهري',
      'yearly': localizations.translate('yearly') ?? 'سنوي',
    };

    return rentTypeNames[type]!;
  }

String _formatDateRange(dynamic range, LocalizationService localizations) {
    try {
      if (range is Map<String, dynamic>) {
        final startDate = range['start_date']?.toString() ?? '';
        final endDate = range['end_date']?.toString();

        if (startDate.isEmpty) {
          return localizations.translate('dates_not_specified') ?? 'لم يتم تحديد تواريخ';
        }

        if (endDate == null  ) {
          return '{ ${localizations.translate('start_date')}: $startDate -  ${localizations.translate('end_date')}:  ∞}'; // ✅ استخدام رمز اللانهاية
        }

        return '{ ${localizations.translate('start_date')}: $startDate - ${localizations.translate('end_date')}: $endDate }';
      } else {
        return range.toString();
      }
    } catch (e) {
      return range?.toString() ?? '';
    }
  }

String _getDateRangeTitle(dynamic range, LocalizationService localizations) {
    try {
      if (range is Map<String, dynamic>) {
        final startDate = range['start_date']?.toString() ?? '';
        final endDate = range['end_date']?.toString();

        if (endDate == null  ) {
          return localizations.translate('available_dates') ;
        }

        return localizations.translate('available_dates');
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final localizations = LocalizationService.of(context); // أضف هذا السطر
    final isDark = themeController.isDark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('apartment_details'), // ترجمة
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (role == 'tenant' ||
              role == 'landlord' && widget.status == 'approved' ||
              role == 'landlord' &&
                  widget.statusLandLordFromHome == 'approved' ||
              role == 'landlord' && widget.status == null ||
              role == 'landlord' && widget.statusLandLordFromHome == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : () async {
                        final oldValue = isFavorite;
                        setState(() {
                          isLoading = true;
                          isFavorite = !isFavorite;
                        });
                        try {
                          final response = await PosttogglefavServices().addFav(
                            idAppartment: widget.apartmentId!.toString(),
                          );
                          final isFavorite = response['data']['is_favorite'];

                          if (isFavorite != true) {
                            setState(() {
                              isFavorite != oldValue;
                            });
                          }
                          SnackBarWidget(
                            context,
                            response['message'],
                            SnackType.success,
                          );
                        } catch (e) {
                          SnackBarWidget(
                            context,
                            e.toString().replaceAll('Exception: ', ''),
                            SnackType.error,
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                child: AnimatedScale(
                  scale: isFavorite ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isLoading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? isDark
                                      ? kPrimaryColorLight1
                                      : kPrimaryColorLight2
                                : Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),

      body: apartment == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(kLogoApp, width: 150, height: 130),
                  const SizedBox(height: 20),
                  Text(
                    isLoading
                        ? localizations.translate(
                            'loading_apartment_details',
                          ) // ترجمة
                        : localizations.translate(
                            'no_apartment_data_found',
                          ), // ترجمة
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isLoading == false)
                    ElevatedButton(
                      onPressed: _loadApartmentDetails,
                      child: Text(localizations.translate('retry')), // ترجمة
                    ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Image Slider
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        // Image Carousel
                        PageView.builder(
                          itemCount: _getAllImageUrls().length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },

                          itemBuilder: (context, index) {
                            final images = _getAllImageUrls();
                            final imageUrl = _fixImageUrl(images[index]);

                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
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
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          localizations.translate(
                                            'failed_to_load_image',
                                          ), // ترجمة
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // Image Indicators
                        if (_getAllImageUrls().length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _getAllImageUrls().length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Image Counter
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${_getAllImageUrls().length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Title and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  apartment!.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Column(
                                      children: [
                                        Text(
                                          '${apartment!.province.name}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (role == 'tenant' ||
                                    role == 'landlord' &&
                                        widget.status == 'approved' ||
                                    role == 'landlord' &&
                                        widget.status == 'available' ||
                                    role == 'landlord' &&
                                        widget.statusLandLordFromHome ==
                                            'available' ||
                                    role == 'landlord' &&
                                        widget.statusLandLordFromHome ==
                                            'approved' ||
                                    role == 'landlord' &&
                                        widget.status == 'rented' ||
                                    role == 'landlord' &&
                                        widget.statusLandLordFromHome ==
                                            'rented' ||
                                    role == 'landlord' &&
                                        widget.statusLandLordFromHome == null)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          StarratingWidget(
                                            rating:
                                                apartment!.averageRating ?? 0.0,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            (apartment!.averageRating ?? 0.0)
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (role == 'tenant' ||
                                          role == 'landlord' &&
                                              widget.status == 'approved' ||
                                          role == 'landlord' &&
                                              widget.status == 'available' ||
                                          role == 'landlord' &&
                                              widget.status == 'rented' ||
                                          role == 'landlord' &&
                                              widget.statusLandLordFromHome ==
                                                  'approved' ||
                                          role == 'landlord' &&
                                              widget.statusLandLordFromHome ==
                                                  'rented' ||
                                          role == 'landlord' &&
                                              widget.statusLandLordFromHome ==
                                                  'available') ...[
                                        const SizedBox(height: 12),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReviewPage(
                                                          apartmentId:
                                                              apartment!.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                localizations.translate(
                                                  'view_reviews',
                                                ), // ترجمة
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (role == 'tenant' ||
                              role == 'landlord' && widget.status != null ||
                              role == 'landlord' &&
                                  widget.statusLandLordFromHome != null) ...[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.40,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.blueGrey[50]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.blue[100]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'SYP ${apartment!.price}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? kPrimaryColorDark1
                                          : kPrimaryColorLight1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getRentTypeName(apartment!.rentType),
                                      textAlign: TextAlign.center,
                                      maxLines:
                                          3, // إذا النص طويل يروح لسطر ثاني
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: isDark
                                            ? kPrimaryColorLight1
                                            : kPrimaryColorDark1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Property Type Badge
                      if (role == 'landlord' && widget.status != null ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome != null) ...[
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? kPrimaryColorDark1
                                : kPrimaryColorLight1,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          child: Text(
                            localizations.translate(
                              'this_property_for_you',
                            ), // ترجمة
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Owner Information
                      if (role == 'tenant' ||
                          role == 'landlord' && widget.status != null ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome != null)
                        Container(
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color.fromARGB(71, 77, 81, 86)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue[100],
                                ),
                                child:
                                    apartment!.user!.profile != null ||
                                        apartment!.user!.profile!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _fixImageUrl(
                                            apartment!.user!.profile!,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                color: kPrimaryColorLight1,
                                                Icons.person,
                                                size: 50,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: kPrimaryColorLight1,
                                        size: 35,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.translate('owner'), // ترجمة
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      apartment!.user!.name ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (role == 'tenant')
                                IconButton(
                                  icon: Icon(
                                    Icons.chat_bubble_outline,
                                    color: isDark
                                        ? kPrimaryColorLight1
                                        : kPrimaryColorDark1,
                                    size: 26,
                                  ),
                                  onPressed: () async {
                                    final chatController =
                                        Get.find<ChatController>();

                                    final conversationId = await chatController
                                        .createOrOpenConversation(
                                          apartment!.user!.id!,
                                        );

                                    if (conversationId != null) {
                                      Get.toNamed(
                                        '/chat',
                                        arguments: {
                                          'conversationId': conversationId,
                                          'otherUserName':
                                              apartment!.user!.name,
                                          'avatar': apartment!.user!.profile,
                                        },
                                      );
                                    } else {
                                      Get.snackbar(
                                        'خطأ',
                                        'لم يتم إنشاء المحادثة',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Basic Features Grid
                      Text(
                        localizations.translate('property_features'), // ترجمة
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: [
                            _buildFeatureItem(
                              Icons.aspect_ratio,
                              '${apartment!.area} ${localizations.translate('square_meters')}', // ترجمة
                            ),
                            _buildFeatureItem(
                              Icons.bed,
                              '${apartment!.roomsCount} ${localizations.translate('rooms')}', // ترجمة
                            ),
                            _buildFeatureItem(
                              Icons.bathtub,
                              '${apartment!.bathroomsCount} ${localizations.translate('bath')}', // ترجمة
                            ),

                            _buildFeatureItem(
                              Icons.balcony,
                              '${apartment!.balconiesCount} ${localizations.translate('balcony')}', // ترجمة
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Detailed Information
                      Text(
                        localizations.translate('details'), // ترجمة
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              '${localizations.translate('city')}:',
                              apartment!.city,
                            ), // ترجمة
                            _buildInfoRow(
                              '${localizations.translate('province')}:', // ترجمة
                              apartment!.province.name,
                            ),
                            _buildInfoRow(
                              '${localizations.translate('floor')}:', // ترجمة
                              apartment!.floor != null
                                  ? apartment!.floor.toString()
                                  : localizations.translate(
                                      'not_specified',
                                    ), // ترجمة
                            ),
                            _buildInfoRow(
                              '${localizations.translate('property_type')}:', // ترجمة
                              _getPropertyTypeName(
                                apartment!.propertyType,
                                localizations,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Amenities
                      Text(
                        localizations.translate('amenities'), // ترجمة
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBooleanFeature(
                            apartment!.hasRoof,
                            localizations.translate('roof_access'), // ترجمة
                          ),
                          _buildBooleanFeature(
                            apartment!.isDeluxe,
                            localizations.translate('deluxe'), // ترجمة
                          ),
                          _buildBooleanFeature(
                            apartment!.hasElectricityMeter,
                            localizations.translate(
                              'electricity_meter',
                            ), // ترجمة
                          ),
                          _buildBooleanFeature(
                            apartment!.hasWaterCounter,
                            localizations.translate('water_counter'), // ترجمة
                          ),
                          _buildBooleanFeature(
                            apartment!.hasSolarEnergy,
                            localizations.translate('solar_energy'), // ترجمة
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        localizations.translate('description'), // ترجمة
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          apartment!.description,
                          style: const TextStyle(fontSize: 15, height: 1.6),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Additional Information
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: kPrimaryColorLight1,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${localizations.translate('posted')}: ${apartment!.createdAt}', // ترجمة
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Available Date Ranges
                      if (apartment!.availableDateRanges?.isNotEmpty == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              localizations.translate(
                                'available_dates',
                              ), // ترجمة
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                           ...(apartment!.availableDateRanges ?? []).map((
                          range,
                          ) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green[50],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getDateRangeTitle(range, localizations),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateRange(range, localizations),
                                      style:  TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      if (role == 'tenant')
                        Align(
                          child: CostumButtonWidget(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompletebookingPage(
                                    apartmentId: widget.apartmentId!,
                                    price: apartment!.price ?? 0.0,
                                    apartmentTitle: apartment!.title,
                                    systemRent: apartment!.rentType,
                                  ),
                                ),
                              );
                            },
                            namebutton: localizations.translate(
                              'book_now',
                            ), // ترجمة
                            width: 300,
                            colorDecoration: Colors.green,
                            colorText: Colors.white,
                          ),
                        ),
                      if (role == 'landlord' && widget.status == 'approved' ||
                          role == 'landlord' && widget.status == 'available' ||
                          role == 'landlord' && widget.status == 'rented' ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome == 'approved' ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome == 'available' ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome == 'rented' ||
                          role == 'landlord' &&
                              widget.statusLandLordFromHome == 'rented')
                        Align(
                          child: CostumButtonWidget(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApartmentbookingsPage(
                                    apartmentId: apartment!.id,
                                  ),
                                ),
                              );
                            },
                            namebutton: localizations.translate(
                              'booking_this_flat',
                            ), // ترجمة
                            width: 400,
                            bordertext: 12,
                            colorDecoration: const Color.fromARGB(
                              204,
                              73,
                              162,
                              235,
                            ),
                            colorText: Colors.white,
                          ),
                        ),

                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
