part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToTab extends NavigationEvent {
  final int tabIndex;

  const NavigateToTab(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}
