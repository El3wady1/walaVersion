import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/availablePoints.dart';

import '../../controller/redeemHistoryCubit.dart';
import '../../controller/redeemHistoryState.dart';

class Displayhistoryredeemcard extends StatelessWidget {
  const Displayhistoryredeemcard({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<Redeemhistorycubit, RedeemHistoryState>(
      builder: (context, state) {
        if (state is LoadingAvilablePointsState) {
          return Center(
            child: CardLoading(
              borderRadius: BorderRadius.circular(10),
              cardLoadingTheme: CardLoadingTheme(
                colorOne: AppColors.secondaryColor.withOpacity(0.3),
                colorTwo:AppColors.secondaryColor.withOpacity(0.2),
              ),
              height: 50,
            ),
          );
        }
        if (state is LoadedAvilablePointsState) {
          return Availablepoints(
            avilablepoints: state.redeemHistoryData.currentPoints
                .toString(),
                
          );
        }
        if (state is FailureAvilablePointsState) {
          return Text("");
        }
            
        return SizedBox();
      },
    )
    
    
          ;
  }
}