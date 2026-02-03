import '../../data/models/redeemHistoryModel.dart';

abstract class RedeemHistoryState {}

class IntialRedeemHistoryState extends RedeemHistoryState{}

class LoadingAvilablePointsState extends RedeemHistoryState{}
class LoadedAvilablePointsState extends RedeemHistoryState{
  var redeemHistoryData;
  LoadedAvilablePointsState(this.redeemHistoryData);
}
class FailureAvilablePointsState extends RedeemHistoryState{
  String erorrMassage;
  FailureAvilablePointsState(this.erorrMassage);
}



class LoadingRedeemHstoryState extends RedeemHistoryState{}
class LoadedRedeemHistoryState extends RedeemHistoryState{
  RedeemHistoryModel redeemHistoryData;
  bool loading;
  LoadedRedeemHistoryState(this.redeemHistoryData,this.loading);
}

class FailureRedeemHistoryState extends RedeemHistoryState{
  String erorrMassage;
  FailureRedeemHistoryState(this.erorrMassage);
}
class RefreshState extends RedeemHistoryState{}

class RebuildRedeemHistoryState extends RedeemHistoryState{}