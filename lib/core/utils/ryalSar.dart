import 'package:flutter/material.dart';
import 'package:saladafactory/core/utils/assets.dart';

class Ryalsar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,right: 8),
      child: Image.asset(AssetIcons.saudi_Riyal,width: 13,height: 13,),
    );
  }
}