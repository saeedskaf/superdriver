import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToTab>(_onNavigateToTab);
  }

  void _onNavigateToTab(NavigateToTab event, Emitter<NavigationState> emit) {
    emit(NavigationState(selectedIndex: event.tabIndex));
  }
}
