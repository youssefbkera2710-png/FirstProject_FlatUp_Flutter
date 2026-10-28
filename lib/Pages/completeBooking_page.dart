import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/apiException.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/booking_model.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';
import 'package:flat_up/Servicse/postAddBooking_services.dart';
import 'package:flat_up/Servicse/postCheckAvilable_services.dart';
import 'package:flat_up/Servicse/postUpdateBooking_services.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CompletebookingPage extends StatefulWidget {
  final int? apartmentId;
  final String? apartmentTitle;
  final double? price;
  final String? systemRent;
  final BookingModel? booking;

  const CompletebookingPage({
    Key? key,
    this.apartmentId,
    this.apartmentTitle,
    this.price,
    this.systemRent,
    this.booking,
  }) : super(key: key);

  static String id = 'CompletebookingPage';

  @override
  State<CompletebookingPage> createState() => _CompletebookingPageState();
}

class _CompletebookingPageState extends State<CompletebookingPage> {
  bool isLoading = false;

  bool get isEditMode => widget.booking != null;
  String? get apartmentTitle =>
      isEditMode ? widget.booking!.apartment.title : widget.apartmentTitle;

  double? get apartmentPrice =>
      isEditMode ? widget.booking!.apartment.price : widget.price;

  String? get systemRent =>
      isEditMode ? widget.booking!.apartment.rentType : widget.systemRent;

  int? get apartmentId =>
      isEditMode ? widget.booking!.apartment.id : widget.apartmentId;

  // Controllers للحقول
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();
  final TextEditingController _paymentIntentController =
      TextEditingController();

  // Focus nodes
  final FocusNode _startDateFocus = FocusNode();
  final FocusNode _endDateFocus = FocusNode();
  final FocusNode _guestsFocus = FocusNode();
  final FocusNode _specialRequestsFocus = FocusNode();
  final FocusNode _paymentIntentFocus = FocusNode();
  int? _selectedMonths;
  int? _selectedYears;

  // التواريخ
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _guestsController.text = '1';

    if (isEditMode) {
      final booking = widget.booking!;

      // تواريخ
      _startDate = DateTime.parse(booking.startDate);
      _endDate = DateTime.parse(booking.endDate);

      _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate!);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);

      _guestsController.text = booking.numberOfGuests.toString();
      _specialRequestsController.text = booking.specialRequests ?? '';
      _paymentIntentController.text = booking.paymentStatus;

      final totalDays = _endDate!.difference(_startDate!).inDays;
      if (systemRent == 'monthly') {
        _selectedMonths = (totalDays / 30).round();
        _selectedYears = null;
      }

      if (systemRent == 'yearly') {
        _selectedYears = (totalDays / 365).round();
        _selectedMonths = null;
      }
    }

    _startDateController.addListener(_updateDates);
    _endDateController.addListener(_updateDates);
    _guestsController.addListener(_updateCalculation);
  }

  @override
  void dispose() {
    // تنظيف جميع الـ controllers
    _startDateController.dispose();
    _endDateController.dispose();
    _guestsController.dispose();
    _specialRequestsController.dispose();
    _paymentIntentController.dispose();

    // تنظيف focus nodes
    _startDateFocus.dispose();
    _endDateFocus.dispose();
    _guestsFocus.dispose();
    _specialRequestsFocus.dispose();
    _paymentIntentFocus.dispose();

    super.dispose();
  }

  void _updateDates() {
    setState(() {});
  }

  void _updateCalculation() {
    setState(() {});
  }

  void _showAvailabilityDialog({
    required double totalAmount,
    required List periods,
  }) {
    final localizations = LocalizationService.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                localizations.translate('apartment_available'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  localizations.translate('available_periods'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: periods.length,
                  itemBuilder: (context, index) {
                    final period = periods[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(
                          Icons.date_range,
                          color: Colors.green,
                        ),
                        title: Text(
                          '${period['start_date'].toString()} → ${period['end_date'].toString()}',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${localizations.translate('total_amount')}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColorLight1,
                      ),
                    ),
                    Text(
                      ' \SYP ${totalAmount.toString()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.translate('cancel'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                isEditMode ? _updateBooking() : _submitBooking();
                Navigator.pop(context);
              },
              child: Text(
                localizations.translate('confirm'),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  // اختيار تاريخ البداية
  Future<void> _selectStartDate() async {
    final localizations = LocalizationService.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        final rentType = systemRent ?? 'monthly';
        if (rentType == 'monthly' && _selectedMonths == null) {
          _selectedMonths = 1;
        }

        if (rentType == 'yearly' && _selectedYears == null) {
          _selectedYears = 1;
        }
        if (rentType == 'monthly') {
          _endDate = picked.add(Duration(days: _selectedMonths! * 30));
        }
        if (rentType == 'yearly') {
          _endDate = picked.add(Duration(days: _selectedYears! * 365));
        }
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final localizations = LocalizationService.of(context);
    if (_startDate == null) {
      _showError(localizations.translate('select_start_date_first'));
      return;
    }

    if (systemRent == 'yearly') {
      _selectYearlyEndDate(localizations);
    } else if (systemRent == 'monthly') {
      _selectMonthlyEndDate(localizations);
    }
  }

  void _selectMonthlyEndDate(LocalizationService localizations) {
    final start = _startDate!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.translate('select_end_date_months')),
          content: SizedBox(
            height: 300,
            width: 220,
            child: ListView.builder(
              itemCount: 60,
              itemBuilder: (context, index) {
                final months = index + 1;
                final endDate = start.add(Duration(days: months * 30));

                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                  subtitle: Text('$months ${localizations.translate('month')}'),
                  onTap: () {
                    setState(() {
                      _selectedMonths = months;
                      _selectedYears = null;

                      _endDate = endDate;
                      _endDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(endDate);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _selectYearlyEndDate(LocalizationService localizations) {
    final start = _startDate!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.translate('select_end_date_years')),
          content: SizedBox(
            height: 300,
            width: 220,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                final years = index + 1;
                final endDate = start.add(Duration(days: years * 365));

                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                  subtitle: Text(
                    '$years ${localizations.translate('year')}${years > 1 ? localizations.translate('s') : ''}',
                  ),
                  onTap: () {
                    setState(() {
                      _selectedYears = years;
                      _selectedMonths = null;

                      _endDate = endDate;
                      _endDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(endDate);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // إظهار رسالة خطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _calculateMonths() {
    final totalDays = _calculateTotalDays();
    return (totalDays / 30).floor();
  }

  int _calculateYears() {
    final totalDays = _calculateTotalDays();
    return (totalDays / 360).floor();
  }

  // التحقق من النموذج
  bool _validateForm() {
    final localizations = LocalizationService.of(context);

    if (_startDateController.text.isEmpty) {
      _showError(localizations.translate('select_start_date'));
      return false;
    }

    if (_endDateController.text.isEmpty) {
      _showError(localizations.translate('select_end_date'));
      return false;
    }

    if (_guestsController.text.isEmpty) {
      _showError(localizations.translate('enter_number_of_guests'));
      return false;
    }

    final guests = int.tryParse(_guestsController.text);
    if (guests == null || guests <= 0) {
      _showError(localizations.translate('enter_valid_number_of_guests'));
      return false;
    }

    if (_paymentIntentController.text.isEmpty) {
      _showError(localizations.translate('enter_payment_intent_id'));
      return false;
    }

    return true;
  }

  // إرسال الحجز
  Future<void> _submitBooking() async {
    if (!_validateForm()) return;
    setState(() {
      isLoading = true;
    });
    try {
      final service = PostaddbookingServices();
      final result = await service.createBooking(
        apartmentId: apartmentId!,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        numberOfGuests: int.parse(_guestsController.text),
        paymentIntentId: _paymentIntentController.text,
        specialRequests: _specialRequestsController.text,
      );
      SnackBarWidget(context, result['message'], SnackType.success);
      // العودة بعد تأخير
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> checkAvilableDate() async {
    if (!_validateForm()) return;
    setState(() {
      isLoading = true;
    });
    try {
      final service = PostcheckavilableServices();
      final result = await service.checkAvilable(
        apartmentId: apartmentId!,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
      );
      final data = result['data'];
      final double totalAmount =
          (data['total_amount'] as num?)?.toDouble() ?? 0.0;
      final List periods = data['available_periods'] ?? [];

      if (!mounted) return;

      _showAvailabilityDialog(totalAmount: totalAmount, periods: periods);
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBooking() async {
    if (_startDate == null || _endDate == null) {
      _showError(
        LocalizationService.of(context).translate('select_start_and_end_date'),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final service = PostupdatebookingServices();
      final result = await service.updateBooking(
        bookingId: widget.booking!.id,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
      );
      SnackBarWidget(context, result['message'], SnackType.success);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  DateTime addRentalMonth(DateTime start, int months) {
    return start.add(Duration(days: months * 30));
  }

  DateTime addRentalYear(DateTime start, int years) {
    return start.add(Duration(days: years * 360));
  }

  int _calculateTotalDays() {
    if (_startDate == null || _endDate == null) return 0;

    return _endDate!.difference(_startDate!).inDays;
  }

  String _getRentTypeName(String? type) {
    final localizations = LocalizationService.of(context);
    if (type == 'monthly') {
      return localizations.translate('monthly') ?? 'شهري';
    } else if (type == 'yearly') {
      return localizations.translate('yearly') ?? 'سنوي';
    }
    return type ?? 'invalid';
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final localizations = LocalizationService.of(context);
    final isDark = themeController.isDark;
    final isFormValid =
        _startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty &&
        _guestsController.text.isNotEmpty &&
        (_paymentIntentController.text.isNotEmpty || isEditMode) &&
        !isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('booking_apartment')),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الشقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('apartment_details'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apartmentTitle ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_getRentTypeName(systemRent)} ${localizations.translate('price')}:',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? kPrimaryColorDark1
                              : kPrimaryColorLight1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' \SYP ${apartmentPrice?.toStringAsFixed(2) ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // تاريخ البداية
            Text(
              localizations.translate('start_date'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectStartDate,
              child: AbsorbPointer(
                child: CostumTextfiledWidget(
                  hintText: localizations.translate('select_start_date'),
                  prefixIcon: Icons.calendar_today,
                  controller: _startDateController,
                  currentFocus: _startDateFocus,
                  nextFocus: _endDateFocus,
                  borderRadius: 12,
                  enableValidation:
                      false, // تعطيل التحقق لأننا نستخدم date picker
                  onChanged: (value) {
                    setState(() {}); // This triggers rebuild
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // تاريخ النهاية
            Text(
              localizations.translate('end_date'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectEndDate,
              child: AbsorbPointer(
                child: CostumTextfiledWidget(
                  hintText: localizations.translate('select_end_date'),
                  prefixIcon: Icons.calendar_today,

                  controller: _endDateController,
                  currentFocus: _endDateFocus,
                  nextFocus: _guestsFocus,
                  borderRadius: 12,
                  enableValidation: false,
                  onChanged: (value) {
                    setState(() {}); // This triggers rebuild
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // عدد الضيوف
            Text(
              localizations.translate('number_of_guests'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            CostumTextfiledWidget(
              hintText: localizations.translate('enter_number_of_guests'),
              prefixIcon: Icons.people,
              controller: _guestsController,
              enabledWrite: !isEditMode,
              keyboardType: TextInputType.number,
              currentFocus: _guestsFocus,
              nextFocus: _specialRequestsFocus,
              borderRadius: 12,
              onChanged: (value) {
                // السماح فقط بالأرقام
                if (value.isNotEmpty && int.tryParse(value) == null) {
                  // إذا كان الإدخال ليس رقماً، نعود للقيمة السابقة
                  final newText = value.replaceAll(RegExp(r'[^0-9]'), '');
                  _guestsController.text = newText;
                  _guestsController.selection = TextSelection.fromPosition(
                    TextPosition(offset: newText.length),
                  );
                }
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            // طلبات خاصة (اختياري)
            Text(
              localizations.translate('special_requests_optional'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            CostumTextfiledWidget(
              onChanged: (value) {
                setState(() {}); // This triggers rebuild
              },
              hintText: localizations.translate('any_special_requirements'),
              prefixIcon: Icons.note,
              controller: _specialRequestsController,
              enabledWrite: !isEditMode,
              keyboardType: TextInputType.multiline,
              minLinesCustom: 3,
              currentFocus: _specialRequestsFocus,
              nextFocus: _paymentIntentFocus,
              borderRadius: 12,
              enableValidation: false, // اختياري
            ),

            const SizedBox(height: 16),

            // Payment Intent ID
            Text(
              '${localizations.translate('payment_intent_id')} *',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CostumTextfiledWidget(
              onChanged: (value) {
                setState(() {}); // This triggers rebuild
              },
              hintText: localizations.translate('enter_payment_intent_id'),
              prefixIcon: Icons.payment,
              controller: _paymentIntentController,
              enabledWrite: !isEditMode,
              currentFocus: _paymentIntentFocus,
              borderRadius: 12,
            ),

            const SizedBox(height: 8),

            if (!isEditMode)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.translate('payment_intent_note'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ملخص الحجز
            if (_startDateController.text.isNotEmpty &&
                _endDateController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('booking_summary'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColorLight1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSummaryRow(
                      '${localizations.translate('start_date')}:',
                      _startDateController.text,
                      localizations,
                    ),
                    _buildSummaryRow(
                      '${localizations.translate('end_date')}:',
                      _endDateController.text,
                      localizations,
                    ),
                    _buildSummaryRow(
                      '${localizations.translate('total_days')}:',
                      _calculateTotalDays().toString(),
                      localizations,
                    ),

                    if (systemRent == 'yearly' && _calculateYears() > 0)
                      _buildSummaryRow(
                        '${localizations.translate('number_of_years')}:',
                        _calculateYears().toString(),
                        localizations,
                      )
                    else if (systemRent == 'monthly' && _calculateMonths() > 0)
                      _buildSummaryRow(
                        '${localizations.translate('number_of_months')}:',
                        _calculateMonths().toString(),
                        localizations,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // زر الحجز
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isFormValid ? checkAvilableDate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? kPrimaryColorLight1
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book_online),
                          const SizedBox(width: 8),
                          Text(
                            isEditMode
                                ? localizations.translate('update_booking')
                                : localizations.translate('book_now'),

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // رسالة شروط الاستخدام
            Text(
              localizations.translate('booking_terms'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لعرض صف في الملخص
  Widget _buildSummaryRow(
    String label,
    String value,
    LocalizationService localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
