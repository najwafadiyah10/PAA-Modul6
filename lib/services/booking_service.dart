import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking_model.dart';
import 'auth_services.dart';
import 'payment_service.dart';

class BookingService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<BookingModel> createBooking(
    BookingModel booking,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/bookings',
    );

    print('CREATE BOOKING BODY: ${booking.toJson()}');

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(
        booking.toJson(),
      ),
    );

    print('CREATE BOOKING STATUS: ${response.statusCode}');
    print('CREATE BOOKING RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(
        body['data']['booking'],
      );
    } else {
      throw Exception(
        body['message'] ?? 'Booking gagal',
      );
    }
  }

  static Future<BookingModel> getBookingById(
    String id,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/bookings/$id',
    );

    final response = await http.get(
      url,
      headers: await _headers(),
    );

    print('GET BOOKING DETAIL STATUS: ${response.statusCode}');
    print('GET BOOKING DETAIL RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(
        body['data']['booking'],
      );
    } else {
      throw Exception(
        body['message'] ?? 'Gagal mengambil booking',
      );
    }
  }

  static Future<List<BookingModel>> getBookings({
    int page = 1,
    int limit = 100,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/bookings',
    ).replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      url,
      headers: await _headers(),
    );

    print('GET BOOKINGS STATUS: ${response.statusCode}');
    print('BOOKING RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List bookingsJson =
          body['data']['bookings'] ?? [];

      final bookings = bookingsJson
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();

      final paymentStatusMap =
          await PaymentService.getPaymentStatusMap();

      final updatedBookings =
          bookings.map((booking) {
        final statusFromPayment =
            paymentStatusMap[booking.id];

        return booking.copyWith(
          paymentStatus:
              statusFromPayment ??
                  booking.paymentStatus ??
                  'unpaid',
        );
      }).toList();

      return updatedBookings;
    } else {
      throw Exception(
        body['message'] ?? 'Gagal mengambil booking',
      );
    }
  }

  static Future<void> confirmBooking(
    String id,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/bookings/$id/confirm',
    );

    final response = await http.put(
      url,
      headers: await _headers(),
    );

    print('CONFIRM BOOKING STATUS: ${response.statusCode}');
    print('CONFIRM BOOKING RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal konfirmasi booking',
      );
    }
  }

  static Future<void> cancelBooking(
    String id, {
    String reason = 'Dibatalkan oleh penyewa',
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/bookings/$id/cancel',
    );

    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'reason': reason,
      }),
    );

    print('CANCEL BOOKING STATUS: ${response.statusCode}');
    print('CANCEL BOOKING RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal membatalkan booking',
      );
    }
  }
}