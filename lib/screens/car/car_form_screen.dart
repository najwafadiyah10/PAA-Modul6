import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:car_rental_app/models/car_model.dart';
import 'package:car_rental_app/services/car_services.dart';
import 'package:car_rental_app/widgets/loading_indicator.dart';

class CarFormScreen extends StatefulWidget {
  final CarModel? car;

  const CarFormScreen({
    super.key,
    this.car,
  });

  @override
  State<CarFormScreen> createState() =>
      _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _colorController;
  late TextEditingController _priceController;
  late TextEditingController _seatsController;
  late TextEditingController _mileageController;
  late TextEditingController _locationController;
  late TextEditingController _descController;

  String _selectedType = 'sedan';
  String _selectedTransmission = 'manual';
  String _selectedFuel = 'bensin';

  bool _isAvailable = true;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF111827);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF7F2FF);

  final List<String> _types = [
    'sedan',
    'suv',
    'mpv',
    'hatchback',
    'pickup',
    'van',
  ];

  final List<String> _transmissions = [
    'manual',
    'automatic',
  ];

  final List<String> _fuels = [
    'bensin',
    'diesel',
    'hybrid',
    'electric',
  ];

  @override
  void initState() {
    super.initState();

    final car = widget.car;

    _nameController =
        TextEditingController(text: car?.name ?? '');

    _brandController =
        TextEditingController(text: car?.brand ?? '');

    _modelController =
        TextEditingController(text: car?.model ?? '');

    _yearController = TextEditingController(
      text: car?.year.toString() ?? '',
    );

    _licensePlateController = TextEditingController(
      text: car?.licensePlate ?? '',
    );

    _colorController =
        TextEditingController(text: car?.color ?? '');

    _priceController = TextEditingController(
      text: car?.pricePerDay.toStringAsFixed(0) ?? '',
    );

    _seatsController = TextEditingController(
      text: car?.seats.toString() ?? '',
    );

    _mileageController = TextEditingController(
      text: car?.mileage?.toStringAsFixed(0) ?? '',
    );

    _locationController =
        TextEditingController(text: car?.location ?? '');

    _descController = TextEditingController(
      text: car?.description ?? '',
    );

    if (car != null) {
      if (_types.contains(car.type)) {
        _selectedType = car.type;
      }

      if (_transmissions.contains(car.transmission)) {
        _selectedTransmission = car.transmission;
      }

      if (_fuels.contains(car.fuel)) {
        _selectedFuel = car.fuel;
      }

      _isAvailable = car.isAvailable;
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final carData = CarModel(
        id: widget.car?.id,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.isEmpty
            ? null
            : _modelController.text.trim(),
        type: _selectedType,
        year: int.parse(
          _yearController.text.trim(),
        ),
        licensePlate:
            _licensePlateController.text.trim(),
        color: _colorController.text.isEmpty
            ? null
            : _colorController.text.trim(),
        pricePerDay: double.parse(
          _priceController.text.trim(),
        ),
        seats: int.parse(
          _seatsController.text.trim(),
        ),
        transmission: _selectedTransmission,
        fuel: _selectedFuel,
        mileage: _mileageController.text.isEmpty
            ? null
            : double.parse(
                _mileageController.text.trim(),
              ),
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descController.text.isEmpty
            ? null
            : _descController.text.trim(),
        isAvailable: _isAvailable,
        images: widget.car?.images ?? [],
        features: widget.car?.features ?? [],
      );

      if (widget.car == null) {
        await CarService.createCar(
          carData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mobil berhasil ditambahkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await CarService.updateCar(
          widget.car!.id!,
          carData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mobil berhasil diperbarui',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _descController.dispose();

    super.dispose();
  }

  Widget _buildBackground({
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
            painter: _CarFormLinePainter(),
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

  Widget _buildHeaderCard() {
    final isEdit = widget.car != null;

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
              isEdit
                  ? Icons.edit_road_rounded
                  : Icons.add_road_rounded,
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
                  isEdit
                      ? Icons.edit_rounded
                      : Icons.directions_car_filled_rounded,
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
                      isEdit
                          ? 'Perbarui Data Mobil'
                          : 'Tambah Mobil Baru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      isEdit
                          ? 'Ubah informasi mobil yang sudah terdaftar.'
                          : 'Lengkapi data mobil agar bisa ditampilkan ke penyewa.',
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null
              ? null
              : Padding(
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: secondaryColor,
                ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.88),
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
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item.toUpperCase(),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResponsiveFields(
    List<Widget> children,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 620;

        if (!isWide) {
          return Column(
            children: children,
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 0,
          children: children.map((child) {
            return SizedBox(
              width: (constraints.maxWidth - 14) / 2,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Container(
      margin: const EdgeInsets.only(
        top: 2,
        bottom: 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _isAvailable
            ? Colors.green.withOpacity(0.08)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isAvailable
              ? Colors.green.withOpacity(0.20)
              : Colors.red.withOpacity(0.20),
        ),
      ),
      child: SwitchListTile(
        title: const Text(
          'Ketersediaan',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _isAvailable
              ? 'Mobil tersedia disewa'
              : 'Mobil sedang tidak tersedia',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        value: _isAvailable,
        activeColor: Colors.green,
        contentPadding: EdgeInsets.zero,
        onChanged: (bool value) {
          setState(() {
            _isAvailable = value;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveCar,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.save_rounded,
              ),
        label: Text(
          _isLoading
              ? 'Menyimpan...'
              : widget.car == null
                  ? 'Simpan Mobil'
                  : 'Simpan Perubahan',
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
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Informasi Utama',
            subtitle:
                'Isi identitas dasar mobil yang akan ditampilkan ke penyewa.',
          ),
          _buildInputField(
            label: 'Nama Mobil *',
            controller: _nameController,
            icon: Icons.directions_car_rounded,
            validator: (v) =>
                v!.isEmpty ? 'Wajib diisi' : null,
          ),
          _buildResponsiveFields(
            [
              _buildInputField(
                label: 'Merek *',
                controller: _brandController,
                icon: Icons.badge_rounded,
                validator: (v) =>
                    v!.isEmpty ? 'Wajib diisi' : null,
              ),
              _buildInputField(
                label: 'Model',
                controller: _modelController,
                icon: Icons.car_repair_rounded,
              ),
              _buildInputField(
                label: 'Tahun *',
                controller: _yearController,
                icon: Icons.calendar_month_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) {
                    return 'Wajib diisi';
                  }

                  if (int.tryParse(v) == null) {
                    return 'Harus angka';
                  }

                  return null;
                },
              ),
              _buildInputField(
                label: 'Plat Nomor *',
                controller: _licensePlateController,
                icon: Icons.confirmation_number_rounded,
                validator: (v) =>
                    v!.isEmpty ? 'Wajib diisi' : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationSection() {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Spesifikasi Mobil',
            subtitle:
                'Atur kategori, transmisi, bahan bakar, dan detail kendaraan.',
          ),
          _buildResponsiveFields(
            [
              _buildDropdown(
                'Tipe',
                _types,
                _selectedType,
                (val) {
                  setState(() {
                    _selectedType = val!;
                  });
                },
                icon: Icons.category_rounded,
              ),
              _buildDropdown(
                'Transmisi',
                _transmissions,
                _selectedTransmission,
                (val) {
                  setState(() {
                    _selectedTransmission = val!;
                  });
                },
                icon: Icons.settings_rounded,
              ),
              _buildDropdown(
                'Bahan Bakar',
                _fuels,
                _selectedFuel,
                (val) {
                  setState(() {
                    _selectedFuel = val!;
                  });
                },
                icon: Icons.local_gas_station_rounded,
              ),
              _buildInputField(
                label: 'Warna *',
                controller: _colorController,
                icon: Icons.palette_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Harga & Kapasitas',
            subtitle:
                'Masukkan harga sewa harian, jumlah kursi, dan jarak tempuh.',
          ),
          _buildResponsiveFields(
            [
              _buildInputField(
                label: 'Harga/Hari (Rp) *',
                controller: _priceController,
                icon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) {
                    return 'Wajib diisi';
                  }

                  if (double.tryParse(v) == null) {
                    return 'Harus angka';
                  }

                  return null;
                },
              ),
              _buildInputField(
                label: 'Kursi *',
                controller: _seatsController,
                icon: Icons.event_seat_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) {
                    return 'Wajib diisi';
                  }

                  if (int.tryParse(v) == null) {
                    return 'Harus angka';
                  }

                  return null;
                },
              ),
              _buildInputField(
                label: 'Jarak Tempuh (Miles)',
                controller: _mileageController,
                icon: Icons.speed_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) {
                    return 'Wajib diisi';
                  }

                  if (double.tryParse(v) == null) {
                    return 'Harus angka';
                  }

                  return null;
                },
              ),
              _buildInputField(
                label: 'Lokasi (Cabang)',
                controller: _locationController,
                icon: Icons.location_on_rounded,
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          _buildAvailabilitySwitch(),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Deskripsi',
            subtitle:
                'Tambahkan informasi tambahan mengenai mobil.',
          ),
          _buildInputField(
            label: 'Deskripsi',
            controller: _descController,
            icon: Icons.notes_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.car == null
              ? 'Tambah Mobil'
              : 'Edit Mobil',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildBackground(
              child: const LoadingIndicator(
                message: 'Menyimpan data...',
              ),
            )
          : _buildBackground(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(
                      height: 18,
                    ),
                    _buildBasicInfoSection(),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildSpecificationSection(),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildPriceSection(),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildDescriptionSection(),
                    const SizedBox(
                      height: 24,
                    ),
                    _buildSubmitButton(),
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CarFormLinePainter extends CustomPainter {
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