import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/location_model.dart';
import 'package:superdriver/data/services/address_service.dart';
import 'package:superdriver/data/services/in_app_messaging_service.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  List<Governorate> _cachedGovernorates = [];
  List<AddressSummary> _cachedAddresses = [];

  AddressBloc() : super(const AddressInitial()) {
    on<AddressListRequested>(_onListRequested);
    on<AddressDetailRequested>(_onDetailRequested);
    on<AddressAddRequested>(_onAddRequested);
    on<AddressUpdateRequested>(_onUpdateRequested);
    on<AddressDeleteRequested>(_onDeleteRequested);
    on<AddressSetCurrentRequested>(_onSetCurrentRequested);
    on<CurrentAddressRequested>(_onCurrentAddressRequested);
    on<GovernoratesRequested>(_onGovernoratesRequested);
  }

  Future<void> _onGovernoratesRequested(
    GovernoratesRequested event,
    Emitter<AddressState> emit,
  ) async {
    if (_cachedGovernorates.isNotEmpty && !event.forceRefresh) {
      emit(GovernoratesLoaded(governorates: _cachedGovernorates));
      return;
    }

    emit(const GovernoratesLoading());
    try {
      final governorates = await addressService.getGovernorates();
      _cachedGovernorates = governorates;
      emit(GovernoratesLoaded(governorates: governorates));
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListRequested(
    AddressListRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final addresses = await addressService.getAllAddresses();
      _cachedAddresses = addresses;
      emit(AddressListLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    AddressDetailRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final address = await addressService.getAddressById(event.id);
      emit(AddressDetailLoaded(address: address));
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddRequested(
    AddressAddRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressOperationInProgress());
    try {
      final address = await addressService.addAddress(
        title: event.title,
        governorate: event.governorate,
        area: event.area,
        street: event.street,
        buildingNumber: event.buildingNumber,
        floor: event.floor,
        apartment: event.apartment,
        landmark: event.landmark,
        additionalNotes: event.additionalNotes,
        latitude: event.latitude,
        longitude: event.longitude,
        isCurrent: event.isCurrent,
      );

      inAppMessagingService.triggerEvent('address_added');
      _refreshAddressCache();
      emit(AddressAddSuccess(address: address));
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateRequested(
    AddressUpdateRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressOperationInProgress());
    try {
      final address = await addressService.updateAddress(
        id: event.id,
        title: event.title,
        governorate: event.governorate,
        area: event.area,
        street: event.street,
        buildingNumber: event.buildingNumber,
        floor: event.floor,
        apartment: event.apartment,
        landmark: event.landmark,
        additionalNotes: event.additionalNotes,
        latitude: event.latitude,
        longitude: event.longitude,
        isCurrent: event.isCurrent,
      );

      _refreshAddressCache();
      emit(AddressUpdateSuccess(address: address));
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteRequested(
    AddressDeleteRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressOperationInProgress());
    try {
      await addressService.deleteAddress(event.id);

      _refreshAddressCache();
      emit(const AddressDeleteSuccess());
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSetCurrentRequested(
    AddressSetCurrentRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressOperationInProgress());
    try {
      await addressService.setCurrentAddress(event.id);

      _refreshAddressCache();
      emit(const AddressSetCurrentSuccess());
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCurrentAddressRequested(
    CurrentAddressRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final address = await addressService.getCurrentAddress();
      if (address != null) {
        emit(CurrentAddressLoaded(address: address));
      } else {
        emit(const NoCurrentAddress());
      }
    } catch (e) {
      emit(AddressError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _refreshAddressCache() async {
    try {
      final addresses = await addressService.getAllAddresses();
      _cachedAddresses = addresses;
    } catch (e) {
      log('Failed to refresh address cache: $e');
    }
  }

  List<Governorate> get cachedGovernorates => _cachedGovernorates;
  List<AddressSummary> get cachedAddresses => _cachedAddresses;
}
