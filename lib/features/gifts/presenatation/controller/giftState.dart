import 'package:saladafactory/features/gifts/data/model/giftsModel.dart';
import 'package:saladafactory/features/gifts/data/model/userData.dart';

abstract class GiftState {}

class GiftIntialState extends GiftState {}

class ChangeToggleGiftState extends GiftState {}

class LoadingGiftState extends GiftState {}

class LoadedGiftState extends GiftState {
  final GiftsModel gifts;
  LoadedGiftState(this.gifts);
}

class FailurGiftState extends GiftState {
  final String erorrMassage;
  FailurGiftState(this.erorrMassage);
}

class LoadingUserDataState extends GiftState {}

class LoadedUserDataState extends GiftState {
  UserResponseModel userData;
  LoadedUserDataState(this.userData);
}

class FailurUserDataState extends GiftState {
  final String erorrMassage;
  FailurUserDataState(this.erorrMassage);
}

class LoadingRedeemState extends GiftState {}

class NotLoadingRedeemState extends GiftState {}
