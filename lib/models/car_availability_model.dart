class CarAvailabilityModel {
  final bool isAvailable;
  final int duration;
  final double estimatedPrice;

  const CarAvailabilityModel({
    required this.isAvailable,
    required this.duration,
    required this.estimatedPrice,
  });

  factory CarAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return CarAvailabilityModel(
      isAvailable: json['isAvailable'] == true,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'duration': duration,
      'estimatedPrice': estimatedPrice,
    };
  }
}
