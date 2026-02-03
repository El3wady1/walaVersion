import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/givePoints/presntattion/view/givePointsView.dart';
import 'package:saladafactory/features/managWala/presntation/controller/managewalaa_State.dart';

import '../../../pendingWalaa/presentation/view/pendingWalaaView.dart';

class ManagewalaaCubit extends Cubit<ManagewalaaState> {

ManagewalaaCubit():super(IntialManagewalaaState());
  int selectedIndex = 0;

  List<Widget> screens=[
        PendingwalaaView()
,
    Givepointsview(),
  ];
  void togglepages(var index) {
    selectedIndex = index;
    if (!isClosed) emit(ChangeToggleManagewalaaCubitState());
  }

}