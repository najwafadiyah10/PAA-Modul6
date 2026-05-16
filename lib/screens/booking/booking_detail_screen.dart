import 'dart:ui';

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

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

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

  Widget buildBackground({
    required Widget child,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF3EEFF),
                  Color(0xFFEFF6FF),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: _BookingDetailLinePainter(),
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.transparent,
                  Colors.white.withOpacity(0.22),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.88),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            Color(0xFF312E81),
            secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(
              0,
              14,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 8,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.055),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 10,
            child: Container(
              width: 120,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.24),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 13,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kode Booking',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          booking?.bookingCode ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        '${booking?.car?.name ?? '-'} • ${booking?.car?.brand ?? '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.86),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard({
    required String title,
    required String statusText,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return glassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
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
                  height: 6,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: color.withOpacity(0.24),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(
              height: 3,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
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
        bottom: 15,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: secondaryColor,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(
    BookingModel data,
  ) {
    return glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            'Informasi Booking',
            subtitle:
                'Detail tanggal, lokasi, dan total biaya sewa.',
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
    );
  }

  Widget buildNoteCard(
    BookingModel data,
  ) {
    return glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            'Catatan',
          ),
          Text(
            data.notes == null || data.notes!.isEmpty
                ? '-'
                : data.notes!,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: secondaryColor.withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: secondaryColor,
            size: 22,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              'Setelah booking dikonfirmasi admin, kamu bisa lanjut melakukan pembayaran melalui tab Tinggal Bayar.',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                height: 1.35,
              ),
            ),
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
            height: 18,
          ),

          buildInfoCard(
            data,
          ),

          const SizedBox(
            height: 16,
          ),

          buildNoteCard(
            data,
          ),

          const SizedBox(
            height: 16,
          ),

          buildInfoBox(),

          const SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return buildBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return buildBackground(
      child: const Center(
        child: Text(
          'Data booking tidak ditemukan',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLoadingView() {
    return buildBackground(
      child: const Center(
        child: CircularProgressIndicator(
          color: secondaryColor,
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
          ? buildLoadingView()
          : errorMessage.isNotEmpty
              ? buildErrorView()
              : booking == null
                  ? buildEmptyView()
                  : buildBackground(
                      child: buildDetailContent(),
                    ),
    );
  }
}

class _BookingDetailLinePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFF7C3AED)
          .withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = const Color(0xFF38BDF8)
          .withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height;
        i < size.width;
        i += 62) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    for (double i = 0;
        i < size.width + size.height;
        i += 92) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        accentPaint,
      );
    }

    final wavePaint = Paint()
      ..color = const Color(0xFF111827)
          .withOpacity(0.035)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.20,
    );

    path.cubicTo(
      size.width * 0.28,
      size.height * 0.14,
      size.width * 0.62,
      size.height * 0.28,
      size.width,
      size.height * 0.18,
    );

    canvas.drawPath(
      path,
      wavePaint,
    );

    final secondPath = Path();

    secondPath.moveTo(
      0,
      size.height * 0.82,
    );

    secondPath.cubicTo(
      size.width * 0.30,
      size.height * 0.74,
      size.width * 0.62,
      size.height * 0.92,
      size.width,
      size.height * 0.80,
    );

    canvas.drawPath(
      secondPath,
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}