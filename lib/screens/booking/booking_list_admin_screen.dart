import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../payment/payment_list_admin_screen.dart';

class BookingListAdminScreen extends StatefulWidget {
  const BookingListAdminScreen({
    super.key,
  });

  @override
  State<BookingListAdminScreen> createState() =>
      _BookingListAdminScreenState();
}

class _BookingListAdminScreenState
    extends State<BookingListAdminScreen> {
  List<BookingModel> bookings = [];

  bool isLoading = true;

  String errorMessage = '';

  String? processingBookingId;

  @override
  void initState() {
    super.initState();

    getBookings();
  }

  Future<void> getBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await BookingService.getBookings();

      if (mounted) {
        setState(() {
          bookings = result;
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

  Future<void> confirmBooking(
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Booking?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Yakin ingin mengonfirmasi booking ${booking.bookingCode ?? ''}?',
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
        processingBookingId = booking.id;
      });

      await BookingService.confirmBooking(
        booking.id ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking berhasil dikonfirmasi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await getBookings();
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
          processingBookingId = null;
        });
      }
    }
  }

  Future<void> cancelBooking(
    BookingModel booking,
  ) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                Navigator.pop(context, false);
              },
              child: const Text(
                'Tidak',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
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
        );
      },
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
        processingBookingId = booking.id;
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

      await getBookings();
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
          processingBookingId = null;
        });
      }
    }
  }

  bool canConfirm(
    BookingModel booking,
  ) {
    final status = booking.status?.toLowerCase();

    return status == 'pending';
  }

  bool canCancel(
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

  Color getBookingStatusColor(
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

  Color getPaymentStatusColor(
    String? status,
  ) {
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

  String getBookingStatusText(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';

      case 'confirmed':
        return 'Dikonfirmasi';

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

  String getPaymentStatusText(
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

  String formatDate(
    String value,
  ) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  String formatPrice(
    double value,
  ) {
    return value.toStringAsFixed(0);
  }

  void showBookingDetail(
    BookingModel booking,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                _buildDetailItem(
                  'Kode Booking',
                  booking.bookingCode ?? '-',
                ),
                _buildDetailItem(
                  'Nama User',
                  booking.userName ?? '-',
                ),
                _buildDetailItem(
                  'Email User',
                  booking.userEmail ?? '-',
                ),
                _buildDetailItem(
                  'Mobil',
                  booking.car?.name ?? '-',
                ),
                _buildDetailItem(
                  'Brand',
                  booking.car?.brand ?? '-',
                ),
                _buildDetailItem(
                  'Tanggal Mulai',
                  formatDate(booking.startDate),
                ),
                _buildDetailItem(
                  'Tanggal Selesai',
                  formatDate(booking.endDate),
                ),
                _buildDetailItem(
                  'Durasi',
                  '${booking.duration} hari',
                ),
                _buildDetailItem(
                  'Lokasi Pickup',
                  booking.pickupLocation ?? '-',
                ),
                _buildDetailItem(
                  'Lokasi Pengembalian',
                  booking.returnLocation ?? '-',
                ),
                _buildDetailItem(
                  'Status Booking',
                  getBookingStatusText(booking.status),
                ),
                _buildDetailItem(
                  'Status Pembayaran',
                  getPaymentStatusText(booking.paymentStatus),
                ),
                _buildDetailItem(
                  'Total',
                  'Rp ${formatPrice(booking.totalPrice)}',
                ),
                _buildDetailItem(
                  'Catatan',
                  booking.notes ?? '-',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Tutup',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(
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
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontSize: 13,
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

  Widget _buildStatusBadge({
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
          color: color.withOpacity(0.45),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
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
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
  ) {
    final isProcessing =
        processingBookingId == booking.id;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.car?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 19,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1A1A2E,
                    ).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.bookingCode ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.person_rounded,
                    text: 'Penyewa: ${booking.userName ?? '-'}',
                  ),
                  _buildInfoRow(
                    icon: Icons.calendar_month_rounded,
                    text:
                        'Tanggal: ${formatDate(booking.startDate)} - ${formatDate(booking.endDate)}',
                  ),
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    text: 'Pickup: ${booking.pickupLocation ?? '-'}',
                  ),
                  _buildInfoRow(
                    icon: Icons.payments_rounded,
                    text: 'Total: Rp ${formatPrice(booking.totalPrice)}',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBadge(
                  text:
                      'Booking: ${getBookingStatusText(booking.status)}',
                  color: getBookingStatusColor(
                    booking.status,
                  ),
                ),
                _buildStatusBadge(
                  text:
                      'Bayar: ${getPaymentStatusText(booking.paymentStatus)}',
                  color: getPaymentStatusColor(
                    booking.paymentStatus,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () {
                            showBookingDetail(
                              booking,
                            );
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
                      foregroundColor:
                          const Color(0xFF1A1A2E),
                      padding:
                          const EdgeInsets.symmetric(
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
                if (canConfirm(booking))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () {
                              confirmBooking(
                                booking,
                              );
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
                        isProcessing
                            ? 'Proses...'
                            : 'Konfirmasi',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
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

            if (canCancel(booking)) ...[
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () {
                          cancelBooking(
                            booking,
                          );
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
                    padding:
                        const EdgeInsets.symmetric(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F1F8,
      ),
      appBar: AppBar(
        title: const Text(
          'Kelola Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(
          0xFF1A1A2E,
        ),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PaymentListAdminScreen(),
                  ),
                );

                getBookings();
              },
              icon: const Icon(
                Icons.verified_rounded,
                size: 18,
              ),
              label: const Text(
                'Verifikasi Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      20,
                    ),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              : bookings.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada booking',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: getBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 16,
                        ),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];

                          return _buildBookingCard(
                            booking,
                          );
                        },
                      ),
                    ),
    );
  }
}