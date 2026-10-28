import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Pages/completeBooking_page.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';
import 'package:flat_up/Servicse/get_my_booking_tenant_services.dart';
import 'package:flat_up/Servicse/post_cancel_my_book.dart';
import 'package:flat_up/components/build_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Models/booking_model.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/Helper/themes.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});
  static String id = "MyBookingPage";

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  List<BookingModel> _myBookings = [];
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadInitialMyBookings();
  });
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMyBookings() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _hasError = false;
        _errorMessage = '';
      });

      final service = GetMyBookingsService();
      List<BookingModel> firstPage = await service.getMyBookingsByPage(
        1,
        q: _searchQuery,
      );

      setState(() {
        _myBookings = firstPage;
        _hasMoreData = firstPage.isNotEmpty && firstPage.length >= 10;
        _isInitialLoading = false;
        _currentPage = 1;
        _hasError = false;
      });
    } catch (e) {
      print("❌ خطأ في تحميل الحجوزات: $e");
      setState(() {
        _isInitialLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreMyBookings() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      int nextPage = _currentPage + 1;
      final service = GetMyBookingsService();
      List<BookingModel> newBookings = await service.getMyBookingsByPage(
        nextPage,
        q: _searchQuery,
      );

      setState(() {
        if (newBookings.isNotEmpty) {
          _myBookings.addAll(newBookings);
          _currentPage = nextPage;
          _hasMoreData = newBookings.length >= 10;
        } else {
          _hasMoreData = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      print("❌ خطأ في تحميل المزيد من الحجوزات: $e");
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshMyBookings() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _hasError = false;
      _errorMessage = '';
    });

    await _loadInitialMyBookings();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.isNotEmpty ? query : null;
    });
    _loadInitialMyBookings();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _searchController.clear();
    });
    _loadInitialMyBookings();
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('https://flatup.next99.net/storage/')) {
      return url;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/storage/')) {
      return 'https://flatup.next99.net$url';
    }

    if (url.startsWith('storage/')) {
      return 'https://flatup.next99.net/$url';
    }

    return 'https://flatup.next99.net/storage/$url';
  }

  Map<String, dynamic> _getStatusInfo(
    String status,
    LocalizationService localizations,
  ) {
    String statusLower = status.toLowerCase();

    switch (statusLower) {
      case 'cancelled':
        return {
          'text': localizations.translate('canceled'),
          'color': Colors.orange,
          'icon': Icons.cancel,
          'bgColor': Colors.orange.shade50,
        };
      case 'completed':
        return {
          'text': localizations.translate('completed'),
          'color': Colors.blueAccent,
          'icon': Icons.check_circle,
          'bgColor': Colors.blueAccent.shade100,
        };
      case 'rejected':
        return {
          'text': localizations.translate('rejected'),
          'color': Colors.red,
          'icon': Icons.block,
          'bgColor': Colors.red.shade50,
        };
      case 'pending':
        return {
          'text': localizations.translate('pending'),
          'color': Colors.amber,
          'icon': Icons.pending,
          'bgColor': Colors.amber.shade50,
        };
      case 'rented':
        return {
          'text': localizations.translate('rented'),
          'color': Colors.purple,
          'icon': Icons.attach_money,
          'bgColor': Colors.purple.shade50,
        };
      case 'approved':
        return {
          'text': localizations.translate('approved'),
          'color': Colors.green,
          'icon': Icons.check,
          'bgColor': Colors.green.shade100,
        };
      default:
        return {
          'text': status,
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'bgColor': Colors.grey.shade50,
        };
    }
  }

  void _editBooking(BookingModel booking) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CompletebookingPage(booking: booking),
          ),
        )
        .then((value) {
          if (value == true) {
            _refreshMyBookings();
          }
        });
  }

  Future<void> _cancelBooking(BookingModel booking, int index) async {
    final localizations = LocalizationService.of(context);

    if (!mounted) return;

    await Future.delayed(Duration.zero);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            localizations.translate('confirmCancellation'),
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('cancelBookingConfirm'),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              if (booking.cancellationFee != null &&
                  booking.cancellationFee! > 0)
                Text(
                  'رسوم الإلغاء: ${booking.cancellationFee} ${localizations.translate('currency')}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                localizations.translate('cancel'),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.translate('confirm')),
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
        bool cancelSuccess = await CancelBookingService().cancelBooking(
          booking.id,
        );

        if (cancelSuccess) {
          // تحديث الحالة في القائمة
          setState(() {
            _myBookings[index] = BookingModel(
              id: booking.id,
              apartment: booking.apartment,
              startDate: booking.startDate,
              endDate: booking.endDate,
              totalAmount: booking.totalAmount,
              status: 'canceled',
              paymentStatus: booking.paymentStatus,
              stripePaymentIntentId: booking.stripePaymentIntentId,
              cancellationFee: booking.cancellationFee,
              numberOfGuests: booking.numberOfGuests,
              specialRequests: booking.specialRequests,
              cancelledAt: DateTime.now().toString(),
              completedAt: booking.completedAt,
              paymentTransactions: booking.paymentTransactions,
              bookingTimeSlots: booking.bookingTimeSlots,
              createdAt: booking.createdAt,
              updatedAt: DateTime.now().toString(),
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('bookingCancelledSuccess')),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('bookingCancelledError')),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print("❌ خطأ غير متوقع في إلغاء الحجز: $e");

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

  // دالة لبناء حالة الخطأ
  Widget _buildErrorState(
    LocalizationService localizations,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            SizedBox(height: 16),
            Text(
              localizations.translate('error_loading'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : localizations.translate('try_again_later'),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialMyBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                localizations.translate('retry'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
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
        _loadInitialMyBookings,
      );
    }

    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              localizations.translate('loadingBookings'),
              style: TextStyle(fontSize: 16, color: colors.primary),
            ),
          ],
        ),
      );
    }

    if (_myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 100,
              color: colors.primary.withOpacity(0.3),
            ),
            SizedBox(height: 20),
            Text(
              localizations.translate('noBookings'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              localizations.translate('bookYourFirstApartment'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            // تصفح العروض
          ],
        ),
      );
    }

    return Column(
      children: [
        // قائمة الحجوزات
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshMyBookings,
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _myBookings.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _myBookings.length) {
                  return _buildLoadMoreIndicator(localizations);
                }

                BookingModel booking = _myBookings[index];
                return _buildBookingCard(
                  booking,
                  context,
                  localizations,
                  index,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator(LocalizationService localizations) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator()
            : Text(
                localizations.translate('noMoreBookings'),
                style: TextStyle(color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
    BuildContext context,
    LocalizationService localizations,
    int index,
  ) {
    final colors = Theme.of(context).colorScheme;

    String mainImageUrl = _fixImageUrl(booking.apartment.mainImage);
    var statusInfo = _getStatusInfo(booking.status, localizations);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _navigateToSingleProduct(
            context,
            booking.apartment.id,
            booking.status,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: statusInfo['color'].withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الشقة وحالة الحجز
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colors.primary.withOpacity(0.1),
                      ),
                      child: mainImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                mainImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colors.primary.withOpacity(0.1),
                                    child: Center(
                                      child: Icon(
                                        Icons.apartment,
                                        size: 60,
                                        color: colors.primary.withOpacity(0.5),
                                      ),
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
                                size: 60,
                                color: colors.primary.withOpacity(0.5),
                              ),
                            ),
                    ),

                    // حالة الحجز
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo['color'].withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusInfo['icon'],
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              statusInfo['text'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // زر الإلغاء (يظهر فقط إذا لم يكن الحجز ملغى أو مكتمل)
                    if (booking.status != 'cancelled' &&
                        booking.status != 'completed' &&
                        booking.status != 'rejected')
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'cancel') {
                                _cancelBooking(booking, index);
                              } else if (value == 'edit') {
                                _editBooking(booking);
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
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      localizations.translate('cancelBooking'),
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

                SizedBox(height: 16),

                // عنوان الشقة
                Text(
                  booking.apartment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8),

                // المدينة
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      booking.apartment.city,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // تاريخ البداية والنهاية
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusInfo['bgColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: colors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                localizations.translate('startDate'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.startDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: colors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                localizations.translate('endDate'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.endDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // عدد الضيوف والمبلغ الإجمالي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outlined,
                          size: 18,
                          color: colors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${booking.numberOfGuests} ${localizations.translate('guests')}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${booking.totalAmount.toStringAsFixed(2)} ${localizations.translate('currency')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // تاريخ إنشاء الحجز
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${localizations.translate('bookingDate')}: ${booking.createdAt}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSingleProduct(
    BuildContext context,
    int id,
    String statusBooking,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SingleProductPage(apartmentId: id, statusBooking: statusBooking),
      ),
    );
  }
}
