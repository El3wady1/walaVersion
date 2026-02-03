import '../../data/model/userSessionModel.dart';

abstract class DrawerState {}

class DrawerInitialState extends DrawerState {}

class DrawerLoadingState extends DrawerState {}

class DrawerLoaded extends DrawerState {
  final UserModel userData;
  DrawerLoaded(this.userData);
}

class DrawerFailState extends DrawerState {
  final String errorMessage;
  DrawerFailState(this.errorMessage);
}
