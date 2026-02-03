import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';

import '../../../../core/utils/getLangState.dart';

Future AcceptGiftServices({
  required String Walaaid,
  required BuildContext context,
}) async {
  try {
    final dio = Dio();
    var langState = LocallizationHelper.get(context);

    final response = await dio.put(
      Apiendpoints.baseUrl + Apiendpoints.walaaHistory.acceptgift + Walaaid,
      data: {
        "rate": "-",
        "status": "compelete",
        "language": langState.languageCode,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Success: ${response.data}');
    } else {
      print('Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
