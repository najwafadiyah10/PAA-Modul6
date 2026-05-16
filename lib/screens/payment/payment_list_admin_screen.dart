import 'package:flutter/material.dart';

import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentListAdminScreen extends StatefulWidget {
  const PaymentListAdminScreen({
    super.key,
  });

  @override
  State<PaymentListAdminScreen> createState() =>
      _PaymentListAdminScreenState();
}

class _PaymentListAdminScreenState
    extends State<PaymentListAdminScreen> {
  List<PaymentModel> payments = [];

  bool isLoading = true;
  String errorMessage = '';

  String? processingPaymentId;

  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color backgroundColor = Color(0xFFF8F1F8);

  @override
  void initState() {
    super.initState();

    getPayments();
  }

  Future<void> getPayments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await PaymentService.getPayments();

      if (mounted) {
        setState(() {
          payments = result;
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

  Future<void> confirmPayment(
    PaymentModel payment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Verifikasi Pembayaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Yakin ingin mengonfirmasi pembayaran dari ${payment.accountName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ya, Konfirmasi',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      setState(() {
        processingPaymentId = payment.id;
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
              'Pembayaran berhasil dikonfirmasi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await getPayments();
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
          processingPaymentId = null;
        });
      }
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'verified':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
        return Colors.red;

      case 'refunded':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'verified':
        return 'Pembayaran Lunas';

      case 'pending':
        return 'Menunggu Verifikasi';

      case 'failed':
        return 'Pembayaran Gagal';

      case 'refunded':
        return 'Refund';

      default:
        return 'Tidak Diketahui';
    }
  }

  String getStatusDescription(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'verified':
        return 'Pembayaran terkonfirmasi';

      case 'pending':
        return 'User sudah membayar, klik untuk konfirmasi.';

      case 'failed':
        return 'Pembayaran gagal atau ditolak.';

      case 'refunded':
        return 'Dana pembayaran sudah dikembalikan.';

      default:
        return 'Status pembayaran belum tersedia.';
    }
  }

  String formatAmount(double? value) {
    if (value == null) {
      return '-';
    }

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

  Widget buildStatusBadge(
    PaymentModel payment,
  ) {
    final color = getStatusColor(payment.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Text(
        getStatusText(payment.status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade700,
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

  Widget buildPaymentCard(
    PaymentModel payment,
  ) {
    final isPending =
        payment.status?.toLowerCase() == 'pending';

    final isProcessing =
        processingPaymentId == payment.id;

    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentCode ??
                            payment.bookingCode ??
                            'Kode pembayaran tidak tersedia',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        payment.bookingCode == null
                            ? 'Kode booking: -'
                            : 'Kode booking: ${payment.bookingCode}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                buildStatusBadge(
                  payment,
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getStatusColor(payment.status)
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: getStatusColor(payment.status),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      getStatusDescription(payment.status),
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

            const SizedBox(
              height: 14,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  buildInfoRow(
                    icon: Icons.person_rounded,
                    title: 'Penyewa',
                    value: payment.userName ?? '-',
                  ),
                  buildInfoRow(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    value: payment.userEmail ?? '-',
                  ),
                  buildInfoRow(
                    icon: Icons.directions_car_rounded,
                    title: 'Mobil',
                    value: payment.carName ?? '-',
                  ),
                  buildInfoRow(
                    icon: Icons.payments_rounded,
                    title: 'Total Bayar',
                    value:
                        'Rp ${formatAmount(payment.amount)}',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'Data Pembayaran',
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            buildInfoRow(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Metode',
              value: formatMethod(payment.method),
            ),
            buildInfoRow(
              icon: Icons.account_balance_rounded,
              title: 'Bank',
              value: payment.bankName,
            ),
            buildInfoRow(
              icon: Icons.numbers_rounded,
              title: 'No. Rekening',
              value: payment.accountNumber,
            ),
            buildInfoRow(
              icon: Icons.badge_rounded,
              title: 'Nama Rekening',
              value: payment.accountName,
            ),
            buildInfoRow(
              icon: Icons.receipt_long_rounded,
              title: 'Transaction ID',
              value: payment.transactionId,
            ),

            if (payment.notes.isNotEmpty) ...[
              const SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      size: 19,
                      color: primaryColor,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        'Catatan: ${payment.notes}',
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

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : getPayments,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Refresh',
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
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isPending && !isProcessing
                        ? () {
                            confirmPayment(
                              payment,
                            );
                          }
                        : null,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.verified_rounded,
                            size: 18,
                          ),
                    label: Text(
                      isProcessing
                          ? 'Proses...'
                          : isPending
                              ? 'Verifikasi'
                              : 'Terkonfirmasi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor:
                          Colors.grey.shade300,
                      disabledForegroundColor:
                          Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              'Gagal memuat pembayaran',
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
              onPressed: getPayments,
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

  Widget buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: primaryColor,
                size: 52,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Belum ada pembayaran',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Data pembayaran dari penyewa akan muncul di sini.',
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

  Widget buildHeaderInfo() {
    final pendingCount = payments
        .where(
          (item) =>
              item.status?.toLowerCase() == 'pending',
        )
        .length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        4,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 28,
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
                const Text(
                  'Verifikasi Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$pendingCount pembayaran menunggu verifikasi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
        title: const Text(
          'Verifikasi Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: getPayments,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? buildErrorView()
              : payments.isEmpty
                  ? buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: getPayments,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        itemCount: payments.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return buildHeaderInfo();
                          }

                          final payment =
                              payments[index - 1];

                          return buildPaymentCard(
                            payment,
                          );
                        },
                      ),
                    ),
    );
  }
}