import 'package:flutter/material.dart';
import 'package:saladafactory/features/production/presentation/view/widget/productionBodyView.dart';

class Productionview extends StatelessWidget {
var numberofBranchPRequest;
var numberofBranchSRequest;
  var role;
   Productionview({required this.role,required this.numberofBranchPRequest,required this.numberofBranchSRequest});

  @override
  Widget build(BuildContext context) {
    return ProductionBodyView(role: role, numberofBranchPRequest: numberofBranchPRequest, numberofBranchSRequest: numberofBranchSRequest,);
  }
}