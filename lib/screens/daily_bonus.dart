import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';

class DailyBonus extends StatelessWidget {
  const DailyBonus({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<DailyBonusManager>(builder: (context, value, child) {
        return value.isLoading
            ? loading(context: context)
            : Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 160.0,
                  centerTitle: true,
                  title: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Ежедневный\n',
                      style: Theme.of(context).textTheme.displayLarge,
                      children: [
                        TextSpan(
                            text: 'бонус',
                            style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ))),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        value.getBonus(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.gift,
                              color: Colors.white,
                              size: 22.0,
                            ),
                            const SizedBox(width: 10.0),
                            AutoSizeText(
                              'Забрать',
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      AccountController.isPremium
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: AutoSizeText(
                                'В Mini Casino Premium бонусы увеличены в 3 раза!',
                                maxLines: 1,
                                style: GoogleFonts.roboto(
                                    color: Colors.black54,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                      GridView.custom(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8),
                        childrenDelegate: SliverChildBuilderDelegate(
                            childCount: value.bonuses.length, (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                color:
                                    DailyBonusManager.currentBonusIndex == index
                                        ? Colors.green.withOpacity(0.1)
                                        : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    color:
                                        DailyBonusManager.currentBonusIndex ==
                                                index
                                            ? Colors.green
                                            : index <
                                                    DailyBonusManager
                                                        .currentBonusIndex
                                                ? Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .background
                                                    .withOpacity(0.8)
                                                : Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .background,
                                    width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.gift,
                                    color: index <
                                            DailyBonusManager.currentBonusIndex
                                        ? value.colors[index].withOpacity(0.6)
                                        : value.colors[index],
                                    size: 25.0,
                                  ),
                                  const SizedBox(height: 10.0),
                                  AutoSizeText(
                                    '+${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(value.bonuses[index] * (AccountController.isPremium ? 3 : 1))}',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: index <
                                                DailyBonusManager
                                                    .currentBonusIndex
                                            ? Colors.green.withOpacity(0.6)
                                            : Colors.green,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: AutoSizeText(
                                      DailyBonusManager.currentBonusIndex ==
                                              index
                                          ? 'Сегодня'
                                          : index <
                                                  DailyBonusManager
                                                      .currentBonusIndex
                                              ? 'Получен!'
                                              : DateFormat.MMMMd('ru_RU')
                                                  .format(DailyBonusManager
                                                      .firstBonusDate
                                                      .add(Duration(
                                                          days: index))),
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: index <
                                                      DailyBonusManager
                                                          .currentBonusIndex
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color!
                                                      .withOpacity(0.3)
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color!,
                                              fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
