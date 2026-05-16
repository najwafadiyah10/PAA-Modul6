import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:car_rental_app/models/booking_model.dart';
import 'package:car_rental_app/models/car_model.dart';
import 'package:car_rental_app/models/payment_model.dart';
import 'package:car_rental_app/screens/auth/login_screen.dart';
import 'package:car_rental_app/screens/car/car_form_screen.dart';
import 'package:car_rental_app/services/auth_services.dart';
import 'package:car_rental_app/services/booking_service.dart';
import 'package:car_rental_app/services/car_services.dart';
import 'package:car_rental_app/services/payment_service.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:car_rental_app/widgets/loading_indicator.dart';

class CarListScreenAdmin extends StatefulWidget {
  const CarListScreenAdmin({
    super.key,
  });

  @override
  State<CarListScreenAdmin> createState() =>
      _CarListScreenAdminState();
}

class _CarListScreenAdminState extends State<CarListScreenAdmin> {
  List<CarModel> _cars = [];
  List<BookingModel> _bookings = [];
  List<PaymentModel> _payments = [];

  bool _isCarLoading = true;
  bool _isBookingLoading = true;
  bool _isPaymentLoading = true;

  String _carError = '';
  String _bookingError = '';
  String _paymentError = '';

  int _selectedIndex = 0;
  String _historyFilter = 'all';
  String? _processingBookingId;
  String? _processingPaymentId;

  final _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

  @override
  void initState() {
    super.initState();

    _fetchCars();
    _fetchBookings();
    _fetchPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCars([
    String? searchQuery,
  ]) async {
    setState(() {
      _isCarLoading = true;
      _carError = '';
    });

    try {
      final result = await CarService.getCars(
        search: searchQuery,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _cars = result['cars'] as List<CarModel>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carError = e.toString().replaceAll(
                'Exception: ',
                '',
              );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCarLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isBookingLoading = true;
      _bookingError = '';
    });

    try {
      final result = await BookingService.getBookings();

      if (mounted) {
        setState(() {
          _bookings = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookingError = e.toString().replaceAll(
                'Exception: ',
                '',
              );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBookingLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isPaymentLoading = true;
      _paymentError = '';
    });

    try {
      final result = await PaymentService.getPayments();

      if (mounted) {
        setState(() {
          _payments = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _paymentError = e.toString().replaceAll(
                'Exception: ',
                '',
              );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaymentLoading = false;
        });
      }
    }
  }

  Future<void> _refreshCurrentTab() async {
    if (_selectedIndex == 0) {
      await _fetchCars(
        _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
    } else if (_selectedIndex == 1) {
      await _fetchBookings();
    } else if (_selectedIndex == 2) {
      await _fetchPayments();
    } else if (_selectedIndex == 3) {
      await _fetchCars();
    } else {
      await _fetchBookings();
      await _fetchPayments();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun admin?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _openAddCar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CarFormScreen(),
      ),
    );

    if (result == true) {
      await _fetchCars();

      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  Future<void> _openEditCar(
    CarModel car,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarFormScreen(
          car: car,
        ),
      ),
    );

    if (result == true) {
      await _fetchCars();
    }
  }

  Future<void> _deleteCar(
    CarModel car,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Hapus Mobil?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus mobil ${car.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Hapus',
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await CarService.deleteCar(
        car.id ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mobil berhasil dihapus',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _fetchCars();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmBooking(
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Konfirmasi Pesanan?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin ingin mengonfirmasi booking ${booking.bookingCode ?? ''}? Setelah dikonfirmasi, penyewa bisa lanjut bayar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Ya, Konfirmasi',
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      setState(() {
        _processingBookingId = booking.id;
      });

      await BookingService.confirmBooking(
        booking.id ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan berhasil dikonfirmasi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingBookingId = null;
        });
      }
    }
  }

  Future<void> _cancelBooking(
    BookingModel booking,
  ) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            const SizedBox(
              height: 14,
            ),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan',
                hintText: 'Contoh: Mobil tidak tersedia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Tidak',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
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
      ),
    );

    if (confirm != true) {
      reasonController.dispose();
      return;
    }

    final reason = reasonController.text.trim().isEmpty
        ? 'Dibatalkan oleh admin'
        : reasonController.text.trim();

    reasonController.dispose();

    try {
      setState(() {
        _processingBookingId = booking.id;
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

      await _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingBookingId = null;
        });
      }
    }
  }

  Future<void> _verifyPayment(
    PaymentModel payment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Verifikasi Pembayaran?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin pembayaran dari ${payment.accountName} sudah sesuai?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Ya, Verifikasi',
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      setState(() {
        _processingPaymentId = payment.id;
      });

      await PaymentService.verifyPayment(
        paymentId: payment.id ?? '',
        status: 'success',
        notes: 'Pembayaran dikonfirmasi',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pembayaran berhasil diverifikasi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _fetchPayments();
      await _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingPaymentId = null;
        });
      }
    }
  }

  List<BookingModel> get _pendingBookings {
    return _bookings.where((booking) {
      return booking.status?.toLowerCase() == 'pending';
    }).toList();
  }

  List<PaymentModel> get _pendingPayments {
    return _payments.where((payment) {
      return payment.status?.toLowerCase() == 'pending';
    }).toList();
  }

  List<BookingModel> get _historyBookings {
  return _bookings.where((booking) {
    final bookingStatus =
        booking.status?.toLowerCase();

    final paymentStatus =
        booking.paymentStatus?.toLowerCase();

    if (_historyFilter == 'paid') {
      return paymentStatus == 'paid' ||
          paymentStatus == 'success' ||
          paymentStatus == 'verified' ||
          bookingStatus == 'completed';
    }

    if (_historyFilter == 'cancelled') {
      return bookingStatus == 'cancelled';
    }

    // All = tampilkan semua booking
    return true;
  }).toList();
}

  int get _paidHistoryCount {
  return _bookings.where((booking) {
    final bookingStatus =
        booking.status?.toLowerCase();

    final paymentStatus =
        booking.paymentStatus?.toLowerCase();

    return paymentStatus == 'paid' ||
        paymentStatus == 'success' ||
        paymentStatus == 'verified' ||
        bookingStatus == 'completed';
  }).length;
}

  int get _cancelledHistoryCount {
    return _bookings.where((booking) {
      return booking.status?.toLowerCase() == 'cancelled';
    }).length;
  }

  bool _canCancelBooking(
    BookingModel booking,
  ) {
    final status = booking.status?.toLowerCase();
    final paymentStatus = booking.paymentStatus?.toLowerCase();

    if (status == 'cancelled' ||
        status == 'completed' ||
        status == 'active') {
      return false;
    }

    if (paymentStatus == 'paid' ||
        paymentStatus == 'success' ||
        paymentStatus == 'pending') {
      return false;
    }

    return status == 'pending' || status == 'confirmed';
  }

  String _formatDate(
    String value,
  ) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  String _formatPrice(
    double value,
  ) {
    return value.toStringAsFixed(0);
  }

  String _bookingStatusText(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Siap Dibayar';
      case 'active':
        return 'Sewa Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _paymentStatusText(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'Lunas';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Gagal';
      case 'unpaid':
        return 'Belum Dibayar';
      case 'refunded':
        return 'Refund';
      default:
        return 'Belum Ada';
    }
  }

  String _paymentMethodText(
    String method,
  ) {
    switch (method) {
      case 'transfer_bank':
        return 'Transfer Bank';
      default:
        return method;
    }
  }

  Color _bookingStatusColor(
    String? status,
  ) {
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

  Color _paymentStatusColor(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'unpaid':
        return Colors.red;
      case 'refunded':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String _appBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard Admin';
      case 1:
        return 'Verifikasi Pesanan';
      case 2:
        return 'Verifikasi Pembayaran';
      case 3:
        return 'Tambah Mobil';
      case 4:
        return 'Histori Booking';
      default:
        return 'Admin';
    }
  }

  Widget _background({
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
            painter: _AdminLinePainter(),
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

  Widget _glassCard({
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

  Widget _headerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
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
              icon,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 13,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.76),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(
                  height: 16,
                ),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.white,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
            size: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _emptyView({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: _glassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: secondaryColor,
                size: 44,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              subtitle,
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

  Widget _errorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _glassCard(
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
                'Gagal memuat data',
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
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Coba Lagi',
                ),
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
      ),
    );
  }

  void _showBookingDetail(
    BookingModel booking,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Detail Booking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogItem('Kode Booking', booking.bookingCode ?? '-'),
                _dialogItem('Penyewa', booking.userName ?? '-'),
                _dialogItem('Email', booking.userEmail ?? '-'),
                _dialogItem('Mobil', booking.car?.name ?? '-'),
                _dialogItem('Tanggal Mulai', _formatDate(booking.startDate)),
                _dialogItem('Tanggal Selesai', _formatDate(booking.endDate)),
                _dialogItem('Durasi', '${booking.duration} hari'),
                _dialogItem('Pickup', booking.pickupLocation ?? '-'),
                _dialogItem('Return', booking.returnLocation ?? '-'),
                _dialogItem('Status Booking', _bookingStatusText(booking.status)),
                _dialogItem('Status Bayar', _paymentStatusText(booking.paymentStatus)),
                _dialogItem('Total', 'Rp ${_formatPrice(booking.totalPrice)}'),
                _dialogItem('Catatan', booking.notes ?? '-'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogItem(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard({
    required BookingModel booking,
    bool showActions = true,
  }) {
    final isProcessing = _processingBookingId == booking.id;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.car?.name ?? '-',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        booking.car?.brand ?? '-',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(
                  text: booking.bookingCode ?? '-',
                  color: secondaryColor,
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            _infoRow(
              icon: Icons.person_rounded,
              title: 'Penyewa',
              value: booking.userName ?? '-',
            ),
            _infoRow(
              icon: Icons.calendar_month_rounded,
              title: 'Tanggal',
              value:
                  '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}',
            ),
            _infoRow(
              icon: Icons.payments_rounded,
              title: 'Total',
              value: 'Rp ${_formatPrice(booking.totalPrice)}',
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusBadge(
                  text: 'Booking: ${_bookingStatusText(booking.status)}',
                  color: _bookingStatusColor(booking.status),
                ),
                _statusBadge(
                  text: 'Bayar: ${_paymentStatusText(booking.paymentStatus)}',
                  color: _paymentStatusColor(booking.paymentStatus),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () {
                              _showBookingDetail(booking);
                            },
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Detail',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (booking.status?.toLowerCase() == 'pending') ...[
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isProcessing
                            ? null
                            : () {
                                _confirmBooking(booking);
                              },
                        icon: isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                              ),
                        label: Text(
                          isProcessing ? 'Proses...' : 'Konfirmasi',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_canCancelBooking(booking)) ...[
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () {
                            _cancelBooking(booking);
                          },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Batalkan Booking',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(
    PaymentModel payment,
  ) {
    final isPending = payment.status?.toLowerCase() == 'pending';
    final isProcessing = _processingPaymentId == payment.id;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentCode ?? 'Kode pembayaran tidak tersedia',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Booking: ${payment.bookingCode ?? '-'}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(
                  text: _paymentStatusText(payment.status),
                  color: _paymentStatusColor(payment.status),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            _infoRow(
              icon: Icons.person_rounded,
              title: 'Penyewa',
              value: payment.userName ?? '-',
            ),
            _infoRow(
              icon: Icons.email_rounded,
              title: 'Email',
              value: payment.userEmail ?? '-',
            ),
            _infoRow(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Metode',
              value: _paymentMethodText(payment.method),
            ),
            _infoRow(
              icon: Icons.account_balance_rounded,
              title: 'Bank',
              value: payment.bankName,
            ),
            _infoRow(
              icon: Icons.badge_rounded,
              title: 'Nama Rekening',
              value: payment.accountName,
            ),
            _infoRow(
              icon: Icons.numbers_rounded,
              title: 'No. Rekening',
              value: payment.accountNumber,
            ),
            _infoRow(
              icon: Icons.payments_rounded,
              title: 'Nominal',
              value: payment.amount == null
                  ? '-'
                  : 'Rp ${payment.amount!.toStringAsFixed(0)}',
            ),
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isPending && !isProcessing
                    ? () {
                        _verifyPayment(payment);
                      }
                    : null,
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.verified_rounded,
                      ),
                label: Text(
                  isProcessing
                      ? 'Memproses...'
                      : isPending
                          ? 'Verifikasi Pembayaran'
                          : 'Sudah Dicek',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardPage() {
    if (_isCarLoading) {
      return _background(
        child: const LoadingIndicator(
          message: 'Memuat data mobil...',
        ),
      );
    }

    if (_carError.isNotEmpty) {
      return _background(
        child: _errorView(
          message: _carError,
          onRetry: () => _fetchCars(),
        ),
      );
    }

    return _background(
      child: RefreshIndicator(
        onRefresh: () => _fetchCars(
          _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ),
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 115,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _headerCard(
                title: 'Dashboard Admin',
                subtitle:
                    'Kelola mobil, pesanan, dan pembayaran dalam satu halaman.',
                icon: Icons.admin_panel_settings_rounded,
                trailing: Row(
                  children: [
                    _statChip(
                      icon: Icons.directions_car_rounded,
                      title: 'Mobil',
                      value: _cars.length.toString(),
                      color: accentColor,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    _statChip(
                      icon: Icons.assignment_rounded,
                      title: 'Pesanan',
                      value: _pendingBookings.length.toString(),
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    _statChip(
                      icon: Icons.payments_rounded,
                      title: 'Bayar',
                      value: _pendingPayments.length.toString(),
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _glassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _fetchCars(value.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari mobil atau brand...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: secondaryColor,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _fetchCars();
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                          ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'List Mobil',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _statusBadge(
                    text: '${_cars.length} mobil',
                    color: secondaryColor,
                  ),
                ],
              ),
            ),
            if (_cars.isEmpty)
              _emptyView(
                icon: Icons.directions_car_filled_rounded,
                title: 'Belum ada mobil',
                subtitle: 'Tambahkan data mobil melalui tab Tambah.',
              )
            else
              ..._cars.map((car) {
                return CarCard(
                  car: car,
                  onEdit: () => _openEditCar(car),
                  onDelete: () => _deleteCar(car),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _ordersPage() {
    if (_isBookingLoading) {
      return _background(
        child: const LoadingIndicator(
          message: 'Memuat pesanan...',
        ),
      );
    }

    if (_bookingError.isNotEmpty) {
      return _background(
        child: _errorView(
          message: _bookingError,
          onRetry: _fetchBookings,
        ),
      );
    }

    final data = _pendingBookings;

    return _background(
      child: RefreshIndicator(
        onRefresh: _fetchBookings,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 115,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _headerCard(
                title: 'Verifikasi Pesanan',
                subtitle:
                    'Pesanan baru yang masih menunggu konfirmasi admin.',
                icon: Icons.fact_check_rounded,
                trailing: Row(
                  children: [
                    _statChip(
                      icon: Icons.hourglass_top_rounded,
                      title: 'Menunggu',
                      value: data.length.toString(),
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.done_all_rounded,
                      title: 'Total Booking',
                      value: _bookings.length.toString(),
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (data.isEmpty)
              _emptyView(
                icon: Icons.fact_check_rounded,
                title: 'Tidak ada pesanan baru',
                subtitle: 'Semua pesanan sudah diproses.',
              )
            else
              ...data.map((booking) {
                return _bookingCard(
                  booking: booking,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _paymentsPage() {
    if (_isPaymentLoading) {
      return _background(
        child: const LoadingIndicator(
          message: 'Memuat pembayaran...',
        ),
      );
    }

    if (_paymentError.isNotEmpty) {
      return _background(
        child: _errorView(
          message: _paymentError,
          onRetry: _fetchPayments,
        ),
      );
    }

    final data = _pendingPayments;

    return _background(
      child: RefreshIndicator(
        onRefresh: _fetchPayments,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 115,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _headerCard(
                title: 'Verifikasi Pembayaran',
                subtitle:
                    'Pembayaran dari penyewa yang perlu dicek admin.',
                icon: Icons.verified_rounded,
                trailing: Row(
                  children: [
                    _statChip(
                      icon: Icons.payments_rounded,
                      title: 'Menunggu',
                      value: data.length.toString(),
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.receipt_long_rounded,
                      title: 'Semua Payment',
                      value: _payments.length.toString(),
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (data.isEmpty)
              _emptyView(
                icon: Icons.verified_rounded,
                title: 'Tidak ada pembayaran pending',
                subtitle: 'Semua pembayaran sudah dicek.',
              )
            else
              ...data.map((payment) {
                return _paymentCard(payment);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _addCarPage() {
    return _background(
      child: ListView(
        padding: const EdgeInsets.only(
          bottom: 115,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _headerCard(
              title: 'Tambah Mobil',
              subtitle:
                  'Tambahkan data mobil baru agar bisa muncul di dashboard penyewa.',
              icon: Icons.add_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: _glassCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: secondaryColor,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Input Data Mobil Baru',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Form tambah mobil tetap memakai halaman CarFormScreen yang sudah ada, jadi logic API tidak berubah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openAddCar,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Tambah Mobil Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyFilterChip({
    required String value,
    required String label,
  }) {
    final selected = _historyFilter == value;

    return ChoiceChip(
      selected: selected,
      label: Text(
        label,
      ),
      selectedColor: secondaryColor,
      backgroundColor: Colors.white.withOpacity(0.84),
      labelStyle: TextStyle(
        color: selected ? Colors.white : primaryColor,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(
        color: selected
            ? secondaryColor
            : secondaryColor.withOpacity(0.18),
      ),
      onSelected: (_) {
        setState(() {
          _historyFilter = value;
        });
      },
    );
  }

  Widget _historyPage() {
    if (_isBookingLoading) {
      return _background(
        child: const LoadingIndicator(
          message: 'Memuat histori booking...',
        ),
      );
    }

    if (_bookingError.isNotEmpty) {
      return _background(
        child: _errorView(
          message: _bookingError,
          onRetry: _fetchBookings,
        ),
      );
    }

    final data = _historyBookings;

    return _background(
      child: RefreshIndicator(
        onRefresh: () async {
          await _fetchBookings();
          await _fetchPayments();
        },
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 115,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _headerCard(
                title: 'Histori Booking',
                subtitle:
                    'Pantau semua booking yang sudah berjalan, lunas, atau dibatalkan.',
                icon: Icons.history_rounded,
                trailing: Row(
                  children: [
                    _statChip(
                      icon: Icons.list_alt_rounded,
                      title: 'Semua',
                      value: _bookings.length.toString(),
                      color: accentColor,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.check_circle_rounded,
                      title: 'Lunas',
                      value: _paidHistoryCount.toString(),
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.cancel_rounded,
                      title: 'Batal',
                      value: _cancelledHistoryCount.toString(),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _historyFilterChip(
                    value: 'all',
                    label: 'All',
                  ),
                  _historyFilterChip(
                    value: 'paid',
                    label: 'Lunas',
                  ),
                  _historyFilterChip(
                    value: 'cancelled',
                    label: 'Dibatalkan',
                  ),
                ],
              ),
            ),
            if (data.isEmpty)
              _emptyView(
                icon: Icons.history_rounded,
                title: 'Belum ada histori',
                subtitle: 'Histori booking akan tampil di sini.',
              )
            else
              ...data.map((booking) {
                return _bookingCard(
                  booking: booking,
                  showActions: false,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 0:
        return _dashboardPage();
      case 1:
        return _ordersPage();
      case 2:
        return _paymentsPage();
      case 3:
        return _addCarPage();
      case 4:
        return _historyPage();
      default:
        return _dashboardPage();
    }
  }

  Widget _topActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBar() {
    final items = [
      _AdminNavItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      _AdminNavItem(
        icon: Icons.fact_check_rounded,
        label: 'Pesanan',
      ),
      _AdminNavItem(
        icon: Icons.verified_rounded,
        label: 'Bayar',
      ),
      _AdminNavItem(
        icon: Icons.add_rounded,
        label: 'Tambah',
      ),
      _AdminNavItem(
        icon: Icons.history_rounded,
        label: 'Histori',
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.80),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.88),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = _selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
  // index 3 = tab Tambah
  if (index == 3) {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CarFormScreen(),
      ),
    );

    if (result == true) {
      _fetchCars();
    }

    return;
  }

  setState(() {
    _selectedIndex = index;
  });
},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: selected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  secondaryColor,
                                ],
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 21,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 10.5,
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _appBarTitle(),
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
                primaryColor,
                Color(0xFF312E81),
                secondaryColor,
              ],
            ),
          ),
        ),
        actions: [
          _topActionButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onPressed: _refreshCurrentTab,
          ),
          _topActionButton(
            icon: Icons.logout_rounded,
            tooltip: 'Keluar',
            color: Colors.red.shade100,
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentPage(),
      bottomNavigationBar: _navBar(),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final String label;

  const _AdminNavItem({
    required this.icon,
    required this.label,
  });
}

class _AdminLinePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFF7C3AED).withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 62) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    for (double i = 0; i < size.width + size.height; i += 92) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        accentPaint,
      );
    }

    final wavePaint = Paint()
      ..color = const Color(0xFF111827).withOpacity(0.035)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height * 0.20);

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

    secondPath.moveTo(0, size.height * 0.82);

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
