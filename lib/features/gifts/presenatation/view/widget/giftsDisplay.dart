import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:card_loading/card_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/core/Widgets/awesomedialog.dart';
import 'package:saladafactory/core/utils/app_router.dart';
import 'package:saladafactory/features/gifts/data/services/makeRedeemServices.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/redeemCard.dart'
    show Redeemcard;
import 'package:saladafactory/features/login/presentation/view/widget/loginBodyView.dart';

import '../../../../../core/utils/alertOrder.dart';
import '../../../../../core/utils/getLangState.dart';
import '../../controller/giftCubit.dart';
import '../../controller/giftState.dart';

class Giftsdisplay extends StatefulWidget {
  final double currentpoints;
  const Giftsdisplay({required this.currentpoints, super.key});

  @override
  State<Giftsdisplay> createState() => _GiftsdisplayState();
}

class _GiftsdisplayState extends State<Giftsdisplay> {
  bool isloading = false;
  final Color primaryColor = Color(0xFF74826A);
  final Color accentColor = Color(0xFFEDBE2C);
  final Color secondaryColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocProvider(
        create: (context) => Giftcubit()..fetuchGifts(),
        child: BlocBuilder<Giftcubit, GiftState>(
          builder: (context, state) {
            var cubit = BlocProvider.of<Giftcubit>(context);

            Widget gridContent() {
              if (state is LoadingGiftState) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: .8,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: CardLoading(
                        cardLoadingTheme: CardLoadingTheme(
                          colorOne: secondaryColor.withOpacity(0.3),
                          colorTwo: secondaryColor.withOpacity(0.2),
                        ),
                        height: 55,
                        width: 120,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is LoadedGiftState) {
                print(state.gifts.data.toString());
                if (state.gifts.data.isEmpty) {
                  return Center(child: Text("لا توجد بيانات".tr()));
                }
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    await cubit.fetuchGifts();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: .62,
                        ),
                    itemCount: state.gifts.data.length,
                    itemBuilder: (context, index) {
                      var gift = state.gifts.data[index];
                      final points = gift.categories.isNotEmpty
                          ? gift.categories.first.points
                          : 0;
                      var trxId;
                      var langState = LocallizationHelper.get(context);
                      var text = gift.title;
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
                      return Redeemcard(
                        name: langState.toString() != "en" ? b : f,
                        desc: gift.description,
                        pointToReedem: points.toString(),
                        redeemPhoto: gift.image,
                        onTap: () async {
                          setState(() => isloading = true);
                          await MakeRedeemServices(
                            productId: gift.id,
                            points: points.toDouble(), context: context,
                          ).then((e) => trxId = e["trxId"]);
                          if (trxId == null) {
                            CustomAwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              title: "فشلت العمليه".tr(),
                              desc: "",
                            );
                          }
                          if (trxId != null) {
                            showFullScreenOrderConfirmationDialog(
                              context: context,
                              title: "تم إرسال طلبك".tr(),
                              message: "سيتم مراجعة الطلب ثم التواصل معك".tr(),
                              orderNumber: trxId,
                              autoCloseSeconds: 5,
                              onClose: () {
                                print("Dialog closed");
                              },
                            );
                          }

                          setState(() => isloading = false);
                        },
                        lockedRedeemBtn: widget.currentpoints < points,
                        isloadingbtn: isloading,
                      );
                    },
                  ),
                );
              }

              if (state is FailurGiftState) {
                return Center(child: Text(state.erorrMassage));
              }

              return SizedBox();
            }

            return Stack(children: [gridContent()]);
          },
        ),
      ),
    );
  }
}
