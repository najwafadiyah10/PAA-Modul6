class PaymentModel {
  final String? id;

  final String bookingId;
  final String method;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String transactionId;
  final String notes;

  final String? status;
  final double? amount;
  final String? paymentCode;
  final String? createdAt;
  final String? verifiedAt;

  final String? userName;
  final String? userEmail;
  final String? bookingCode;
  final String? carName;

  PaymentModel({
    this.id,
    required this.bookingId,
    required this.method,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.transactionId,
    required this.notes,
    this.status,
    this.amount,
    this.paymentCode,
    this.createdAt,
    this.verifiedAt,
    this.userName,
    this.userEmail,
    this.bookingCode,
    this.carName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'];
    final user = json['user'];

    String parsedBookingId = '';

    if (booking is Map<String, dynamic>) {
      parsedBookingId =
          booking['_id']?.toString() ??
          booking['id']?.toString() ??
          '';
    } else {
      parsedBookingId =
          json['bookingId']?.toString() ??
          json['booking']?.toString() ??
          '';
    }

    return PaymentModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),

      bookingId: parsedBookingId,

      method: json['method']?.toString() ?? '-',
      bankName: json['bankName']?.toString() ?? '-',
      accountNumber: json['accountNumber']?.toString() ?? '-',
      accountName: json['accountName']?.toString() ?? '-',
      transactionId: json['transactionId']?.toString() ?? '-',
      notes: json['notes']?.toString() ?? '',

      status: json['status']?.toString() ?? 'pending',

      amount: (json['amount'] as num?)?.toDouble(),

      paymentCode: json['paymentCode']?.toString(),

      createdAt: json['createdAt']?.toString(),
      verifiedAt: json['verifiedAt']?.toString(),

      userName: user is Map<String, dynamic>
          ? user['name']?.toString()
          : null,

      userEmail: user is Map<String, dynamic>
          ? user['email']?.toString()
          : null,

      bookingCode: booking is Map<String, dynamic>
          ? booking['bookingCode']?.toString()
          : null,

      carName: booking is Map<String, dynamic> &&
              booking['car'] is Map<String, dynamic>
          ? booking['car']['name']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'method': method,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'transactionId': transactionId,
      'notes': notes,
    };
  }
}