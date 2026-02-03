import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/mission/presentation/controller/missionCubit.dart';
import 'package:saladafactory/features/mission/presentation/view/widget/missionBodyView.dart';

class Missionview extends StatelessWidget {
  const Missionview({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocProvider(create: (BuildContext context) =>MissionCubit()..fetchMission(),
      child: MissionBodyView()),
    );
  }
}