import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/localls.dart';

import '../../../../core/utils/getLangState.dart';
import '../models/earnSevicesModel.dart';

Future EarnRedeemHistoryServices({
  required String wlaaHistoryId,
  required BuildContext context
}) async {
  final dio = Dio();
  var token;
await Localls.getToken().then((v)=>token=v);

  try {
    var earnModel= EarnModel(collect: true);
    final response = await dio.put(
      
      Apiendpoints.baseUrl+Apiendpoints.walaaHistory.Iscollect+wlaaHistoryId, 
      options: Options(
        headers: {
          "Authorization": "Bearer $token", 
        },
      ),
      data: earnModel.toJson(context: context)
    );

    if (response.statusCode == 200) {
      print("Success: ${response.data}");
    } else {
      print("Failed with status: ${response.statusCode}");
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print("Server Error: ${e.response?.data}");
    } else {
      print("Connection Error: ${e.message}");
    }
  } catch (e) {
    print("Unexpected Error: $e");
  }
}
