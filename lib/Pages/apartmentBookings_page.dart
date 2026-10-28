import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Servicse/getAllBookingForAppartment_services.dart';
import 'package:flat_up/Servicse/postApproveBooking_services.dart';
import 'package:flat_up/Servicse/postRejectBooking_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widget/snackBar_widget.dart';

class ApartmentbookingsPage extends StatefulWidget {
  final int apartmentId;

  const ApartmentbookingsPage({Key? key, required this.apartmentId})
    : super(key: key);

  @override
  State<ApartmentbookingsPage> createState() => _ApartmentbookingsPageState();
}

class _ApartmentbookingsPageState extends State<ApartmentbookingsPage> {
  bool isLoading = true;
  List bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    try {
      final response = await GetallbookingforappartmentServices().getBooking(
        apartmentId: widget.apartmentId,
      );

      setState(() {
        bookings = response['data']['data'];
      });
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _approve(int bookingId) async {
    try {
      final response = await PostapprovebookingServices().approveBooking(
        bookingId: bookingId,
      );
      SnackBarWidget(context, response['message'], SnackType.success);
      _loadBookings();
    } catch (e) {
      SnackBarWidget(context, e.toString(), SnackType.error);
    }
  }

  Future<void> _reject(int bookingId) async {
    try {
      final response = await PostrejectbookingServices().rejectBooking(
        bookingId: bookingId,
      );
      SnackBarWidget(context, response['message'], SnackType.success);
      _loadBookings();
    } catch (e) {
      SnackBarWidget(context, e.toString(), SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title:  Text(
          localization.translate('apartment_bookings'),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _bookingCard(bookings[index]);
              },
            ),
    );
  }

  Widget _emptyState() {
    final localization = LocalizationService.of(context);

    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment, size: 150, color: kPrimaryColorLight1),
          Text(
            localization.translate('no_bookings_yet'),
            style: TextStyle(fontSize: 26, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(dynamic booking) {
    final localization = LocalizationService.of(context);

    final status = booking['status'];

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tenant Info
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            booking['user']['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            booking['user']['email'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 16),

                _infoRow('from', booking['start_date']),
                _infoRow('to', booking['end_date']),
                _infoRow('guests', booking['number_of_guests'].toString()),
                _infoRow('total_amount', '${booking['total_amount']}'),
                _infoRow('created', '${booking['created_at']}'),
                if (status != ' pending ')
                  _infoRow('updated_from_you', '${booking['updated_at']}'),

                if (booking['special_requests'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      booking['special_requests'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 16),

                if (status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approve(booking['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:  Text(
                           localization.translate('approved'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _reject(booking['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:  Text(
                            localization.translate('rejected'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (status == 'completed')
          Positioned(
            top: 12,
            right: 12,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.withOpacity(0.08),
                ),
                child: Text(
                  localization.translate('completed'),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    final localization = LocalizationService.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              localization.translate(label),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    final localization = LocalizationService.of(context);
    switch (status) {
      case 'approved ':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        localization.translate('$status'),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
