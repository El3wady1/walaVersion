import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/features/pendingWalaa/%20model/walaaHistoryModel.dart';
import 'package:saladafactory/features/pendingWalaa/data/services/acceptgiftServices.dart';
import 'package:saladafactory/features/pendingWalaa/data/services/getPendingwalaaOrder.dart';
import 'package:saladafactory/features/pendingWalaa/presentation/controller/pendinngWalaaState.dart';

class PendinngwalaaCubit extends Cubit<PendinngwalaaState> {
  PendinngwalaaCubit() : super(IntialPendinngWalaaState());
  bool isloading = false;

  fetchPendingWalaaHistroy() async {
    emit(LoadingPendinngWalaaState());
    try {

      var pendings = await GetPendingwalaaOrder();

      if (pendings == null || pendings.isEmpty) {
        emit(FailurePendinngWalaaState("لا توجد بيانات".tr()));
      } else {
        emit(LoadedPendinngWalaaState(pendings));
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      print("Status Code: ${e.response?.statusCode}");

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(FailurePendinngWalaaState("تفقد اتصالك بالانترنت".tr()));
      } else if (e.response?.statusCode == 401) {
        emit(FailurePendinngWalaaState("انتهت صلاحية الجلسة".tr()));
      } else {
        emit(FailurePendinngWalaaState("حدث خطأ في السيرفر".tr()));
      }
    }
  }


}
