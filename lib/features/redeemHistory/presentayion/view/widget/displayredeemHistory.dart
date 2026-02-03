import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/controller/redeemHistoryCubit.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/redeemHistoryCard.dart';
import '../../../../../core/utils/getLangState.dart';
import '../../../data/services/earnRedeemHistoryServices.dart' show EarnRedeemHistoryServices;
import '../../controller/redeemHistoryState.dart';

class Displayredeemhistory extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<Redeemhistorycubit>(context);

    return Expanded(
      child: BlocBuilder<Redeemhistorycubit, RedeemHistoryState>(
        builder: (context, state) {
          if (state is LoadingRedeemHstoryState) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: CardLoading(
                    cardLoadingTheme: CardLoadingTheme(
                      colorOne: AppColors.secondaryColor.withOpacity(0.3),
                      colorTwo: AppColors.secondaryColor.withOpacity(0.2),
                    ),
                    height: 80,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                );
              },
            );
          }

          if (state is LoadedRedeemHistoryState) {
            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async {
                context.read<Redeemhistorycubit>().fetchRedeemHistoryData();
              },
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 5),
                itemCount: state.redeemHistoryData.data.length,
                itemBuilder: (context, index) {
                  var redeemHistory = state.redeemHistoryData.data[index];
                  var langState = LocallizationHelper.get(context);
                  var text = redeemHistory.title ?? '';
                  String before = '';
                  String after = '';

                  if (text.contains("\n")) {
                    int i = text.indexOf('\n');
                    before = text.substring(0, i).trim();
                    after = text.substring(i + 1).trim();
                  } else {
                    before = after = text;
                  }

                  return RedeemHistoryCard(
                    giftName: langState != "en" ? before : after,
                    status: redeemHistory.status.toString(),
                    place: redeemHistory.place,
                    date: redeemHistory.createdAt!.toUtc(),
                    id: redeemHistory.trxId,
                    isDeducted: redeemHistory.rate,
                    istatus: redeemHistory.status.toString(),
                    points: redeemHistory.points,
                    iscolected: redeemHistory.collect,
                    onTap: () async {
                      print(redeemHistory.id);
                      await EarnRedeemHistoryServices(
                        wlaaHistoryId: redeemHistory.id, context: context,
                      );
                      context.read<Redeemhistorycubit>().fetchRedeemHistoryData();
                    },
                  );
                },
              ),
            );
          }

          if (state is FailureRedeemHistoryState) {
            return Center(
              child: Text(
                state.erorrMassage ?? "An error occurred.",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
