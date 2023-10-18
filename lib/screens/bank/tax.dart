import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Tax extends StatelessWidget {
  const Tax({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('1000000'));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Налог',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              Consumer<Balance>(builder: (ctx, balance, _) {
                return AutoSizeText(
                  balance.currentBalanceString,
                  style: Theme.of(context).textTheme.displaySmall,
                );
              })
            ],
          ),
        ),
        body: FutureBuilder(
            future: Provider.of<TaxManager>(context, listen: false).getTax(),
            builder: (context, snapshot) {
              return Consumer<TaxManager>(
                  builder: (context, taxManager, child) {
                return taxManager.isLoading
                    ? loading(context: context)
                    : Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(35.0),
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.landmark,
                                              color: Colors.white,
                                              size: 80.0,
                                            ),
                                            const SizedBox(height: 10.0),
                                            AutoSizeText(
                                              'Налог',
                                              maxLines: 1,
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
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                              left: 50.0, right: 50.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            color: Theme.of(context).cardColor,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .background,
                                                width: 3.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                AutoSizeText(
                                                  NumberFormat.simpleCurrency(
                                                          locale: ui.Platform
                                                              .localeName)
                                                      .format(taxManager
                                                          .currentTax),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .appBarTheme
                                                      .titleTextStyle!
                                                      .copyWith(fontSize: 25.0),
                                                ),
                                                const SizedBox(height: 5.0),
                                                AutoSizeText(
                                                  'Текущий налог\n${taxManager.currentTax > 0 ? 'Оплатите его до ${DateFormat.MMMMd('ru_RU').format(taxManager.taxPeriod)}' : ''}',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                taxManager.currentTax > 0
                                                    ? AutoSizeText(
                                                        'Оплатите его до ${DateFormat.MMMMd('ru_RU').format(taxManager.taxPeriod)}',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.5),
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Column(
                                          children: [
                                            buttonModel(
                                                context: context,
                                                buttonName: 'Оплатить',
                                                onPressed: () =>
                                                    taxManager.payTax(context),
                                                color: Colors.blueAccent),
                                            const SizedBox(height: 20.0),
                                            AutoSizeText(
                                              'Каждая ставка облагается налогом в размере 1% от ставки. Налог можно оплатить в любое время до истечения срока действия. Если вы не оплатите его вовремя, то не сможете продолжать играть в игры.\nP.S. Если у вас есть Premium-подписка, то налог платить не нужно!',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              });
            }),
      ),
    );
  }
}
