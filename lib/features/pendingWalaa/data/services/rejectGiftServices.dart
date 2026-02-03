import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';

import '../../../../core/utils/getLangState.dart';
Future RejectGiftServices({
  required String Walaaid,
  required BuildContext context
}) async {
  try {
    final dio = Dio();
    var langState = LocallizationHelper.get(context);

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));

    final response = await dio.put(
      '${Apiendpoints.baseUrl}${Apiendpoints.walaaHistory.refusegift}$Walaaid',
      data: {
        "rate": "+",
        "status": "cancel",
        "language": langState.languageCode
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status! < 500, // يسمح لنا بالتعامل مع 400
      ),
    );

    print('Status code: ${response.statusCode}');
    print('Response data: ${response.data}');
    
  } catch (e) {
    print('Error: $e');
  }
}
