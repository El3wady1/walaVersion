import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/controller/redeemHistoryCubit.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/redeemHistoryBodyView.dart';

class Redeemhistoryview extends StatelessWidget {
  const Redeemhistoryview({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
        create: (_) => Redeemhistorycubit()..fetchRedeemHistoryData(),

      child: Redeemhistorybodyview ());
  }
}