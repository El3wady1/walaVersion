import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/getMissionDataByDepIdServices.dart' show getMissionDataByDepIdServices;
import 'missionState.dart';

class MissionCubit extends Cubit<MissionState> {
  MissionCubit() : super(IntialMissionState());

  fetchMission() async {
  if (isClosed) return;

  emit(LoadingMissionState());

  try {
    final data = await getMissionDataByDepIdServices();
    if (isClosed) return;
    emit(LoadedMissionState(data));
  } catch (e) {
    if (isClosed) return;
    emit(FailMissionState(e.toString()));
  }
}
refreshMission()async{
await fetchMission();
}

}
