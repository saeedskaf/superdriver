import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int id;
  final String title;
  final int governorate;
  final String governorateName;
  final int area;
  final String areaName;
  final String street;
  final String buildingNumber;
  final String floor;
  final String apartment;
  final String landmark;
  final String additionalNotes;
  final double? latitude;
  final double? longitude;
  final bool isCurrent;
  final String fullAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    required this.title,
    required this.governorate,
    required this.governorateName,
    required this.area,
    required this.areaName,
    required this.street,
    required this.buildingNumber,
    required this.floor,
    required this.apartment,
    required this.landmark,
    required this.additionalNotes,
    this.latitude,
    this.longitude,
    required this.isCurrent,
    required this.fullAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      governorate: json['governorate'] ?? 0,
      governorateName: json['governorate_name'] ?? '',
      area: json['area'] ?? 0,
      areaName: json['area_name'] ?? '',
      street: json['street'] ?? '',
      buildingNumber: json['building_number'] ?? '',
      floor: json['floor'] ?? '',
      apartment: json['apartment'] ?? '',
      landmark: json['landmark'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      isCurrent: json['is_current'] ?? false,
      fullAddress: json['full_address'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'governorate': governorate,
      'area': area,
      'street': street,
      'building_number': buildingNumber,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'additional_notes': additionalNotes,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      'is_current': isCurrent,
    };
  }

  Address copyWith({
    int? id,
    String? title,
    int? governorate,
    String? governorateName,
    int? area,
    String? areaName,
    String? street,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? additionalNotes,
    double? latitude,
    double? longitude,
    bool? isCurrent,
    String? fullAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      governorate: governorate ?? this.governorate,
      governorateName: governorateName ?? this.governorateName,
      area: area ?? this.area,
      areaName: areaName ?? this.areaName,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrent: isCurrent ?? this.isCurrent,
      fullAddress: fullAddress ?? this.fullAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    governorate,
    governorateName,
    area,
    areaName,
    street,
    buildingNumber,
    floor,
    apartment,
    landmark,
    additionalNotes,
    latitude,
    longitude,
    isCurrent,
    fullAddress,
    createdAt,
    updatedAt,
  ];
}

/// Simplified address model for list display
class AddressSummary extends Equatable {
  final int id;
  final String title;
  final String governorateName;
  final String areaName;
  final bool isCurrent;

  const AddressSummary({
    required this.id,
    required this.title,
    required this.governorateName,
    required this.areaName,
    required this.isCurrent,
  });

  factory AddressSummary.fromJson(Map<String, dynamic> json) {
    return AddressSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      governorateName: json['governorate_name'] ?? '',
      areaName: json['area_name'] ?? '',
      isCurrent: json['is_current'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, governorateName, areaName, isCurrent];
}
