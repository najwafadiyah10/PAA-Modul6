import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:car_rental_app/models/car_model.dart';
import 'package:car_rental_app/services/car_services.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:car_rental_app/widgets/loading_indicator.dart';

import 'package:car_rental_app/services/auth_services.dart';
import 'package:car_rental_app/screens/auth/login_screen.dart';

import '../booking/booking_screen.dart';
import '../booking/booking_history_screen.dart';

class CarListScreenUser extends StatefulWidget {
  const CarListScreenUser({
    super.key,
  });

  @override
  State<CarListScreenUser> createState() =>
      _CarListScreenUserState();
}

class _CarListScreenUserState extends State<CarListScreenUser> {
  List<CarModel> _cars = [];

  bool _isLoading = true;

  String _errorMessage = '';

  int _selectedIndex = 0;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  bool isFilteringAvailability = false;
  bool isAvailabilityFiltered = false;

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

  @override
  void initState() {
    super.initState();

    _fetchCars();
  }

  Future<void> _fetchCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      isAvailabilityFiltered = false;
    });

    try {
      final result = await CarService.getCars(
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
          _errorMessage = e.toString().replaceAll(
                'Exception: ',
                '',
              );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return date.toIso8601String().split('T')[0];
  }

  Future<void> _selectAvailabilityDate(
    bool isStartDate,
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
        if (isStartDate) {
          selectedStartDate = picked;

          if (selectedEndDate != null &&
              selectedEndDate!.isBefore(selectedStartDate!)) {
            selectedEndDate = null;
          }
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _checkAvailableCars() async {
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih tanggal mulai dan tanggal selesai dulu',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    if (selectedEndDate!.isBefore(selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal selesai tidak boleh sebelum tanggal mulai',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      isFilteringAvailability = true;
    });

    try {
      final availableCars = await CarService.getAvailableCars(
        startDate: _formatDate(selectedStartDate),
        endDate: _formatDate(selectedEndDate),
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _cars = availableCars;
          isAvailabilityFiltered = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll(
                'Exception: ',
                '',
              );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          isFilteringAvailability = false;
        });
      }
    }
  }

  Future<void> _resetAvailabilityFilter() async {
    setState(() {
      selectedStartDate = null;
      selectedEndDate = null;
      isAvailabilityFiltered = false;
    });

    await _fetchCars();
  }

  Future<void> _refreshDashboard() async {
    if (selectedStartDate != null && selectedEndDate != null) {
      await _checkAvailableCars();
    } else {
      await _fetchCars();
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
          'Apakah Anda yakin ingin keluar dari akun ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
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

  String getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Menunggu Konfirmasi';
      case 2:
        return 'Bayar Pesanan';
      case 3:
        return 'Riwayat';
      default:
        return 'Car Rental';
    }
  }

  Widget _buildDecoratedBackground({
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
          painter: _SoftLineBackgroundPainter(),
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

  Widget _buildSoftCircle({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF312E81),
            Color(0xFF7C3AED),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
  right: -10,
  top: 12,
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
          Colors.white.withOpacity(0.22),
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
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cek Mobil Tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Pilih tanggal sewa untuk melihat mobil yang bisa dibooking.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDateFilterBox(
                      title: 'Tanggal Mulai',
                      value: selectedStartDate == null
                          ? 'Pilih tanggal'
                          : _formatDate(selectedStartDate),
                      icon: Icons.calendar_month_rounded,
                      onTap: () => _selectAvailabilityDate(true),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildDateFilterBox(
                      title: 'Tanggal Selesai',
                      value: selectedEndDate == null
                          ? 'Pilih tanggal'
                          : _formatDate(selectedEndDate),
                      icon: Icons.event_available_rounded,
                      onTap: () => _selectAvailabilityDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isFilteringAvailability
                          ? null
                          : _checkAvailableCars,
                      icon: isFilteringAvailability
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.search_rounded,
                            ),
                      label: Text(
                        isFilteringAvailability
                            ? 'Mengecek...'
                            : 'Cek Mobil Tersedia',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: secondaryColor,
                        disabledBackgroundColor:
                            Colors.white.withOpacity(0.5),
                        disabledForegroundColor: secondaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  if (isAvailabilityFiltered) ...[
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: _resetAvailabilityFilter,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterBox({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.75),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: secondaryColor,
              size: 20,
            ),
            const SizedBox(
              width: 8,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isAvailabilityFiltered
                  ? 'Mobil Tersedia di Tanggal Ini'
                  : 'Semua Mobil',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: secondaryColor.withOpacity(0.18),
              ),
            ),
            child: Text(
              '${_cars.length} mobil',
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return _buildDecoratedBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 14,
                sigmaY: 14,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.86),
                  ),
                ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ElevatedButton.icon(
                      onPressed: _refreshDashboard,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.68),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      size: 52,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    isAvailabilityFiltered
                        ? 'Mobil tidak tersedia'
                        : 'Belum ada mobil',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    isAvailabilityFiltered
                        ? 'Tidak ada mobil yang tersedia pada rentang tanggal tersebut.'
                        : 'Data mobil belum tersedia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (isAvailabilityFiltered) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetAvailabilityFilter,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'Tampilkan Semua Mobil',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPage() {
    if (_isLoading) {
      return _buildDecoratedBackground(
        child: LoadingIndicator(
          message: isFilteringAvailability
              ? 'Mengecek ketersediaan mobil...'
              : 'Memuat data mobil...',
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorView();
    }

    return _buildDecoratedBackground(
      child: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 110,
          ),
          children: [
            _buildHeader(),
            _buildSectionTitle(),
            if (_cars.isEmpty)
              SizedBox(
                height: 380,
                child: _buildEmptyView(),
              )
            else
              ..._cars.map((car) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: CarCard(
                    car: car,
                    onBooking: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            car: car,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage();

      case 1:
        return const BookingHistoryScreen(
          key: ValueKey('pending_bookings'),
          filterType: 'pending',
          title: 'Menunggu Konfirmasi',
          emptyMessage: 'Belum ada booking yang menunggu konfirmasi.',
          showAppBar: false,
        );

      case 2:
        return const BookingHistoryScreen(
          key: ValueKey('ready_to_pay_bookings'),
          filterType: 'ready_to_pay',
          title: 'Tinggal Bayar',
          emptyMessage: 'Belum ada booking yang tinggal dibayar.',
          showAppBar: false,
        );

      case 3:
        return const BookingHistoryScreen(
          key: ValueKey('history_bookings'),
          filterType: 'history',
          title: 'Riwayat Booking',
          emptyMessage: 'Belum ada riwayat booking.',
          showAppBar: false,
        );

      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
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

  Widget _buildNavBar() {
    final items = [
      _NavItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      _NavItem(
        icon: Icons.hourglass_top_rounded,
        label: 'Menunggu',
      ),
      _NavItem(
        icon: Icons.payments_rounded,
        label: 'Bayar',
      ),
      _NavItem(
        icon: Icons.history_rounded,
        label: 'Riwayat',
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        14,
        0,
        14,
        12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.86),
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
                final isSelected = _selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF111827),
                                  Color(0xFF7C3AED),
                                ],
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 22,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
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
          getAppBarTitle(),
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
        actions: [
          if (_selectedIndex == 0)
            _buildTopActionButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onPressed: _refreshDashboard,
            ),
          _buildTopActionButton(
            icon: Icons.logout_rounded,
            tooltip: 'Keluar',
            color: Colors.red.shade100,
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildNavBar(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

class _SoftLineBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7C3AED).withOpacity(0.045)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 58) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    for (double i = 0; i < size.width + size.height; i += 86) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        accentPaint,
      );
    }

    final wavePaint = Paint()
      ..color = const Color(0xFF111827).withOpacity(0.035)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.18,
    );

    path.cubicTo(
      size.width * 0.28,
      size.height * 0.12,
      size.width * 0.58,
      size.height * 0.26,
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
      size.height * 0.78,
    );

    secondPath.cubicTo(
      size.width * 0.30,
      size.height * 0.70,
      size.width * 0.62,
      size.height * 0.88,
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