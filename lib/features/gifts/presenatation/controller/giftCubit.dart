import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/gifts/data/model/userData.dart';
import 'package:saladafactory/features/gifts/data/services/getGiftsServices.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftState.dart';
import '../../data/model/giftsModel.dart';
import '../../data/services/getallUserData.dart';
import '../view/widget/giftBodyView.dart';
import '../../../redeemHistory/presentayion/view/redeemHistoryView.dart';
import '../../../mission/presentation/view/missionView.dart';
class Giftcubit extends Cubit<GiftState> {
  Giftcubit() : super(GiftIntialState());

  Timer? _timer;
  bool _started = false;

  int selectedIndex = 0;
  bool isRedeeming = false;
    final List<Widget> screens = [
    Giftbodyview(),
    Redeemhistoryview(),
    Missionview(),
  ];

  // ================= Tabs =================
  void togglepages(var index) {
    selectedIndex = index;
    if (!isClosed) emit(ChangeToggleGiftState());
  }

  // ================= Auto Refresh =================
  void startAutoRefresh() {
    if (_started) return;
    _started = true;

    fetchUserData(); 

    _timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!isClosed) {
        await fetchUserData(silent: true); 
      }
    });
  }

  // ================= LoadingToggleRedeem =================

    Isloading(){
      isRedeeming=true;
      emit(LoadingRedeemState());
    }

    Notloading(){
         isRedeeming=false;
      emit(NotLoadingRedeemState());
    }


  // ================= User Data =================
  Future<void> fetchUserData({bool silent = false}) async {
    if (!silent && !isClosed) { 
      emit(LoadingUserDataState()); 
    }

    try {
      final UserResponseModel data = await GetallUserData();

      if (isClosed) return; 

      if (data.name.isEmpty) {
        if (!isClosed) emit(FailurUserDataState("لا توجد بيانات".tr()));
      } else {
        if (!isClosed) emit(LoadedUserDataState(data));
      }
    } catch (e) {
      if (isClosed) return;

      if (!isClosed) emit(FailurUserDataState("تحقق من اتصالك بالإنترنت".tr()));
    }
  }

  // ================= Gifts =================
  Future<void> fetuchGifts() async {
    if (!isClosed) emit(LoadingGiftState());

    try {
      final GiftsModel data = await getGiftsServices();
      if (isClosed) return;

      if (data.data.isEmpty) {
        if (!isClosed) emit(FailurGiftState("لا توجد بيانات".tr()));
      } else {
        if (!isClosed) emit(LoadedGiftState(data));
      }
    } catch (e) {
      if (isClosed) return;

      if (e.toString().toLowerCase().contains("socket") ||
          e.toString().toLowerCase().contains("connect")) {
        if (!isClosed) emit(FailurGiftState("تحقق من اتصالك بالإنترنت".tr()));
      } else {
        print(e.toString());
        if (!isClosed) emit(FailurGiftState(e.toString()));
      }
    }
  }

  // ================= Dispose =================
  @override
  Future<void> close() {
    _timer?.cancel(); 
    return super.close();
  }
}
