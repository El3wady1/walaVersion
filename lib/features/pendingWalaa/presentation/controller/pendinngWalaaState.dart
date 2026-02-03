import 'package:saladafactory/features/pendingWalaa/%20model/walaaHistoryModel.dart';

abstract class PendinngwalaaState {}

class IntialPendinngWalaaState extends PendinngwalaaState {}

class LoadingPendinngWalaaState extends PendinngwalaaState {}

class LoadedPendinngWalaaState extends PendinngwalaaState {
 List< dynamic >pendingWalaaData;
  LoadedPendinngWalaaState(this.pendingWalaaData);
}

class FailurePendinngWalaaState extends PendinngwalaaState {
  String erorrMassage;
  FailurePendinngWalaaState(this.erorrMassage);
}

class LoadingModulPendinngWalaaState extends PendinngwalaaState{}
class NotLoadingModulPendinngWalaaState extends PendinngwalaaState{}