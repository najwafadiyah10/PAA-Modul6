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

  final _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color backgroundColor = Color(0xFFF8F1F8);

  @override
  void initState() {
    super.initState();

    _fetchCars();
  }

  Future<void> _fetchCars([
    String? searchQuery,
  ]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await CarService.getCars(
        search: searchQuery,
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(10),
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

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Colors.white.withOpacity(0.12),
          foregroundColor: foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temukan mobil terbaik',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            'Pilih mobil sesuai kebutuhan perjalananmu.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _fetchCars(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Cari mobil atau brand...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primaryColor,
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
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        6,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Mobil Tersedia',
              style: TextStyle(
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
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_cars.length} mobil',
              style: const TextStyle(
                color: primaryColor,
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
              onPressed: () => _fetchCars(),
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
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: primaryColor,
                size: 52,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Belum ada mobil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Data mobil belum tersedia atau pencarian tidak ditemukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarList() {
    return RefreshIndicator(
      onRefresh: () => _fetchCars(
        _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 20,
        ),
        itemCount: _cars.length,
        itemBuilder: (
          context,
          index,
        ) {
          final car = _cars[index];

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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daftar Mobil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildAppBarButton(
            icon: Icons.assignment_rounded,
            label: 'Booking Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BookingHistoryScreen(),
                ),
              );
            },
          ),
          _buildAppBarButton(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            backgroundColor: Colors.red.withOpacity(0.18),
            foregroundColor: Colors.white,
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(
              message: 'Memuat data mobil...',
            )
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildSectionTitle(),
                    Expanded(
                      child: _cars.isEmpty
                          ? _buildEmptyView()
                          : _buildCarList(),
                    ),
                  ],
                ),
    );
  }
}