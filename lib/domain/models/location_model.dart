// lib/domain/models/location_model.dart

import 'package:equatable/equatable.dart';

class Area extends Equatable {
  final int id;
  final String name;
  final String slug;
  final int governorate;
  final String governorateName;

  const Area({
    required this.id,
    required this.name,
    required this.slug,
    required this.governorate,
    required this.governorateName,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      governorate: json['governorate'] ?? 0,
      governorateName: json['governorate_name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, slug, governorate, governorateName];
}

class Governorate extends Equatable {
  final int id;
  final String name;
  final String slug;
  final List<Area> areas;

  const Governorate({
    required this.id,
    required this.name,
    required this.slug,
    required this.areas,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    final areasList =
        (json['areas'] as List<dynamic>?)
            ?.map((area) => Area.fromJson(area))
            .toList() ??
        [];

    return Governorate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      areas: areasList,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, areas];
}
