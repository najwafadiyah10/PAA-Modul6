import 'package:flutter/material.dart';

import 'package:car_rental_app/models/car_model.dart';
import 'package:car_rental_app/services/car_services.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:car_rental_app/widgets/loading_indicator.dart';
import 'package:car_rental_app/screens/car/car_form_screen.dart';
import 'package:car_rental_app/services/auth_services.dart';
import 'package:car_rental_app/screens/auth/login_screen.dart';

import '../booking/booking_list_admin_screen.dart';

class CarListScreenAdmin extends StatefulWidget {
  const CarListScreenAdmin({
    super.key,
  });

  @override
  State<CarListScreenAdmin> createState() =>
      _CarListScreenAdminState();
}

class _CarListScreenAdminState
    extends State<CarListScreenAdmin> {
  List<CarModel> _cars = [];

  bool _isLoading = true;

  String _errorMessage = '';

  final _searchController =
      TextEditingController();

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
          _cars =
              result['cars'] as List<CarModel>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              e.toString().replaceAll(
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

  Future<void> _deleteCar(
    CarModel car,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Mobil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus mobil ${car.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hapus',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CarService.deleteCar(
          car.id!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Mobil berhasil dihapus',
              ),
              backgroundColor: Colors.green,
            ),
          );

          _fetchCars();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
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
  }

  Future<void> _logout() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
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
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
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
            builder: (context) =>
                const LoginScreen(),
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
          backgroundColor: backgroundColor ??
              Colors.white.withOpacity(0.12),
          foregroundColor:
              foregroundColor ?? Colors.white,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
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
                backgroundColor:
                    const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'Tidak ada data mobil',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCarList() {
    return RefreshIndicator(
      onRefresh: () => _fetchCars(),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 90,
        ),
        itemCount: _cars.length,
        itemBuilder: (
          context,
          index,
        ) {
          final car = _cars[index];

          return CarCard(
            car: car,
            onEdit: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CarFormScreen(
                    car: car,
                  ),
                ),
              );

              if (result == true) {
                _fetchCars();
              }
            },
            onDelete: () => _deleteCar(
              car,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F1F8),
      appBar: AppBar(
        title: const Text(
          'Kelola Mobil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildAppBarButton(
            icon: Icons.book_online_rounded,
            label: 'Kelola Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BookingListAdminScreen(),
                ),
              );
            },
          ),
          _buildAppBarButton(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            backgroundColor:
                Colors.red.withOpacity(0.18),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(
                    message:
                        'Memuat data mobil...',
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : _cars.isEmpty
                        ? _buildEmptyView()
                        : _buildCarList(),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CarFormScreen(),
            ),
          );

          if (result == true) {
            _fetchCars();
          }
        },
        backgroundColor:
            const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Tambah Mobil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}