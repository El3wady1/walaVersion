import 'package:dio/dio.dart';
import 'package:saladafactory/features/pendingWalaa/%20model/walaaHistoryModel.dart';

import '../../../../core/utils/apiEndpoints.dart';

Future<dynamic> GetPendingwalaaOrder() async {
  final dio = Dio();

  final response = await dio.get(
    Apiendpoints.baseUrl + Apiendpoints.walaaHistory.getPending,
  );

  if (response.statusCode == 200) {
    dynamic data = response.data["data"];
    return data.map((pending) => WalaaHistoryModel.fromJson(pending)).toList();
  } else {
    throw ("erorr");
  }
}
