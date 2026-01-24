import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/domain/services/order_services.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  List<Order> _activeOrders = [];
  List<Order> _historyOrders = [];

  OrdersBloc() : super(const OrdersInitial()) {
    on<OrdersLoadRequested>(_onOrdersLoadRequested);
    on<OrdersActiveLoadRequested>(_onActiveOrdersLoadRequested);
    on<OrdersHistoryLoadRequested>(_onHistoryOrdersLoadRequested);
    on<OrderDetailsLoadRequested>(_onOrderDetailsLoadRequested);
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<OrderPlaceRequested>(_onOrderPlaceRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<OrderReorderRequested>(_onOrderReorderRequested);
    on<OrderTrackRequested>(_onOrderTrackRequested);
    on<OrdersRefreshRequested>(_onOrdersRefreshRequested);
  }

  List<Order> get activeOrders => _activeOrders;
  List<Order> get historyOrders => _historyOrders;

  Future<void> _onOrdersLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final activeOrders = await orderServices.getActiveOrders();
      final historyOrders = await orderServices.getOrdersHistory();

      _activeOrders = activeOrders;
      _historyOrders = historyOrders;

      if (activeOrders.isEmpty && historyOrders.isEmpty) {
        emit(const OrdersEmpty());
      } else {
        emit(OrdersLoaded(
          activeOrders: activeOrders,
          historyOrders: historyOrders,
        ));
      }
    } catch (e) {
      emit(OrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onActiveOrdersLoadRequested(
    OrdersActiveLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final activeOrders = await orderServices.getActiveOrders();
      _activeOrders = activeOrders;

      emit(OrdersLoaded(
        activeOrders: activeOrders,
        historyOrders: _historyOrders,
      ));
    } catch (e) {
      emit(OrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onHistoryOrdersLoadRequested(
    OrdersHistoryLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final historyOrders = await orderServices.getOrdersHistory();
      _historyOrders = historyOrders;

      emit(OrdersLoaded(
        activeOrders: _activeOrders,
        historyOrders: historyOrders,
      ));
    } catch (e) {
      emit(OrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderDetailsLoadRequested(
    OrderDetailsLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderDetailsLoading());
    try {
      final order = await orderServices.getOrderDetails(event.orderId);
      emit(OrderDetailsLoaded(order: order));
    } catch (e) {
      emit(OrderDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderCreating());
    try {
      final request = CreateOrderRequest(
        deliveryAddressId: event.deliveryAddressId,
        paymentMethod: event.paymentMethod,
        notes: event.notes,
      );

      final order = await orderServices.createOrder(request);
      emit(OrderCreated(order: order));
    } catch (e) {
      emit(OrderCreateError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderPlaceRequested(
    OrderPlaceRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderPlacing());
    try {
      final order = await orderServices.placeOrder(event.orderId);
      emit(OrderPlaced(order: order));
    } catch (e) {
      emit(OrderPlaceError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderCancelling());
    try {
      final order = await orderServices.cancelOrder(
        orderId: event.orderId,
        reason: event.reason,
      );
      emit(OrderCancelled(order: order));
    } catch (e) {
      emit(OrderCancelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderReorderRequested(
    OrderReorderRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderReordering());
    try {
      final order = await orderServices.reorder(event.orderId);
      emit(OrderReordered(order: order));
    } catch (e) {
      emit(OrderReorderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrderTrackRequested(
    OrderTrackRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final order = await orderServices.trackOrder(event.orderId);
      emit(OrderTracking(order: order));
    } catch (e) {
      emit(OrderTrackError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOrdersRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final activeOrders = await orderServices.getActiveOrders();
      final historyOrders = await orderServices.getOrdersHistory();

      _activeOrders = activeOrders;
      _historyOrders = historyOrders;

      emit(OrdersLoaded(
        activeOrders: activeOrders,
        historyOrders: historyOrders,
      ));
    } catch (e) {
      emit(OrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
