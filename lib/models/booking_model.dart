import 'car_model.dart';

class BookingModel {
  final String? id;
  final String? bookingCode;

  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  final CarModel? car;

  final String startDate;
  final String endDate;

  final int duration;

  final double totalPrice;
  final double pricePerDay;

  final String? status;

  final String? pickupLocation;
  final String? returnLocation;

  final String? notes;

  final String? paymentStatus;

  BookingModel({
    this.id,
    this.bookingCode,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.car,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalPrice,
    required this.pricePerDay,
    this.status,
    this.pickupLocation,
    this.returnLocation,
    this.notes,
    this.paymentStatus,
  });

  static String _getPaymentStatus(Map<String, dynamic> json) {
    final rawStatus =
        json['paymentStatus'] ??
        json['payment_status'] ??
        json['payment']?['status'] ??
        json['paymentData']?['status'];

    if (rawStatus == null) {
      return 'unpaid';
    }

    final status = rawStatus.toString().toLowerCase();

    if (status == 'paid' ||
        status == 'success' ||
        status == 'verified') {
      return 'paid';
    }

    if (status == 'pending') {
      return 'pending';
    }

    if (status == 'failed') {
      return 'failed';
    }

    return status;
  }

  static CarModel? _parseCar(dynamic carData) {
    if (carData == null) {
      return null;
    }

    if (carData is Map<String, dynamic>) {
      return CarModel.fromJson(carData);
    }

    return null;
  }

  static String? _parseUserId(dynamic userData) {
    if (userData == null) {
      return null;
    }

    if (userData is Map<String, dynamic>) {
      return userData['_id']?.toString() ??
          userData['id']?.toString();
    }

    return userData.toString();
  }

  static String? _parseUserName(dynamic userData) {
    if (userData is Map<String, dynamic>) {
      return userData['name']?.toString();
    }

    return null;
  }

  static String? _parseUserEmail(dynamic userData) {
    if (userData is Map<String, dynamic>) {
      return userData['email']?.toString();
    }

    return null;
  }

  static String? _parseUserPhone(dynamic userData) {
    if (userData is Map<String, dynamic>) {
      return userData['phone']?.toString();
    }

    return null;
  }

  factory BookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final userData = json['user'];

    return BookingModel(
      id: json['_id']?.toString() ??
          json['id']?.toString(),

      bookingCode:
          json['bookingCode']?.toString(),

      userId:
          _parseUserId(userData),

      userName:
          _parseUserName(userData),

      userEmail:
          _parseUserEmail(userData),

      userPhone:
          _parseUserPhone(userData),

      car:
          _parseCar(json['car']),

      startDate:
          json['startDate']?.toString() ?? '',

      endDate:
          json['endDate']?.toString() ?? '',

      duration:
          (json['duration'] as num?)?.toInt() ?? 0,

      totalPrice:
          (json['totalPrice'] as num?)?.toDouble() ?? 0,

      pricePerDay:
          (json['pricePerDay'] as num?)?.toDouble() ?? 0,

      status:
          json['status']?.toString(),

      pickupLocation:
          json['pickupLocation']?.toString(),

      returnLocation:
          json['returnLocation']?.toString(),

      notes:
          json['notes']?.toString(),

      paymentStatus:
          _getPaymentStatus(json),
    );
  }

  BookingModel copyWith({
    String? paymentStatus,
  }) {
    return BookingModel(
      id: id,
      bookingCode: bookingCode,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      car: car,
      startDate: startDate,
      endDate: endDate,
      duration: duration,
      totalPrice: totalPrice,
      pricePerDay: pricePerDay,
      status: status,
      pickupLocation: pickupLocation,
      returnLocation: returnLocation,
      notes: notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car': car?.id,
      'startDate': startDate,
      'endDate': endDate,
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
      'notes': notes,
    };
  }
}