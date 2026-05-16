import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:car_rental_app/config/api_config.dart';
import 'package:car_rental_app/models/car_availability_model.dart';
import 'package:car_rental_app/models/car_model.dart';
import 'package:car_rental_app/services/auth_services.dart';

class CarService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getCars({
    int page = 1,
    int limit = 100,
    String? search,
    String? type,
    String? brand,
    String? transmission,
    String? fuel,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    if (brand != null && brand.isNotEmpty) {
      queryParams['brand'] = brand;
    }

    if (transmission != null && transmission.isNotEmpty) {
      queryParams['transmission'] = transmission;
    }

    if (fuel != null && fuel.isNotEmpty) {
      queryParams['fuel'] = fuel;
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}',
    ).replace(
      queryParameters: queryParams,
    );

    final response = await http.get(url);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] ?? {};
      final List<dynamic> carsJson = data['cars'] ?? [];

      final cars = carsJson
          .map(
            (json) => CarModel.fromJson(json),
          )
          .toList();

      return {
        'cars': cars,
        'pagination': data['pagination'],
      };
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data mobil',
    );
  }

  static Future<CarModel> getCarById(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id',
    );

    final response = await http.get(url);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return CarModel.fromJson(
        body['data']['car'],
      );
    }

    throw Exception(
      body['message'] ?? 'Mobil tidak ditemukan',
    );
  }

  static Future<CarAvailabilityModel> checkCarAvailability({
    required String carId,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$carId/availability',
    ).replace(
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    final response = await http.get(
      url,
      headers: await _authHeaders(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return CarAvailabilityModel.fromJson(
        body['data'] ?? {},
      );
    }

    throw Exception(
      body['message'] ?? 'Gagal mengecek ketersediaan mobil',
    );
  }

  static Future<List<CarModel>> getAvailableCars({
    required String startDate,
    required String endDate,
    int limit = 100,
  }) async {
    final result = await getCars(
      limit: limit,
    );

    final allCars = result['cars'] as List<CarModel>;
    final availableCars = <CarModel>[];

    for (final car in allCars) {
      final carId = car.id;

      if (carId == null || carId.isEmpty) {
        continue;
      }

      try {
        final availability = await checkCarAvailability(
          carId: carId,
          startDate: startDate,
          endDate: endDate,
        );

        if (availability.isAvailable) {
          availableCars.add(car);
        }
      } catch (_) {
        // Satu mobil gagal dicek tidak boleh menggagalkan semua daftar mobil.
        continue;
      }
    }

    return availableCars;
  }

  static Future<CarModel> createCar(CarModel car) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}',
    );

    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(
        car.toJson(),
      ),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return CarModel.fromJson(
        body['data']['car'],
      );
    }

    throw Exception(
      body['message'] ?? 'Gagal menambahkan mobil',
    );
  }

  static Future<CarModel> updateCar(
    String id,
    CarModel car,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id',
    );

    final response = await http.put(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(
        car.toJson(),
      ),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return CarModel.fromJson(
        body['data']['car'],
      );
    }

    throw Exception(
      body['message'] ?? 'Gagal memperbarui data mobil',
    );
  }

  static Future<void> deleteCar(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id',
    );

    final response = await http.delete(
      url,
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);

      throw Exception(
        body['message'] ?? 'Gagal menghapus mobil',
      );
    }
  }
}
