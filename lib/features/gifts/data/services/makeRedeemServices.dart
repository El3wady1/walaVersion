import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/core/utils/Strings.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/localls.dart';

import '../../../../core/utils/alertOrder.dart';
import 'package:dio/dio.dart';

import '../../../../core/utils/getLangState.dart';

Future<Map<String, dynamic>> MakeRedeemServices({
  required String productId,
  required double points,
  required BuildContext context
}) async {
  final dio = Dio();
  var token = await Localls.getToken();
        var langState = LocallizationHelper.get(context);

  try {
    final response = await dio.post(
      Apiendpoints.baseUrl + Apiendpoints.walaaHistory.add,
      options: Options(headers: {"authorization": "Bearer $token"}),
      data: {
        "title": productId,
        "status": Strings.pending,
        "points": points,
        "place": "r",
        "rate": "-",
        "collect": true,
            "language":langState.languageCode

      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "trxId": response.data["data"]["trxId"],
      };
    } else {
      return {"success": false};
    }
  } catch (e) {
    print(e);
    return {"success": false};
  }
}
