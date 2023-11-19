import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Keno extends StatelessWidget {
  const Keno({super.key});

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
        return !context.read<KenoLogic>().isGameOn;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Container(
            height: 237.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                ]),
            child: Consumer<KenoLogic>(
              builder: (ctx, kenoLogic, _) {
                return Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                  'Прибыль (${kenoLogic.coefficient.toStringAsFixed(2)}x):',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 20.0)),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: AutoSizeText(
                                    kenoLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(kenoLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(kenoLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 20.0)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: kenoLogic.coefficients.isEmpty
                                ? Center(
                                    child: AutoSizeText(
                                      'Коэффициентов пока нет',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: kenoLogic.coefficients.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 10.0),
                                    itemBuilder: (context, index) {
                                      return Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: index ==
                                                      kenoLogic
                                                              .currentCoefficient -
                                                          1
                                                  ? Border.all(
                                                      width: 2.0,
                                                      color: Colors.green)
                                                  : null,
                                              color: Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme!
                                                  .background,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1.0,
                                                    blurRadius: 5.0)
                                              ],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(15.0))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${kenoLogic.coefficients[index]}x',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ),
                                        ),
                                      );
                                    }),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    kenoLogic.getRandomNumbers();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.dice,
                                        color: Colors.white,
                                        size: 23.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      AutoSizeText(
                                        'РАНДОМ',
                                        maxLines: 1,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    kenoLogic.clearList();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.white,
                                    size: 25.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: kenoLogic.userNumbersList.isEmpty ||
                                      kenoLogic.isGameOn
                                  ? null
                                  : () {
                                      if (balance.currentBalance <
                                          double.parse(Keno.betFormatter
                                              .getUnformattedValue()
                                              .toStringAsFixed(2))) {
                                        return;
                                      }

                                      kenoLogic.startGame(
                                          context: context,
                                          bet: double.parse(Keno.betFormatter
                                              .getUnformattedValue()
                                              .toString()));
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
                                  'СТАВКА',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color:
                                          kenoLogic.userNumbersList.isEmpty ||
                                                  kenoLogic.isGameOn
                                              ? Colors.white.withOpacity(0.4)
                                              : Colors.white,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              },
            ),
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
                  onPressed: context.watch<KenoLogic>().isGameOn
                      ? null
                      : () {
                          Beamer.of(context).beamBack();
                        },
                  icon: FaIcon(
                    FontAwesomeIcons.arrowLeft,
                    color: Theme.of(context).appBarTheme.iconTheme!.color,
                    size: Theme.of(context).appBarTheme.iconTheme!.size,
                  )),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Keno',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                Consumer<Balance>(
                  builder: (context, value, _) {
                    return currencyNormalFormat(
                        context: context, moneys: value.currentBalance);
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
                    onPressed: context.watch<KenoLogic>().isGameOn
                        ? null
                        : () => context.beamToNamed('/game-statistic/keno'),
                    icon: FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Theme.of(context).appBarTheme.iconTheme!.color,
                      size: Theme.of(context).appBarTheme.iconTheme!.size,
                    )),
              ),
            ],
          ),
          body: Consumer<KenoLogic>(builder: (ctx, kenoLogic, _) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  child: customTextField(
                      currencyTextInputFormatter: Keno.betFormatter,
                      textInputFormatter: Keno.betFormatter,
                      context: context,
                      keyboardType: TextInputType.number,
                      readOnly: kenoLogic.isGameOn,
                      isBetInput: true,
                      controller: Keno.betController,
                      hintText: 'Ставка...'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: GridView.custom(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverWovenGridDelegate.count(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          pattern: const [
                            WovenGridTile(2),
                            WovenGridTile(
                              2,
                              crossAxisRatio: 1,
                            ),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate(
                          childCount: 40,
                          (context, index) => ElevatedButton(
                            onPressed: () {
                              kenoLogic.selectCustomNumber(index);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor:
                                  kenoLogic.userNumbersList.contains(index)
                                      ? const Color.fromARGB(255, 164, 223, 96)
                                      : Theme.of(context).canvasColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      width: 3.0,
                                      color: kenoLogic.randomNumbersList
                                              .contains(index)
                                          ? kenoLogic.userNumbersList
                                                  .contains(index)
                                              ? Colors.deepPurpleAccent
                                              : Colors.deepPurpleAccent
                                                  .withOpacity(0.5)
                                          : Colors.transparent)),
                            ),
                            child: AutoSizeText(
                              (index + 1).toString(),
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: kenoLogic.userNumbersList
                                              .contains(index)
                                          ? Colors.black87
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color),
                            ),
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
    );
  }
}
