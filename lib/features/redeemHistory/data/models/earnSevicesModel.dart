import 'package:flutter/material.dart';

import '../../../../core/utils/getLangState.dart';

class EarnModel {
  final bool collect;

  EarnModel({required this.collect});

  Map<String, dynamic> toJson({required  BuildContext context}) {
        var langState = LocallizationHelper.get(context);

    return {
      "collect": collect,
            "language":langState.languageCode

    };
  }
}
