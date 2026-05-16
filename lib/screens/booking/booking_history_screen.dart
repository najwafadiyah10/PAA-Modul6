import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../screens/payment/payment_screen.dart';
import '../../services/booking_service.dart';
import '../../services/booking_logic_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String filterType;
  final String title;
  final String emptyMessage;
  final bool showAppBar;

  const BookingHistoryScreen({
    super.key,
    this.filterType = 'all',
    this.title = 'Booking Saya',
    this.emptyMessage = 'Belum ada booking',
    this.showAppBar = true,
  });

  @override
  State<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<BookingModel> bookings = [];

  bool isLoading = true;

  String errorMessage = '';
  String? cancellingBookingId;

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

  @override
  void initState() {
    super.initState();

    getBookings();
  }

  @override
  void didUpdateWidget(covariant BookingHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filterType != widget.filterType) {
      getBookings();
    }
  }

  List<BookingModel> filterBookings(
    List<BookingModel> data,
  ) {
    return BookingLogicService.filterUserBookings(
      data,
      widget.filterType,
    );
  }

  Future<void> getBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await BookingService.getBookings();

      final filteredResult = filterBookings(result);

      if (mounted) {
        setState(() {
          bookings = filteredResult;
          errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'active':
        return Colors.blue;

      case 'completed':
        return Colors.teal;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Color getPaymentColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
        return Colors.red;

      case 'unpaid':
        return Colors.red;

      case 'refunded':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  String getBookingStatusText(String? status) {
    return BookingLogicService.userBookingStatusText(status);
  }

  String getBookingStatusDescription(String? status) {
    return BookingLogicService.bookingStatusDescription(status);
  }

  String getPaymentStatusText(String? status) {
    return BookingLogicService.userPaymentStatusText(status);
  }

  String getPaymentStatusDescription(String? status) {
    return BookingLogicService.paymentStatusDescription(status);
  }

  String formatDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  String formatPrice(double value) {
    return value.toStringAsFixed(0);
  }

  bool canPay(BookingModel booking) {
    return BookingLogicService.canUserPay(booking);
  }

  bool canCancel(BookingModel booking) {
    return BookingLogicService.canUserCancel(booking);
  }

  Future<void> cancelBooking(
    BookingModel booking,
  ) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Batalkan Booking?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yakin ingin membatalkan booking ${booking.bookingCode ?? ''}?',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alasan pembatalan',
                  hintText: 'Contoh: Jadwal berubah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      reasonController.dispose();
      return;
    }

    final reason = reasonController.text.trim().isEmpty
        ? 'Dibatalkan oleh penyewa'
        : reasonController.text.trim();

    reasonController.dispose();

    try {
      setState(() {
        cancellingBookingId = booking.id;
      });

      await BookingService.cancelBooking(
        booking.id ?? '',
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await getBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          cancellingBookingId = null;
        });
      }
    }
  }

  Widget buildStatusInfo({
    required String title,
    required String statusText,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton(
    BookingModel booking,
  ) {
    final bookingStatus = booking.status?.toLowerCase();

    final paymentStatus =
        booking.paymentStatus?.toLowerCase() ?? 'unpaid';

    final isCancelling = cancellingBookingId == booking.id;

    Widget mainButton;

    if (canPay(booking)) {
      mainButton = SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  booking: booking,
                ),
              ),
            );

            getBookings();
          },
          icon: const Icon(
            Icons.payments_rounded,
            size: 20,
          ),
          label: const Text(
            'Lanjut Bayar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    } else {
      String buttonText = 'Belum Bisa Bayar';
      IconData buttonIcon = Icons.lock_clock_rounded;

      if (bookingStatus == 'pending') {
        buttonText = 'Menunggu Konfirmasi Admin';
        buttonIcon = Icons.hourglass_top_rounded;
      } else if (paymentStatus == 'pending') {
        buttonText = 'Menunggu Verifikasi Pembayaran';
        buttonIcon = Icons.verified_rounded;
      } else if (paymentStatus == 'paid' ||
          paymentStatus == 'success') {
        buttonText = 'Pembayaran Selesai';
        buttonIcon = Icons.check_circle_rounded;
      } else if (bookingStatus == 'cancelled') {
        buttonText = 'Booking Dibatalkan';
        buttonIcon = Icons.cancel_rounded;
      }

      mainButton = SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(
            buttonIcon,
            size: 20,
          ),
          label: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.white.withOpacity(0.82),
            disabledForegroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        mainButton,
        if (canCancel(booking)) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isCancelling
                  ? null
                  : () {
                      cancelBooking(booking);
                    },
              icon: isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.cancel_outlined,
                      size: 20,
                    ),
              label: Text(
                isCancelling
                    ? 'Membatalkan...'
                    : 'Batalkan Booking',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(
                  color: Colors.red.withOpacity(0.85),
                ),
                backgroundColor: Colors.white.withOpacity(0.55),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildBookingCard(
    BookingModel booking,
  ) {
    final bookingColor = getStatusColor(booking.status);

    final paymentColor = getPaymentColor(
      booking.paymentStatus,
    );

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF111827),
                        Color(0xFF7C3AED),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.car?.name ?? '-',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.car?.brand ?? '-',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: secondaryColor.withOpacity(0.14),
                    ),
                  ),
                  child: Text(
                    booking.bookingCode ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.045),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tanggal mulai: ${formatDate(booking.startDate)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total: Rp ${formatPrice(booking.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            buildStatusInfo(
              title: 'Status Booking',
              statusText: getBookingStatusText(
                booking.status,
              ),
              description: getBookingStatusDescription(
                booking.status,
              ),
              color: bookingColor,
            ),
            buildStatusInfo(
              title: 'Status Pembayaran',
              statusText: getPaymentStatusText(
                booking.paymentStatus,
              ),
              description: getPaymentStatusDescription(
                booking.paymentStatus,
              ),
              color: paymentColor,
            ),
            const SizedBox(height: 6),
            buildActionButton(booking),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_rounded,
                color: secondaryColor,
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Gagal memuat booking',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: getBookings,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: secondaryColor,
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return buildErrorView();
    }

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: getBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 8,
            bottom: widget.showAppBar ? 16 : 118,
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.58,
              child: buildEmptyView(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: getBookings,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 8,
          bottom: widget.showAppBar ? 16 : 118,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return buildBookingCard(booking);
        },
      ),
    );
  }

  Widget buildDecoratedBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F1FF),
            Color(0xFFEFF6FF),
            Color(0xFFFFFBEB),
          ],
        ),
      ),
      child: buildBodyContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return buildDecoratedBody();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF111827),
                Color(0xFF312E81),
                Color(0xFF7C3AED),
              ],
            ),
          ),
        ),
      ),
      body: buildDecoratedBody(),
    );
  }
}
