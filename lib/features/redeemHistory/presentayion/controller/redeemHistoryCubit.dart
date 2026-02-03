import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/avilablepointsModel.dart';
import '../../data/services/getAvilablePointsServices.dart';
import '../../data/services/getAllRedeemHistoryServices.dart';
import 'redeemHistoryState.dart';

class Redeemhistorycubit extends Cubit<RedeemHistoryState> {
  Redeemhistorycubit() : super(IntialRedeemHistoryState()){
  //  Timer.periodic(Duration(seconds: 5), (_) => fetchAvailablePoints());
  }

  Timer? _timer;

  Future<void> fetchAvailablePoints() async {
    emit(LoadingAvilablePointsState());
    try {
      final CurrentPoints points = await GetAvilablePoints();
      emit(LoadedAvilablePointsState(points));
    } catch (e) {
      emit(FailureAvilablePointsState(e.toString()));
    }
  }

  Future<void> fetchRedeemHistoryData() async {
    emit(LoadingRedeemHstoryState());
    try {
      final redeemHistoryData = await GetRedeemHistoryServices();
      emit(LoadedRedeemHistoryState(redeemHistoryData,false));
    } catch (e) {
      emit(FailureRedeemHistoryState(e.toString()));
    }
  }

  Future<void> refreshRedeemHistory() async {
    await fetchAvailablePoints();
    await fetchRedeemHistoryData();
  }

void startAutoRefresh({int seconds = 30}) {
  _timer?.cancel();
  _timer = Timer.periodic(Duration(seconds: seconds), (timer) async {
    await refreshRedeemHistory(); // Use await
  });
}


  void stopAutoRefresh() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
