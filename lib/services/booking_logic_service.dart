import 'package:car_rental_app/models/booking_model.dart';
import 'package:car_rental_app/models/payment_model.dart';

class BookingLogicService {
  static String normalizeBookingStatus(String? status) {
    return status?.toLowerCase() ?? '';
  }

  static String normalizePaymentStatus(String? status) {
    final raw = status?.toLowerCase() ?? '';

    if (raw == 'success' || raw == 'paid' || raw == 'verified') {
      return 'paid';
    }

    if (raw == 'pending') {
      return 'pending';
    }

    if (raw == 'failed') {
      return 'failed';
    }

    if (raw == 'refunded') {
      return 'refunded';
    }

    return 'unpaid';
  }

  static bool isPaymentPaid(String? status) {
    return normalizePaymentStatus(status) == 'paid';
  }

  static bool isPaymentPending(String? status) {
    return normalizePaymentStatus(status) == 'pending';
  }

  static bool isPaymentUnpaidOrFailed(String? status) {
    final normalized = normalizePaymentStatus(status);
    return normalized == 'unpaid' || normalized == 'failed';
  }

  static List<BookingModel> filterUserBookings(
    List<BookingModel> bookings,
    String filterType,
  ) {
    return bookings.where((booking) {
      final bookingStatus = normalizeBookingStatus(booking.status);
      final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

      if (filterType == 'pending') {
        return bookingStatus == 'pending';
      }

      if (filterType == 'ready_to_pay') {
        return bookingStatus == 'confirmed' &&
            (paymentStatus == 'unpaid' || paymentStatus == 'failed');
      }

      if (filterType == 'history') {
        final isPendingBooking = bookingStatus == 'pending';
        final isReadyToPay = bookingStatus == 'confirmed' &&
            (paymentStatus == 'unpaid' || paymentStatus == 'failed');

        return !isPendingBooking && !isReadyToPay;
      }

      return true;
    }).toList();
  }

  static List<BookingModel> pendingBookings(List<BookingModel> bookings) {
    return bookings.where((booking) {
      return normalizeBookingStatus(booking.status) == 'pending';
    }).toList();
  }

  static List<PaymentModel> pendingPayments(List<PaymentModel> payments) {
    return payments.where((payment) {
      return normalizePaymentStatus(payment.status) == 'pending';
    }).toList();
  }

  static List<BookingModel> adminHistoryBookings(
    List<BookingModel> bookings, [
    String filter = 'all',
  ]) {
    return bookings.where((booking) {
      final bookingStatus = normalizeBookingStatus(booking.status);
      final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

      if (filter == 'paid') {
        return paymentStatus == 'paid' || bookingStatus == 'completed';
      }

      if (filter == 'cancelled') {
        return bookingStatus == 'cancelled';
      }

      return true;
    }).toList();
  }

  static int paidBookingCount(List<BookingModel> bookings) {
    return bookings.where((booking) {
      final bookingStatus = normalizeBookingStatus(booking.status);
      final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

      return paymentStatus == 'paid' || bookingStatus == 'completed';
    }).length;
  }

  static int cancelledBookingCount(List<BookingModel> bookings) {
    return bookings.where((booking) {
      return normalizeBookingStatus(booking.status) == 'cancelled';
    }).length;
  }

  static bool canUserPay(BookingModel booking) {
    final bookingStatus = normalizeBookingStatus(booking.status);
    final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

    return bookingStatus == 'confirmed' &&
        (paymentStatus == 'unpaid' || paymentStatus == 'failed');
  }

  static bool canUserCancel(BookingModel booking) {
    final bookingStatus = normalizeBookingStatus(booking.status);
    final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

    if (booking.id == null || booking.id!.isEmpty) {
      return false;
    }

    if (bookingStatus == 'pending') {
      return true;
    }

    if (bookingStatus == 'confirmed' &&
        (paymentStatus == 'unpaid' || paymentStatus == 'failed')) {
      return true;
    }

    return false;
  }

  static bool canAdminCancel(BookingModel booking) {
    final bookingStatus = normalizeBookingStatus(booking.status);
    final paymentStatus = normalizePaymentStatus(booking.paymentStatus);

    if (booking.id == null || booking.id!.isEmpty) {
      return false;
    }

    if (bookingStatus == 'cancelled' ||
        bookingStatus == 'completed' ||
        bookingStatus == 'active') {
      return false;
    }

    if (paymentStatus == 'paid' || paymentStatus == 'pending') {
      return false;
    }

    return bookingStatus == 'pending' || bookingStatus == 'confirmed';
  }

  static String bookingStatusText(String? status) {
    switch (normalizeBookingStatus(status)) {
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

  static String userBookingStatusText(String? status) {
    switch (normalizeBookingStatus(status)) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Booking Dikonfirmasi';
      case 'active':
        return 'Sewa Aktif';
      case 'completed':
        return 'Sewa Selesai';
      case 'cancelled':
        return 'Booking Dibatalkan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  static String paymentStatusText(String? status) {
    switch (normalizePaymentStatus(status)) {
      case 'paid':
        return 'Lunas';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Gagal';
      case 'refunded':
        return 'Refund';
      case 'unpaid':
      default:
        return 'Belum Dibayar';
    }
  }

  static String userPaymentStatusText(String? status) {
    switch (normalizePaymentStatus(status)) {
      case 'paid':
        return 'Pembayaran Lunas';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Pembayaran Gagal';
      case 'refunded':
        return 'Dana Dikembalikan';
      case 'unpaid':
      default:
        return 'Belum Dibayar';
    }
  }

  static String paymentMethodText(String method) {
    switch (method) {
      case 'transfer_bank':
        return 'Transfer Bank';
      default:
        return method;
    }
  }

  static String bookingStatusDescription(String? status) {
    switch (normalizeBookingStatus(status)) {
      case 'pending':
        return 'Booking kamu sudah dibuat dan sedang menunggu persetujuan admin.';
      case 'confirmed':
        return 'Booking sudah disetujui admin. Kamu bisa lanjut melakukan pembayaran.';
      case 'active':
        return 'Mobil sedang dalam masa penyewaan.';
      case 'completed':
        return 'Penyewaan mobil sudah selesai.';
      case 'cancelled':
        return 'Booking ini sudah dibatalkan.';
      default:
        return 'Status booking belum tersedia.';
    }
  }

  static String paymentStatusDescription(String? status) {
    switch (normalizePaymentStatus(status)) {
      case 'paid':
        return 'Pembayaran sudah dikonfirmasi oleh admin.';
      case 'pending':
        return 'Pembayaran sudah dikirim dan sedang dicek oleh admin.';
      case 'failed':
        return 'Pembayaran gagal atau ditolak. Silakan lakukan pembayaran ulang.';
      case 'refunded':
        return 'Pembayaran sudah dikembalikan.';
      case 'unpaid':
      default:
        return 'Pembayaran belum dilakukan.';
    }
  }
}
