// lib/domain/bloc/address/address_state.dart

part of 'address_bloc.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class GovernoratesLoading extends AddressState {
  const GovernoratesLoading();
}

class GovernoratesLoaded extends AddressState {
  final List<Governorate> governorates;

  const GovernoratesLoaded({required this.governorates});

  @override
  List<Object?> get props => [governorates];
}

class AddressListLoaded extends AddressState {
  final List<AddressSummary> addresses;

  const AddressListLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

class AddressDetailLoaded extends AddressState {
  final Address address;

  const AddressDetailLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}

class CurrentAddressLoaded extends AddressState {
  final Address address;

  const CurrentAddressLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}

class NoCurrentAddress extends AddressState {
  const NoCurrentAddress();
}

class AddressOperationInProgress extends AddressState {
  const AddressOperationInProgress();
}

class AddressAddSuccess extends AddressState {
  final Address address;

  const AddressAddSuccess({required this.address});

  @override
  List<Object?> get props => [address];
}

class AddressUpdateSuccess extends AddressState {
  final Address address;

  const AddressUpdateSuccess({required this.address});

  @override
  List<Object?> get props => [address];
}

class AddressDeleteSuccess extends AddressState {
  const AddressDeleteSuccess();
}

class AddressSetCurrentSuccess extends AddressState {
  const AddressSetCurrentSuccess();
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
