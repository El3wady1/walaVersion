import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/features/production/data/services/getLinkofPrintP_S.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

GotoProductionUrl(BuildContext context)async{
    String? productionPrintUrl;

  await GetLonkProductionS_P(context).then((v) {
    productionPrintUrl=v;
 });
    final Uri uri = Uri.parse(productionPrintUrl.toString());
    if (!await launchUrl(uri)) {
      showfalseSnackBar(context: context, message: "فشل في تحميل البيانات من السيرفر".tr(), icon: Icons.print_disabled);
    }
  
}