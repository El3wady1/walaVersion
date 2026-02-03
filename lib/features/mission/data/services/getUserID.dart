import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/apiEndpoints.dart';
import '../../../../core/utils/localls.dart';

Future<String?> getUserDepartmentId() async {
  final url = Apiendpoints.baseUrl + Apiendpoints.auth.userData;
  final dio = Dio();

  final token = await Localls.getToken();
  print("TOKEN => $token");

  try {
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      if (data["department"] != null && data["department"].isNotEmpty) {
        final deptId = data["department"][0]["_id"];

        await Localls.setdepatmentid(depatmentid: deptId);
        return deptId;
      } else {
        throw Exception("لا يوجد Department للمستخدم");
      }
    } else {
      throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
    }
  } catch (e) {
    print("حدث خطأ: $e");
    return null;
  }
}

