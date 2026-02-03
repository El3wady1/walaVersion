import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/getuserSessionServices.dart';
import 'drawerState.dart';

class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(DrawerInitialState());

  Future<void> fetchDrawerUserData() async {
    emit(DrawerLoadingState());

    try {
      final data = await getUserSessionServices();

      if (data == null) {
        emit(DrawerFailState("لا توجد بيانات".tr()));
      } else {
        emit(DrawerLoaded(data));
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      print("Status Code: ${e.response?.statusCode}");

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(DrawerFailState("تفقد اتصالك بالانترنت".tr()));
      } else if (e.response?.statusCode == 401) {
        emit(DrawerFailState("انتهت صلاحية الجلسة".tr()));
      } else {
        emit(DrawerFailState("حدث خطأ في السيرفر".tr()));
      }
    } catch (e) {
      print("Unknown Error: $e");
      emit(DrawerFailState("حدث خطأ غير متوقع".tr()));
    }
  }
}
