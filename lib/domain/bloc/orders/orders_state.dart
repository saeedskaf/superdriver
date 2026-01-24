part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<Order> activeOrders;
  final List<Order> historyOrders;

  const OrdersLoaded({
    required this.activeOrders,
    required this.historyOrders,
  });

  List<Order> get completedOrders =>
      historyOrders.where((o) => o.isCompleted).toList();

  List<Order> get cancelledOrders =>
      historyOrders.where((o) => o.isCancelled).toList();

  @override
  List<Object?> get props => [activeOrders, historyOrders];
}

class OrdersEmpty extends OrdersState {
  const OrdersEmpty();
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderDetailsLoading extends OrdersState {
  const OrderDetailsLoading();
}

class OrderDetailsLoaded extends OrdersState {
  final Order order;

  const OrderDetailsLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailsError extends OrdersState {
  final String message;

  const OrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCreating extends OrdersState {
  const OrderCreating();
}

class OrderCreated extends OrdersState {
  final Order order;

  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCreateError extends OrdersState {
  final String message;

  const OrderCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderPlacing extends OrdersState {
  const OrderPlacing();
}

class OrderPlaced extends OrdersState {
  final Order order;

  const OrderPlaced({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderPlaceError extends OrdersState {
  final String message;

  const OrderPlaceError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCancelling extends OrdersState {
  const OrderCancelling();
}

class OrderCancelled extends OrdersState {
  final Order order;

  const OrderCancelled({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCancelError extends OrdersState {
  final String message;

  const OrderCancelError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderReordering extends OrdersState {
  const OrderReordering();
}

class OrderReordered extends OrdersState {
  final Order order;

  const OrderReordered({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderReorderError extends OrdersState {
  final String message;

  const OrderReorderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderTracking extends OrdersState {
  final Order order;

  const OrderTracking({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderTrackError extends OrdersState {
  final String message;

  const OrderTrackError(this.message);

  @override
  List<Object?> get props => [message];
}
