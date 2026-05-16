import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import 'booking_detail_screen.dart';

class BookingScreen extends StatefulWidget {
  final CarModel car;

  const BookingScreen({
    super.key,
    required this.car,
  });

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  final pickupController = TextEditingController();
  final returnController = TextEditingController();
  final notesController = TextEditingController();

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

  Future<void> selectDate(
    bool isStart,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;

          if (endDate != null &&
              endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> bookingCar() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih tanggal booking',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal selesai tidak valid',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final duration = endDate!
          .difference(
            startDate!,
          )
          .inDays;

      final booking = BookingModel(
        car: widget.car,
        startDate: startDate!
            .toIso8601String()
            .split('T')[0],
        endDate: endDate!
            .toIso8601String()
            .split('T')[0],
        duration: duration,
        totalPrice: widget.car.pricePerDay * duration,
        pricePerDay: widget.car.pricePerDay,
        pickupLocation: pickupController.text,
        returnLocation: returnController.text,
        notes: notesController.text,
      );

      final result = await BookingService.createBooking(
        booking,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking berhasil',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(
              bookingId: result.id!,
            ),
          ),
        );
      }
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
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    pickupController.dispose();
    returnController.dispose();
    notesController.dispose();

    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return date.toString().split(' ')[0];
  }

  int getDuration() {
    if (startDate == null || endDate == null) {
      return 0;
    }

    return endDate!
        .difference(
          startDate!,
        )
        .inDays;
  }

  double getTotalPrice() {
    return widget.car.pricePerDay * getDuration();
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
            painter: _BookingLinePainter(),
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

  Widget buildCarSummary() {
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
            top: 10,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 118,
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
                      Icons.local_taxi_rounded,
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
                        const Text(
                          'Mobil Pilihan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          widget.car.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          widget.car.brand,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 14,
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

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildHeaderChip(
                    icon: Icons.event_available_rounded,
                    label: 'Booking',
                  ),
                  buildHeaderChip(
                    icon: Icons.verified_rounded,
                    label: 'Konfirmasi Admin',
                  ),
                  buildHeaderChip(
                    icon: Icons.payments_rounded,
                    label: 'Transfer Bank',
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payments_rounded,
                      color: Colors.greenAccent,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Rp ${widget.car.pricePerDay.toStringAsFixed(0)} / hari',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget buildHeaderChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
        bottom: 10,
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

  Widget buildDateButton({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: secondaryColor,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          child: Icon(
            icon,
            color: secondaryColor,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.88),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: secondaryColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
      ),
    );
  }

  Widget buildPriceSummary() {
    final duration = getDuration();
    final total = getTotalPrice();

    return glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Colors.green,
                size: 21,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Ringkasan Biaya',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          buildPriceRow(
            title: 'Durasi sewa',
            value: '$duration hari',
          ),

          const SizedBox(
            height: 9,
          ),

          buildPriceRow(
            title: 'Harga per hari',
            value:
                'Rp ${widget.car.pricePerDay.toStringAsFixed(0)}',
          ),

          const Divider(
            height: 26,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total estimasi',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Flexible(
                child: Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPriceRow({
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
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
              'Setelah booking dibuat, admin akan mengonfirmasi terlebih dahulu. Pembayaran dilakukan setelah booking disetujui.',
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

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : bookingCar,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.check_circle_rounded,
              ),
        label: Text(
          isLoading ? 'Memproses...' : 'Buat Booking',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
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
          'Booking Mobil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: buildBackground(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            buildCarSummary(),

            const SizedBox(
              height: 24,
            ),

            glassCard(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  buildSectionTitle(
                    'Pilih Jadwal',
                    subtitle:
                        'Tentukan tanggal mulai dan selesai sewa mobil.',
                  ),

                  buildDateButton(
                    title: 'Tanggal Mulai',
                    value: startDate == null
                        ? 'Pilih tanggal mulai'
                        : formatDate(startDate),
                    icon: Icons.calendar_month_rounded,
                    onPressed: () => selectDate(
                      true,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  buildDateButton(
                    title: 'Tanggal Selesai',
                    value: endDate == null
                        ? 'Pilih tanggal selesai'
                        : formatDate(endDate),
                    icon: Icons.event_available_rounded,
                    onPressed: () => selectDate(
                      false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            glassCard(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  buildSectionTitle(
                    'Informasi Pengambilan',
                    subtitle:
                        'Isi lokasi pengambilan dan pengembalian mobil.',
                  ),

                  buildInputField(
                    controller: pickupController,
                    label: 'Lokasi Pickup',
                    hint: 'Masukkan lokasi pengambilan',
                    icon: Icons.location_on_rounded,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  buildInputField(
                    controller: returnController,
                    label: 'Lokasi Pengembalian',
                    hint: 'Masukkan lokasi pengembalian',
                    icon: Icons.assignment_return_rounded,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  buildInputField(
                    controller: notesController,
                    label: 'Catatan',
                    hint: 'Tambahkan catatan jika ada',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            buildPriceSummary(),

            const SizedBox(
              height: 18,
            ),

            buildInfoBox(),

            const SizedBox(
              height: 24,
            ),

            buildSubmitButton(),

            const SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingLinePainter extends CustomPainter {
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