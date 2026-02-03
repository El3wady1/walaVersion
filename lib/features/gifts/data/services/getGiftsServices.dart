import 'package:dio/dio.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/features/gifts/data/model/giftsModel.dart';
import '../../../mission/data/services/getUserID.dart';
import 'dart:convert';

Future<GiftsModel> getGiftsServices() async {
  final dio = Dio();

  final departmentId = await getUserDepartmentId();

  if (departmentId == null || departmentId.isEmpty) {
    throw Exception("Department ID is null");
  }

  try {
    final response = await dio.post(
      Apiendpoints.baseUrl + Apiendpoints.rewards.getAllRewardsByDepIDandShown,
      data: {"departmentid": departmentId},
    );

    final responseData = response.data is String
        ? jsonDecode(response.data)
        : response.data;
print(responseData);
    return GiftsModel.fromJson(Map<String, dynamic>.from(responseData));

  } on DioException catch (e) {
    if (e.response != null) {
      print("STATUS: ${e.response!.statusCode}");
      print("DATA: ${e.response!.data}");
    } else {
      print("ERROR: ${e.message}");
    }
    rethrow;
  }
}
