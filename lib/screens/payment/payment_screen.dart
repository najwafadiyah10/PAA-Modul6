import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final accountNumberController =
      TextEditingController();

  final accountNameController =
      TextEditingController();

  final notesController =
      TextEditingController();

  String selectedMethod = 'transfer_bank';

  String selectedBank = 'BCA';

  // final List<String> methods = [
  //   'transfer_bank',
  //   'e_wallet',
  //   'cash',
  // ];

  final List<String> banks = [
    'BCA',
    'BRI',
    'BNI',
    'Mandiri',
    'BSI',
  ];

  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color backgroundColor = Color(0xFFF8F1F8);

  Future<void> submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final payment = PaymentModel(
        bookingId: widget.booking.id ?? '',
        method: selectedMethod,
        bankName: selectedBank,
        accountNumber: accountNumberController.text,
        accountName: accountNameController.text,
        transactionId:
            'TRX-${DateTime.now().millisecondsSinceEpoch}',
        notes: notesController.text,
      );

      await PaymentService.createPayment(
        payment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pembayaran berhasil dikirim',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
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
    accountNumberController.dispose();

    accountNameController.dispose();

    notesController.dispose();

    super.dispose();
  }

  String formatPrice(double value) {
    return value.toStringAsFixed(0);
  }

  String formatMethod(String value) {
    switch (value) {
      case 'transfer_bank':
        return 'Transfer Bank';

      case 'e_wallet':
        return 'E-Wallet';

      case 'cash':
        return 'Cash';

      default:
        return value;
    }
  }

  Widget buildBookingSummary() {
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
            'Ringkasan Booking',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
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
                      widget.booking.car?.name ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.booking.car?.brand ?? '-',
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
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                buildSummaryRow(
                  title: 'Kode Booking',
                  value: widget.booking.bookingCode ?? '-',
                  isDark: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                buildSummaryRow(
                  title: 'Total Bayar',
                  value:
                      'Rp ${formatPrice(widget.booking.totalPrice)}',
                  isDark: true,
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow({
    required String title,
    required String value,
    bool isDark = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.72)
                : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isHighlight
                  ? Colors.greenAccent
                  : isDark
                      ? Colors.white
                      : primaryColor,
              fontSize: isHighlight ? 16 : 13,
              fontWeight:
                  isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
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

  Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    bool formatPaymentMethod = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
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
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(
            formatPaymentMethod ? formatMethod(e) : e,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.white,
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

  Widget buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 22,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              'Setelah pembayaran dikirim, status akan menjadi menunggu verifikasi admin.',
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
        onPressed: isLoading ? null : submitPayment,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.send_rounded,
              ),
        label: Text(
          isLoading
              ? 'Mengirim Pembayaran...'
              : 'Kirim Pembayaran',
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
          'Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              buildBookingSummary(),

              const SizedBox(
                height: 22,
              ),

              buildSectionTitle(
  'Metode Pembayaran',
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.account_balance_rounded,
          color: primaryColor,
        ),
      ),
      const SizedBox(
        width: 12,
      ),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Bank',
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Pembayaran akan dicek dan diverifikasi oleh admin.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 14,
),

              const SizedBox(
                height: 14,
              ),

              buildDropdownField(
                label: 'Bank',
                value: selectedBank,
                items: banks,
                icon: Icons.account_balance_rounded,
                onChanged: (value) {
                  setState(() {
                    selectedBank = value!;
                  });
                },
              ),

              const SizedBox(
                height: 22,
              ),

              buildSectionTitle(
                'Data Rekening Pengirim',
              ),

              buildTextField(
                controller: accountNumberController,
                label: 'Nomor Rekening',
                hint: 'Masukkan nomor rekening',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nomor rekening wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 14,
              ),

              buildTextField(
                controller: accountNameController,
                label: 'Nama Pemilik Rekening',
                hint: 'Masukkan nama pemilik rekening',
                icon: Icons.person_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama rekening wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 14,
              ),

              buildTextField(
                controller: notesController,
                label: 'Catatan',
                hint: 'Tambahkan catatan jika ada',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(
                height: 18,
              ),

              buildInfoBox(),

              const SizedBox(
                height: 26,
              ),

              buildSubmitButton(),

              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}