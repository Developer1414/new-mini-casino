import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';

class Mines extends StatelessWidget {
  const Mines({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        return !context.read<MinesLogic>().isGameOn;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Container(
              height: 188.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                  ]),
              child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Consumer<MinesLogic>(
                          builder: (ctx, minesLogic, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                          'Прибыль (${minesLogic.currentCoefficient.isNaN ? '0.00' : minesLogic.currentCoefficient.toStringAsFixed(2)}x):',
                                          style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                          )),
                                      AutoSizeText(
                                          minesLogic.profit < 1000000
                                              ? NumberFormat.simpleCurrency(
                                                      locale: ui
                                                          .Platform.localeName)
                                                  .format(minesLogic.profit)
                                              : NumberFormat
                                                      .compactSimpleCurrency(
                                                          locale: ui.Platform
                                                              .localeName)
                                                  .format(minesLogic.profit),
                                          style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                          )),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText('Кол. мин:',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        )),
                                    AutoSizeText(
                                        minesLogic.sliderValue
                                            .round()
                                            .toString(),
                                        style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        )),
                                  ],
                                ),
                                Slider(
                                  value: minesLogic.sliderValue,
                                  max: 24,
                                  min: 1,
                                  divisions: 23,
                                  onChanged: (double value) {
                                    if (minesLogic.isGameOn) return;
                                    minesLogic.changeSliderValue(value);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Consumer<MinesLogic>(builder: (ctx, minesLogic, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: !minesLogic.isGameOn
                                    ? null
                                    : () {
                                        minesLogic.autoMove();
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  backgroundColor: Colors.blueAccent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0)),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: AutoSizeText(
                                    'АВТО',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!minesLogic.isGameOn) {
                                    if (balance.currentBalance <
                                        double.parse(betFormatter
                                            .getUnformattedValue()
                                            .toString())) {
                                      return;
                                    }

                                    minesLogic.startGame(
                                        context: context,
                                        bet: double.parse(betFormatter
                                            .getUnformattedValue()
                                            .toString()));
                                  } else {
                                    minesLogic.cashout();
                                  }
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
                                  child: AutoSizeText(
                                    !minesLogic.isGameOn ? 'СТАВКА' : 'ЗАБРАТЬ',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  )),
            ),
            appBar: AppBar(
              toolbarHeight: 76.0,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: IconButton(
                    splashRadius: 25.0,
                    padding: EdgeInsets.zero,
                    onPressed: context.watch<MinesLogic>().isGameOn
                        ? null
                        : () {
                            Beamer.of(context).beamBack();
                          },
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Mines',
                    style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Consumer<Balance>(
                    builder: (context, value, _) {
                      return AutoSizeText(
                        value.currentBalanceString,
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900),
                      );
                    },
                  )
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: context.watch<MinesLogic>().isGameOn
                          ? null
                          : () {
                              context.beamToNamed('/game-statistic/mines');
                            },
                      icon: const FaIcon(
                        FontAwesomeIcons.circleInfo,
                        color: Colors.black87,
                        size: 30.0,
                      )),
                ),
              ],
            ),
            body: Consumer<MinesLogic>(builder: (ctx, minesLogic, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15.0),
                    child: customTextField(
                        context: context,
                        currencyTextInputFormatter: betFormatter,
                        textInputFormatter: betFormatter,
                        keyboardType: TextInputType.number,
                        readOnly: minesLogic.isGameOn,
                        isBetInput: true,
                        controller: betController,
                        hintText: 'Ставка...'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: GridView.custom(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverWovenGridDelegate.count(
                            crossAxisCount: 5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            pattern: const [
                              WovenGridTile(1),
                              WovenGridTile(
                                7 / 7,
                                crossAxisRatio: 1,
                                alignment: AlignmentDirectional.centerEnd,
                              ),
                            ],
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                            childCount: 25,
                            (context, index) => ElevatedButton(
                              onPressed: () {
                                minesLogic.checkItem(index);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor:
                                    setItemColor(minesLogic, index),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: !minesLogic.isGameOn
                                  ? minesLogic.minesIndex.isNotEmpty
                                      ? Image(
                                          image: AssetImage(
                                              'assets/mines/${!minesLogic.minesIndex.contains(index) ? 'brilliant' : 'bomb'}.png'),
                                        )
                                      : Container()
                                  : minesLogic.openedIndexes.contains(index)
                                      ? Image(
                                          image: AssetImage(
                                              'assets/mines/${!minesLogic.minesIndex.contains(index) ? 'brilliant' : 'bomb'}.png'),
                                        )
                                      : Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Color setItemColor(MinesLogic minesLogic, int index) {
    if (minesLogic.minesIndex.isNotEmpty) {
      if (minesLogic.openedIndexes.contains(index)) {
        if (!minesLogic.minesIndex.contains(index)) {
          return Colors.blueAccent.shade100;
        } else {
          return Colors.redAccent.shade100;
        }
      } else {
        return Colors.grey.shade300;
      }
    } else {
      return Colors.grey.shade300;
    }
  }
}
