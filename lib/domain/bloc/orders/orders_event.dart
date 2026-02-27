part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoadRequested extends OrdersEvent {
  const OrdersLoadRequested();
}

class OrdersActiveLoadRequested extends OrdersEvent {
  const OrdersActiveLoadRequested();
}

class OrdersHistoryLoadRequested extends OrdersEvent {
  const OrdersHistoryLoadRequested();
}

class OrderDetailsLoadRequested extends OrdersEvent {
  final int orderId;

  const OrderDetailsLoadRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCreateRequested extends OrdersEvent {
  final int cartId;
  final int deliveryAddressId;
  final String paymentMethod;
  final String? contactPhone;
  final DateTime? scheduledDeliveryTime;
  final String? notes;

  const OrderCreateRequested({
    required this.cartId,
    required this.deliveryAddressId,
    this.paymentMethod = 'cash',
    this.contactPhone,
    this.scheduledDeliveryTime,
    this.notes,
  });

  @override
  List<Object?> get props => [
    cartId,
    deliveryAddressId,
    paymentMethod,
    contactPhone,
    scheduledDeliveryTime,
    notes,
  ];
}

class OrderPlaceRequested extends OrdersEvent {
  final int orderId;

  const OrderPlaceRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCancelRequested extends OrdersEvent {
  final int orderId;
  final String reason;

  const OrderCancelRequested({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class OrderReorderRequested extends OrdersEvent {
  final int orderId;

  const OrderReorderRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderTrackRequested extends OrdersEvent {
  final int orderId;

  const OrderTrackRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrdersRefreshRequested extends OrdersEvent {
  const OrdersRefreshRequested();
}
