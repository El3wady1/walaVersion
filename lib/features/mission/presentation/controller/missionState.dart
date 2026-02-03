import 'package:saladafactory/features/mission/data/model/missionModel.dart';

abstract class MissionState {}

class IntialMissionState extends MissionState {}

class LoadingMissionState extends MissionState {}

class LoadedMissionState extends MissionState {
  final List<MissionModel> missions;
  LoadedMissionState(this.missions);
}

class FailMissionState extends MissionState {
  final String error;
  FailMissionState(this.error);
}
