part of 'navigation_bloc.dart';

class NavigationState extends Equatable {
  final int selectedIndex;

  const NavigationState({this.selectedIndex = 0});

  @override
  List<Object> get props => [selectedIndex];
}
