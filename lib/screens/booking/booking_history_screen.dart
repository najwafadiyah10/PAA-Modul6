import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../screens/payment/payment_screen.dart';
import '../../services/booking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({
    super.key,
  });

  @override
  State<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState
    extends State<BookingHistoryScreen> {
  List<BookingModel> bookings = [];

  bool isLoading = true;

  String errorMessage = '';
  String? cancellingBookingId;

  @override
  void initState() {
    super.initState();

    getBookings();
  }

  Future<void> getBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await BookingService.getBookings();

      setState(() {
        bookings = result;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';

      case 'confirmed':
        return 'Booking Dikonfirmasi';

      case 'active':
        return 'Sewa Aktif';

      case 'completed':
        return 'Sewa Selesai';

      case 'cancelled':
        return 'Booking Dibatalkan';

      default:
        return 'Status Tidak Diketahui';
    }
  }

  String getBookingStatusDescription(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Booking kamu sedang menunggu persetujuan admin.';

      case 'confirmed':
        return 'Booking sudah disetujui admin. Kamu bisa lanjut melakukan pembayaran.';

      case 'active':
        return 'Mobil sedang dalam masa penyewaan.';

      case 'completed':
        return 'Penyewaan mobil sudah selesai.';

      case 'cancelled':
        return 'Booking ini sudah dibatalkan.';

      default:
        return 'Status booking belum tersedia.';
    }
  }

  String getPaymentStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'Pembayaran Lunas';

      case 'pending':
        return 'Menunggu Verifikasi';

      case 'failed':
        return 'Pembayaran Gagal';

      case 'unpaid':
        return 'Belum Dibayar';

      case 'refunded':
        return 'Dana Dikembalikan';

      default:
        return 'Status Pembayaran Tidak Diketahui';
    }
  }

  String getPaymentStatusDescription(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'Pembayaran sudah dikonfirmasi oleh admin.';

      case 'pending':
        return 'Pembayaran sudah dikirim dan sedang dicek admin.';

      case 'failed':
        return 'Pembayaran gagal atau ditolak. Silakan lakukan pembayaran ulang.';

      case 'unpaid':
        return 'Pembayaran belum dilakukan.';

      case 'refunded':
        return 'Pembayaran sudah dikembalikan.';

      default:
        return 'Status pembayaran belum tersedia.';
    }
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
    final bookingStatus =
        booking.status?.toLowerCase();

    final paymentStatus =
        booking.paymentStatus?.toLowerCase();

    return bookingStatus == 'confirmed' &&
        (paymentStatus == 'unpaid' ||
            paymentStatus == 'failed');
  }

  bool canCancel(BookingModel booking) {
  final bookingStatus =
      booking.status?.toLowerCase();

  final paymentStatus =
      booking.paymentStatus?.toLowerCase();

  if (booking.id == null || booking.id!.isEmpty) {
    return false;
  }

  if (bookingStatus == 'pending') {
    return true;
  }

  if (bookingStatus == 'confirmed' &&
      (paymentStatus == 'unpaid' ||
          paymentStatus == 'failed')) {
    return true;
  }

  return false;
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
          borderRadius: BorderRadius.circular(16),
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
            const SizedBox(
              height: 14,
            ),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan',
                hintText: 'Contoh: Jadwal berubah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              'Tidak',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Ya, Batalkan',
            ),
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
          content: Text(
            'Booking berhasil dibatalkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    await getBookings();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
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
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
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
    );
  }

  Widget buildActionButton(
  BookingModel booking,
) {
  final bookingStatus =
      booking.status?.toLowerCase();

  final paymentStatus =
      booking.paymentStatus?.toLowerCase();

  final isCancelling =
      cancellingBookingId == booking.id;

  Widget mainButton;

  if (canPay(booking)) {
    mainButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaymentScreen(
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
          backgroundColor:
              const Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  } else {
    String buttonText = 'Belum Bisa Bayar';
    IconData buttonIcon =
        Icons.lock_clock_rounded;

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
          disabledBackgroundColor:
              Colors.grey.shade300,
          disabledForegroundColor:
              Colors.grey.shade700,
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  return Column(
    children: [
      mainButton,

      if (canCancel(booking)) ...[
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isCancelling
                ? null
                : () {
                    cancelBooking(
                      booking,
                    );
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
              side: const BorderSide(
                color: Colors.red,
              ),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
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
    final bookingColor =
        getStatusColor(booking.status);

    final paymentColor =
        getPaymentColor(
      booking.paymentStatus,
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.car?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        booking.car?.brand ?? '-',
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1A1A2E,
                    ).withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.bookingCode ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                      color: Color(
                        0xFF1A1A2E,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color:
                            Colors.grey.shade700,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          'Tanggal mulai: ${formatDate(booking.startDate)}',
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: 18,
                        color:
                            Colors.grey.shade700,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          'Total: Rp ${formatPrice(booking.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            buildStatusInfo(
              title: 'Status Booking',
              statusText:
                  getBookingStatusText(
                booking.status,
              ),
              description:
                  getBookingStatusDescription(
                booking.status,
              ),
              color: bookingColor,
            ),

            buildStatusInfo(
              title: 'Status Pembayaran',
              statusText:
                  getPaymentStatusText(
                booking.paymentStatus,
              ),
              description:
                  getPaymentStatusDescription(
                booking.paymentStatus,
              ),
              color: paymentColor,
            ),

            const SizedBox(
              height: 6,
            ),

            buildActionButton(
              booking,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F1F8,
      ),
      appBar: AppBar(
        title: const Text(
          'Booking Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(
          0xFF1A1A2E,
        ),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Text(
                      errorMessage,
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              : bookings.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada booking',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: getBookings,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.only(
                          top: 8,
                          bottom: 16,
                        ),
                        itemCount: bookings.length,
                        itemBuilder:
                            (context, index) {
                          final booking =
                              bookings[index];

                          return buildBookingCard(
                            booking,
                          );
                        },
                      ),
                    ),
    );
  }
}