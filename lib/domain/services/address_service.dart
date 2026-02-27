// lib/domain/services/address_service.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/location_model.dart';

class AddressService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final accessToken = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    };
  }

  String _extractErrorMessage(Map<String, dynamic> responseBody) {
    if (responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError[0].toString();
      }
    }
    if (responseBody['message'] != null) {
      return responseBody['message'].toString();
    }
    if (responseBody['detail'] != null) {
      return responseBody['detail'].toString();
    }
    return 'Unexpected error';
  }

  /// Truncate coordinate to ensure no more than 9 total digits
  /// Backend expects DecimalField with max_digits=9
  String _formatCoordinate(double value) {
    final intPart = value.truncate().abs();
    final intDigits = intPart == 0 ? 1 : (log(intPart + 1) / ln10).ceil();
    final maxDecimalPlaces = max(0, 9 - intDigits);
    final decimalPlaces = min(6, maxDecimalPlaces);
    return value.toStringAsFixed(decimalPlaces);
  }

  /// GET /api/addresses/locations/governorates/
  Future<List<Governorate>> getGovernorates() async {
    final uri = Uri.parse(Environment.governoratesEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    dev.log('GET Governorates Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Governorate.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// GET /api/addresses/
  Future<List<AddressSummary>> getAllAddresses() async {
    final uri = Uri.parse(Environment.addressesEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    dev.log('GET All Addresses Response: $responseBody');

    if (response.statusCode == 200) {
      final List<dynamic> addressList = responseBody;
      return addressList.map((json) => AddressSummary.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception(
        _extractErrorMessage(responseBody as Map<String, dynamic>),
      );
    }
  }

  /// POST /api/addresses/
  Future<Address> addAddress({
    required String title,
    required int governorate,
    required int area,
    required String street,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? additionalNotes,
    double? latitude,
    double? longitude,
    bool isCurrent = false,
  }) async {
    final uri = Uri.parse(Environment.addressesEndpoint);
    final headers = await _getAuthHeaders();

    final Map<String, dynamic> body = {
      'title': title,
      'governorate': governorate,
      'area': area,
      'street': street,
      'is_current': isCurrent,
    };

    if (buildingNumber != null && buildingNumber.isNotEmpty) {
      body['building_number'] = buildingNumber;
    }
    if (floor != null && floor.isNotEmpty) body['floor'] = floor;
    if (apartment != null && apartment.isNotEmpty) {
      body['apartment'] = apartment;
    }
    if (landmark != null && landmark.isNotEmpty) body['landmark'] = landmark;
    if (additionalNotes != null && additionalNotes.isNotEmpty) {
      body['additional_notes'] = additionalNotes;
    }
    if (latitude != null) body['latitude'] = _formatCoordinate(latitude);
    if (longitude != null) body['longitude'] = _formatCoordinate(longitude);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body);
    dev.log('POST Add Address Response: $responseBody');

    if (response.statusCode == 201) {
      return Address.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// GET /api/addresses/{id}/
  Future<Address> getAddressById(int id) async {
    final uri = Uri.parse(Environment.addressByIdEndpoint(id));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    dev.log('GET Address by ID Response: $responseBody');

    if (response.statusCode == 200) {
      return Address.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else if (response.statusCode == 404) {
      throw Exception('Address not found');
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// PATCH /api/addresses/{id}/
  Future<Address> updateAddress({
    required int id,
    String? title,
    int? governorate,
    int? area,
    String? street,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? additionalNotes,
    double? latitude,
    double? longitude,
    bool? isCurrent,
  }) async {
    final uri = Uri.parse(Environment.addressByIdEndpoint(id));
    final headers = await _getAuthHeaders();

    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (governorate != null) body['governorate'] = governorate;
    if (area != null) body['area'] = area;
    if (street != null) body['street'] = street;
    if (buildingNumber != null) body['building_number'] = buildingNumber;
    if (floor != null) body['floor'] = floor;
    if (apartment != null) body['apartment'] = apartment;
    if (landmark != null) body['landmark'] = landmark;
    if (additionalNotes != null) body['additional_notes'] = additionalNotes;
    if (latitude != null) body['latitude'] = _formatCoordinate(latitude);
    if (longitude != null) body['longitude'] = _formatCoordinate(longitude);
    if (isCurrent != null) body['is_current'] = isCurrent;

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body);
    dev.log('PATCH Update Address Response: $responseBody');

    if (response.statusCode == 200) {
      return Address.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else if (response.statusCode == 404) {
      throw Exception('Address not found');
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// DELETE /api/addresses/{id}/
  Future<void> deleteAddress(int id) async {
    final uri = Uri.parse(Environment.addressByIdEndpoint(id));
    final headers = await _getAuthHeaders();

    final response = await http.delete(uri, headers: headers);
    dev.log('DELETE Address Response Status: ${response.statusCode}');

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else if (response.statusCode == 404) {
      throw Exception('Address not found');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// POST /api/addresses/{id}/set_current/
  Future<void> setCurrentAddress(int id) async {
    final uri = Uri.parse(Environment.setCurrentAddressEndpoint(id));
    final headers = await _getAuthHeaders();

    final response = await http.post(uri, headers: headers);
    dev.log('POST Set Current Address Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else if (response.statusCode == 404) {
      throw Exception('Address not found');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// GET /api/addresses/current/
  Future<Address?> getCurrentAddress() async {
    final uri = Uri.parse(Environment.currentAddressEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    dev.log('GET Current Address Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return Address.fromJson(responseBody);
    } else if (response.statusCode == 404) {
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final addressService = AddressService();
