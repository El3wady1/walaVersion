import 'package:dio/dio.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:saladafactory/features/gifts/data/model/userData.dart';
import 'dart:convert';

import 'package:saladafactory/features/redeemHistory/data/models/avilablepointsModel.dart';
import 'package:saladafactory/features/redeemHistory/data/models/redeemHistoryModel.dart';

Future GetRedeemHistoryServices() async {
  final dio = Dio();
  try {
var token;
   await Localls.getToken().then((e)=>token=e);
    if(token==null){
      print(token.toString());
    }
          print("GetallUserData"+token.toString());

    final response = await dio.get(
      Apiendpoints.baseUrl + Apiendpoints.walaaHistory.getAlluserHistory,
      options: Options(headers: {
        "authorization":"Bearer $token"
      }),
    );

    final responseData = response.data is String
        ? jsonDecode(response.data)
        : response.data;
print(responseData);
final model = RedeemHistoryModel.fromJson(response.data);


    return model ;

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
