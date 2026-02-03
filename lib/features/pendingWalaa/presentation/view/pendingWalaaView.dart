import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/pendingWalaa/presentation/controller/pendinngWalaacubit.dart';
import 'package:saladafactory/features/pendingWalaa/presentation/view/widget/pendinngWalaaBodyView.dart';

class PendingwalaaView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (BuildContext context) { return PendinngwalaaCubit()..fetchPendingWalaaHistroy(); },
    child:  Pendinngwalaabodyview());
  }
}