import 'package:dio/dio.dart';

import '../../../../core/utils/apiEndpoints.dart';
import '../../../../core/utils/localls.dart';
import '../model/userSessionModel.dart';

Future<UserModel?> getUserSessionServices() async {
  final dio = Dio();
  final token = await Localls.getToken();

  print("TOKEN = $token");

  try {
    final response = await dio.get(
      Apiendpoints.baseUrl + Apiendpoints.auth.userData,
      options: Options(headers: {"authorization": "Bearer $token"}),
    );

    print("RESPONSE = ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // لو عندك data داخل object
      if (response.data is Map && response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      } else {
        return UserModel.fromJson(response.data);
      }
    } else {
      return null;
    }
  } on DioException catch (e) {
    throw e;
  }
}
