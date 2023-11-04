import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/bonus_manager.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:provider/provider.dart';

class Bank extends StatelessWidget {
  const Bank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 76.0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Beamer.of(context).beamBack();
                },
                icon: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
                )),
          ),
          title: AutoSizeText(
            'Банк',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.blue.shade900, Colors.blue.shade700]),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5), blurRadius: 10.0)
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      color: Colors.white,
                      size: 80.0,
                    ),
                    const SizedBox(height: 10.0),
                    AutoSizeText(
                      'MC Bank',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                children: [
                  buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.moneyBill,
                      buttonName: 'Взять кредит',
                      color: Theme.of(context).canvasColor,
                      onPressed: () {
                        context.beamToNamed('/loan-moneys');
                      }),
                  const SizedBox(height: 15.0),
                  buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.landmark,
                      buttonName: 'Заплатить налог',
                      color: Theme.of(context).canvasColor,
                      onPressed: () {
                        context.beamToNamed('/tax');
                      }),
                  const SizedBox(height: 15.0),
                  buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.moneyBillTransfer,
                      buttonName: 'Перевести игроку',
                      color: Theme.of(context).canvasColor,
                      onPressed: () {
                        context.beamToNamed('/transfer-moneys');
                      }),
                  const SizedBox(height: 15.0),
                  buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.moneyBill,
                      buttonName: 'Покупка игровой валюты',
                      color: Colors.blueAccent,
                      onPressed: () {
                        context.beamToNamed('/purchasing-game-currency');
                      }),
                  const SizedBox(height: 15.0),
                  Consumer<BonusManager>(
                    builder: (context, value, child) {
                      return value.isLoadingBonus
                          ? Container(
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.deepPurple.withOpacity(0.8),
                                        blurRadius: 5.0)
                                  ]),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(18.0),
                                  child: SizedBox(
                                    width: 26.0,
                                    height: 26.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : buttonModel(
                              context: context,
                              icon: FontAwesomeIcons.rectangleAd,
                              buttonName: 'Бесплатный бонус',
                              color: Colors.deepPurple,
                              onPressed: () {
                                value.getFreeBonus(context);
                              });
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
