// lib/domain/bloc/address/address_event.dart

part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class GovernoratesRequested extends AddressEvent {
  final bool forceRefresh;

  const GovernoratesRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddressListRequested extends AddressEvent {
  const AddressListRequested();
}

class AddressDetailRequested extends AddressEvent {
  final int id;

  const AddressDetailRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class AddressAddRequested extends AddressEvent {
  final String title;
  final int governorate;
  final int area;
  final String street;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final String? additionalNotes;
  final double? latitude;
  final double? longitude;
  final bool isCurrent;

  const AddressAddRequested({
    required this.title,
    required this.governorate,
    required this.area,
    required this.street,
    this.buildingNumber,
    this.floor,
    this.apartment,
    this.landmark,
    this.additionalNotes,
    this.latitude,
    this.longitude,
    this.isCurrent = false,
  });

  @override
  List<Object?> get props => [
    title,
    governorate,
    area,
    street,
    buildingNumber,
    floor,
    apartment,
    landmark,
    additionalNotes,
    latitude,
    longitude,
    isCurrent,
  ];
}

class AddressUpdateRequested extends AddressEvent {
  final int id;
  final String? title;
  final int? governorate;
  final int? area;
  final String? street;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final String? additionalNotes;
  final double? latitude;
  final double? longitude;
  final bool? isCurrent;

  const AddressUpdateRequested({
    required this.id,
    this.title,
    this.governorate,
    this.area,
    this.street,
    this.buildingNumber,
    this.floor,
    this.apartment,
    this.landmark,
    this.additionalNotes,
    this.latitude,
    this.longitude,
    this.isCurrent,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    governorate,
    area,
    street,
    buildingNumber,
    floor,
    apartment,
    landmark,
    additionalNotes,
    latitude,
    longitude,
    isCurrent,
  ];
}

class AddressDeleteRequested extends AddressEvent {
  final int id;

  const AddressDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class AddressSetCurrentRequested extends AddressEvent {
  final int id;

  const AddressSetCurrentRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class CurrentAddressRequested extends AddressEvent {
  const CurrentAddressRequested();
}
