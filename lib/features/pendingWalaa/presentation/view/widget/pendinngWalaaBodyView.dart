import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'package:saladafactory/core/utils/assets.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/pendingWalaa/data/services/rejectGiftServices.dart';
import 'package:saladafactory/features/pendingWalaa/presentation/controller/pendinngWalaaState.dart';
import 'package:saladafactory/features/pendingWalaa/presentation/view/widget/pendingCard.dart'
    show Pendingcard;

import '../../../../../core/utils/getLangState.dart';
import '../../../data/services/acceptgiftServices.dart';
import '../../../data/services/dateFormat.dart';
import '../../../data/services/getPendingwalaaOrder.dart';
import '../../controller/pendinngWalaacubit.dart';

class Pendinngwalaabodyview extends StatelessWidget {
  const Pendinngwalaabodyview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendinngwalaaCubit, PendinngwalaaState>(
      builder: (context, state) {
        if (state is LoadingPendinngWalaaState) {
          return Center(child: Loadingwidget());
        }
        if (state is LoadedPendinngWalaaState) {
          var pendings = state.pendingWalaaData;
          return BlocConsumer<PendinngwalaaCubit,PendinngwalaaState>(
            builder: (BuildContext context, state2) {
var cubit=BlocProvider.of<PendinngwalaaCubit>(context);
            return   RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async{await context
                                .read<PendinngwalaaCubit>()
                                .fetchPendingWalaaHistroy(); },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Pending Transactions".tr() + " (${pendings.length})",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                                  Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: pendings.length,
                        itemBuilder: (context, index) {
                          final transaction = pendings[index];
                
                          var title = transaction.title.toString() ?? '';
                          final points = transaction.points ?? 0;
                          final userName = transaction.user.name ?? '';
                          final trxId = transaction.trxId ?? '';
                          final createdAt = transaction.createdAt ?? '';
                          final status = transaction.status ?? '';
                          var langState = LocallizationHelper.get(context);
                             var text = transaction.title;
                  var b;
                  var f;
                  if(text.toString().contains("\n")){
                      int i = text.indexOf('\n');

                  String before = text.substring(0, i);
                  String after = text.substring(i + 1).trim();
                  b=before;
                  f=after;
                  }else{
                    b=f=text.toString();
                  }
                          return Pendingcard(
                            title: langState.toString() != "en" ? b : f,
                            points: points,
                            userName: userName,
                            status: status,
                            trxId: trxId,
                            createdAt: createdAt.toString(),
                            onAccept: () async {
                           try{
                             await AcceptGiftServices(
                                Walaaid: transaction.id, context: context,
                              );
                           }  catch(e){}
                              context
                                  .read<PendinngwalaaCubit>()
                                  .fetchPendingWalaaHistroy();
                            },
                            onReject: () async {
                              await RejectGiftServices(
                                Walaaid: transaction.id, context: context,
                              );
                           await   context
                                  .read<PendinngwalaaCubit>()
                                  .fetchPendingWalaaHistroy();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
            );
     
             }, listener: (BuildContext context, state) {  },
                );
        }
        return Center(
          child: SizedBox(child: Text(
          ""
          )),
        );
      },
    );
  }
}
