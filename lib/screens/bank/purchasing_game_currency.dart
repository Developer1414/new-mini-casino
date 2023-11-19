import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/purchasing_game_currency_controller.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
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
        children: [
          purchasingGameCurrencyController.isLoading
              ? loading(
                  context: context,
                  text: purchasingGameCurrencyController.loadingText)
              : Scaffold(
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, bottom: 15.0),
                    child: AutoSizeText(
                        'Покупка и продажа игровой валюты вне игры запрещена!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12.0,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .color!
                                .withOpacity(0.4))),
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
                          onPressed: () {
                            Beamer.of(context).beamBack();
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
                  body: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.moneyBill,
                                      color: Colors.white,
                                      size: 80.0,
                                    ),
                                    const SizedBox(height: 10.0),
                                    AutoSizeText(
                                      'Сколько вы хотели бы купить?',
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30.0),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 60.0,
                                          width: 60.0,
                                          child: ElevatedButton(
                                            onPressed:
                                                purchasingGameCurrencyController
                                                            .amountGameCurrency ==
                                                        250000
                                                    ? null
                                                    : () {
                                                        purchasingGameCurrencyController
                                                            .changeCurrency(
                                                                -50000);
                                                      },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 5,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 179, 242, 31),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                            ),
                                            child: FaIcon(
                                              FontAwesomeIcons.minus,
                                              color: purchasingGameCurrencyController
                                                          .amountGameCurrency ==
                                                      250000
                                                  ? Colors.white38
                                                  : Colors.black,
                                              size: 25.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15.0),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              AutoSizeText(
                                                  NumberFormat.simpleCurrency(
                                                          locale: ui.Platform
                                                              .localeName)
                                                      .format(
                                                          purchasingGameCurrencyController
                                                              .amountGameCurrency),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontSize: 20.0)),
                                              const SizedBox(height: 5.0),
                                              AutoSizeText(
                                                '(Игровых)',
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15.0),
                                        SizedBox(
                                          height: 60.0,
                                          width: 60.0,
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
                                            style: ElevatedButton.styleFrom(
                                              elevation: 5,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 179, 242, 31),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
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
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            'Итого:',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                NumberFormat.simpleCurrency(
                                                        locale: 'ru_RU')
                                                    .format(
                                                        purchasingGameCurrencyController
                                                            .amountRealCurrency),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              const SizedBox(width: 5.0),
                                              AutoSizeText(
                                                '(Реальных)',
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    SizedBox(
                                      height: 60.0,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          purchasingGameCurrencyController
                                              .getGameCurrency(
                                                  context: context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          backgroundColor: const Color.fromARGB(
                                              255, 179, 242, 31),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                        ),
                                        child: AutoSizeText(
                                          'Купить',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                            color: const Color.fromARGB(
                                                255, 5, 2, 1),
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                        onPageStarted: (String url) {},
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                      ),
                    )
                    ..loadRequest(purchasingGameCurrencyController.uri))
              : Container(),
        ],
      );
    });
  }
}
