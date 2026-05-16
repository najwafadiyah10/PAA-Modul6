import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState
    extends State<BookingDetailScreen> {
  BookingModel? booking;

  bool isLoading = true;

  String errorMessage = '';

  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color backgroundColor = Color(0xFFF8F1F8);

  @override
  void initState() {
    super.initState();

    getBooking();
  }

  Future<void> getBooking() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result =
          await BookingService.getBookingById(
        widget.bookingId,
      );

      if (mounted) {
        setState(() {
          booking = result;
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

  String formatDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  String formatPrice(double value) {
    return value.toStringAsFixed(0);
  }

  Color getBookingStatusColor(String? status) {
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

  Color getPaymentStatusColor(String? status) {
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
        return 'Booking kamu sudah dibuat dan sedang menunggu persetujuan admin.';

      case 'confirmed':
        return 'Booking sudah disetujui admin. Kamu bisa lanjut melakukan pembayaran dari halaman Booking Saya.';

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
        return 'Pembayaran sudah dikirim dan sedang dicek oleh admin.';

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

  Widget buildStatusCard({
    required String title,
    required String statusText,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 12,
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

  Widget buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Booking',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            booking?.bookingCode ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  '${booking?.car?.name ?? '-'} • ${booking?.car?.brand ?? '-'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailContent() {
    final data = booking!;

    final bookingColor =
        getBookingStatusColor(data.status);

    final paymentColor =
        getPaymentStatusColor(data.paymentStatus);

    return RefreshIndicator(
      onRefresh: getBooking,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          buildHeaderCard(),

          const SizedBox(
            height: 18,
          ),

          buildStatusCard(
            title: 'Status Booking',
            statusText:
                getBookingStatusText(data.status),
            description:
                getBookingStatusDescription(data.status),
            color: bookingColor,
            icon: Icons.assignment_turned_in_rounded,
          ),

          const SizedBox(
            height: 12,
          ),

          buildStatusCard(
            title: 'Status Pembayaran',
            statusText:
                getPaymentStatusText(data.paymentStatus),
            description:
                getPaymentStatusDescription(data.paymentStatus),
            color: paymentColor,
            icon: Icons.payments_rounded,
          ),

          const SizedBox(
            height: 20,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Booking',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                buildInfoItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'Tanggal Mulai',
                  value: formatDate(data.startDate),
                ),
                buildInfoItem(
                  icon: Icons.event_available_rounded,
                  title: 'Tanggal Selesai',
                  value: formatDate(data.endDate),
                ),
                buildInfoItem(
                  icon: Icons.timelapse_rounded,
                  title: 'Durasi',
                  value: '${data.duration} hari',
                ),
                buildInfoItem(
                  icon: Icons.location_on_rounded,
                  title: 'Lokasi Pickup',
                  value: data.pickupLocation ?? '-',
                ),
                buildInfoItem(
                  icon: Icons.assignment_return_rounded,
                  title: 'Lokasi Pengembalian',
                  value: data.returnLocation ?? '-',
                ),
                buildInfoItem(
                  icon: Icons.payments_rounded,
                  title: 'Total Harga',
                  value:
                      'Rp ${formatPrice(data.totalPrice)}',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  data.notes == null ||
                          data.notes!.isEmpty
                      ? '-'
                      : data.notes!,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: primaryColor,
                  size: 22,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'Setelah booking dikonfirmasi admin, kamu bisa lanjut melakukan pembayaran melalui halaman Booking Saya.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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
            const SizedBox(
              height: 14,
            ),
            const Text(
              'Gagal memuat detail booking',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed: getBooking,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Coba Lagi',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? buildErrorView()
              : booking == null
                  ? const Center(
                      child: Text(
                        'Data booking tidak ditemukan',
                      ),
                    )
                  : buildDetailContent(),
    );
  }
}