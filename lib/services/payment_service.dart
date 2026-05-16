import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/payment_model.dart';
import '../services/auth_services.dart';

class PaymentService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> createPayment(
    PaymentModel payment,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/payments',
    );

    final body = payment.toJson();

    print('CREATE PAYMENT BODY: $body');

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    print('CREATE PAYMENT STATUS: ${response.statusCode}');
    print('CREATE PAYMENT RESPONSE: ${response.body}');

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Response server bukan JSON. Cek endpoint pembayaran.',
      );
    }

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Gagal bayar',
      );
    }
  }

  static Future<List<PaymentModel>> getPayments({
    int page = 1,
    int limit = 100,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/payments',
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

    print('GET PAYMENTS STATUS: ${response.statusCode}');
    print('GET PAYMENTS RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List paymentsJson = _extractPayments(body);

      return paymentsJson
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } else {
      throw Exception(
        body['message'] ?? 'Gagal mengambil data pembayaran',
      );
    }
  }

  static Future<void> verifyPayment({
    required String paymentId,
    String status = 'success',
    String notes = 'Pembayaran dikonfirmasi',
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/payments/$paymentId/verify',
    );

    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        'notes': notes,
      }),
    );

    print('VERIFY PAYMENT STATUS: ${response.statusCode}');
    print('VERIFY PAYMENT RESPONSE: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal verifikasi pembayaran',
      );
    }
  }

  static Future<Map<String, String>> getPaymentStatusMap() async {
    final payments = await getPayments(
      limit: 100,
    );

    final Map<String, String> result = {};

    for (final payment in payments) {
      if (payment.bookingId.isEmpty) {
        continue;
      }

      result[payment.bookingId] = _normalizePaymentStatus(
        payment.status,
      );
    }

    print('PAYMENT STATUS MAP: $result');

    return result;
  }

  static List _extractPayments(dynamic body) {
    if (body is Map &&
        body['data'] is Map &&
        body['data']['payments'] is List) {
      return body['data']['payments'];
    }

    if (body is Map && body['payments'] is List) {
      return body['payments'];
    }

    if (body is Map && body['data'] is List) {
      return body['data'];
    }

    return [];
  }

  static String _normalizePaymentStatus(dynamic rawStatus) {
    if (rawStatus == null) {
      return 'unpaid';
    }

    final status = rawStatus.toString().toLowerCase();

    if (status == 'success' ||
        status == 'paid' ||
        status == 'verified') {
      return 'paid';
    }

    if (status == 'pending') {
      return 'pending';
    }

    if (status == 'failed') {
      return 'failed';
    }

    if (status == 'refunded') {
      return 'refunded';
    }

    return 'unpaid';
  }
}