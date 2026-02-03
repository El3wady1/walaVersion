import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/managWala/presntation/controller/managewalaa_Cubit.dart';
import 'package:saladafactory/features/managWala/presntation/view/widget/managewalaaBodyView.dart';

class Managewalaaview extends StatelessWidget {
  const Managewalaaview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (BuildContext context) =>ManagewalaaCubit(),
    child: Managewalaabodyview());
  }
}