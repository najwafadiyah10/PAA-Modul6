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

  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color backgroundColor = Color(0xFFF8F1F8);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
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

  Widget buildCarSummary() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Mobil',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
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
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Rp ${widget.car.pricePerDay.toStringAsFixed(0)} / hari',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
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
                      fontWeight: FontWeight.w500,
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
            color: primaryColor,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
        ),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryColor,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Ringkasan Biaya',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Durasi sewa',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '$duration hari',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harga per hari',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Rp ${widget.car.pricePerDay.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(
            height: 24,
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
              Text(
                'Rp ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
          isLoading ? 'Memproses...' : 'Booking Sekarang',
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
          elevation: 3,
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
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          buildCarSummary(),

          const SizedBox(
            height: 22,
          ),

          buildSectionTitle(
            'Pilih Jadwal',
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

          const SizedBox(
            height: 22,
          ),

          buildSectionTitle(
            'Informasi Pengambilan',
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

          const SizedBox(
            height: 22,
          ),

          buildPriceSummary(),

          const SizedBox(
            height: 26,
          ),

          buildSubmitButton(),

          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}