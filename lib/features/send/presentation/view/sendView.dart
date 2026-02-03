import 'package:flutter/material.dart';
import 'package:saladafactory/features/send/presentation/view/widget/sendBodyView.dart';

class Sendview extends StatelessWidget {
  var numberofBranchPRequest;
var numberofBranchSRequest;
Sendview({required this.numberofBranchPRequest,required this.numberofBranchSRequest});
  @override
  Widget build(BuildContext context) {
    return Sendbodyview(role: 'admin', numberofBranchPRequest: numberofBranchPRequest, numberofBranchSRequest: numberofBranchSRequest,);
  }
}