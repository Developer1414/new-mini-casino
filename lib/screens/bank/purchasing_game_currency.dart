import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/purchasing_game_currency_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/custom_bet_alert_widget.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:webview_flutter/webview_flutter.dart';

class PurchasingGameCurrency extends StatelessWidget {
  const PurchasingGameCurrency({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchasingGameCurrencyController>(
        builder: (context, purchasingGameCurrencyController, child) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          purchasingGameCurrencyController.isLoading
              ? loading(
                  context: context,
                  text: purchasingGameCurrencyController.loadingText)
              : Scaffold(
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
                            Navigator.of(context).pop();
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
                          )),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Игровая валюта',
                          style: Theme.of(context).appBarTheme.titleTextStyle,
                        ),
                        Consumer<Balance>(builder: (ctx, balance, _) {
                          return currencyNormalFormat(
                              context: context, moneys: balance.currentBalance);
                        })
                      ],
                    ),
                  ),
                  bottomNavigationBar: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: smallHelperPanel(
                          context: context,
                          icon: FontAwesomeIcons.circleInfo,
                          text:
                              'Покупка и продажа игровой валюты вне игры - запрещена!',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText('Итого',
                                style: Theme.of(context).textTheme.titleMedium),
                            AutoSizeText(
                                NumberFormat.simpleCurrency(locale: 'ru_RU')
                                    .format(purchasingGameCurrencyController
                                        .amountRealCurrency),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 20.0)),
                          ],
                        ),
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      purchasingGameCurrencyController
                                          .getGameCurrency(context: context),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor:
                                        const Color.fromARGB(255, 179, 242, 31),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25.0),
                                          topRight: Radius.circular(25.0)),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: AutoSizeText(
                                      'Купить',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: const Color.fromARGB(
                                              255, 5, 2, 1),
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  body: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 100.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: const Color.fromARGB(
                                                255, 179, 242, 31)
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 179, 242, 31),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          NumberFormat.simpleCurrency(
                                                  locale:
                                                      ui.Platform.localeName)
                                              .format(
                                                  purchasingGameCurrencyController
                                                      .amountGameCurrency),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 25.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Row(
                                      children: [
                                        purchasingGameCurrencyController
                                                    .amountGameCurrency ==
                                                100000
                                            ? Container()
                                            : Expanded(
                                                child: SizedBox(
                                                  height: 50.0,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      purchasingGameCurrencyController
                                                          .changeCurrency(
                                                              -50000);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 5,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              179,
                                                              242,
                                                              31),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0)),
                                                    ),
                                                    child: FaIcon(
                                                      FontAwesomeIcons.minus,
                                                      color: purchasingGameCurrencyController
                                                                  .amountGameCurrency ==
                                                              100000
                                                          ? Colors.white38
                                                          : Colors.black,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        purchasingGameCurrencyController
                                                        .amountGameCurrency ==
                                                    100000 ||
                                                purchasingGameCurrencyController
                                                        .amountGameCurrency ==
                                                    10000000
                                            ? Container()
                                            : const SizedBox(width: 15.0),
                                        purchasingGameCurrencyController
                                                    .amountGameCurrency ==
                                                10000000
                                            ? Container()
                                            : Expanded(
                                                child: SizedBox(
                                                  height: 50.0,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        purchasingGameCurrencyController
                                                                    .amountGameCurrency ==
                                                                10000000
                                                            ? null
                                                            : () {
                                                                purchasingGameCurrencyController
                                                                    .changeCurrency(
                                                                        50000);
                                                              },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 5,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              179,
                                                              242,
                                                              31),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0)),
                                                    ),
                                                    child: FaIcon(
                                                      FontAwesomeIcons.plus,
                                                      color: purchasingGameCurrencyController
                                                                  .amountGameCurrency ==
                                                              10000000
                                                          ? Colors.white38
                                                          : Colors.black,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                                buttonModel(
                                  context: context,
                                  color:
                                      const Color.fromARGB(255, 179, 242, 31),
                                  onPressed: () async {
                                    double customBet =
                                        await getCustomBet(context);

                                    if (customBet >= 100000) {
                                      purchasingGameCurrencyController
                                          .custromCurrency(customBet);
                                    }
                                  },
                                  buttonName: 'Моя сумма',
                                  textColor: const Color.fromARGB(255, 5, 2, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          purchasingGameCurrencyController.isOpenURL
              ? WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(const Color(0x00000000))
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onProgress: (int progress) {
                          // Update loading bar.
                        },
                        onPageStarted: (String url) {},
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                      ),
                    )
                    ..loadRequest(purchasingGameCurrencyController.uri))
              : Container(),
          ConfettiWidget(
            confettiController: confettiController,
            numberOfParticles: 15,
            emissionFrequency: 0.1,
            gravity: 0.1,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ],
      );
    });
  }
}
