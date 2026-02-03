import 'package:flutter/material.dart';

class LocallizationHelper {
static  get<String>(BuildContext context){
      Locale locale = Localizations.localeOf(context);
return locale;
  }
}