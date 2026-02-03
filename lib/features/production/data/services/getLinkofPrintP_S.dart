import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';

Future GetLonkProductionS_P(
  BuildContext context
)async{
final dio =Dio();

var res = await dio.get(Apiendpoints.baseUrl+Apiendpoints.settings.getUrlPrintPageofSP);

try{
  if(res.statusCode==200){
    print(res.data["data"]["des"]);
return res.data["data"]["des"];
}else {
  showfalseSnackBar(context: context, message:  "فشل في تحميل البيانات من السيرفر".tr(), icon: Icons.sync_problem);

}
}catch(e){
  showfalseSnackBar(context: context, message: e.toString(), icon: Icons.sync_problem);
}

}