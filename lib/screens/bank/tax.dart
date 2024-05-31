import 'package:auto_size_text/auto_size_text.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Tax extends StatelessWidget {
  const Tax({super.key});

  static CurrencyTextInputFormatter betFormatter =
      CurrencyTextInputFormatter.currency(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.formatString('1000000'));

  @override
  Widget build(BuildContext context) {
    return Consumer<TaxManager>(
      builder: (context, taxManager, child) {
        return taxManager.isLoading
            ? loading(context: context)
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
                        return currencyNormalFormat(
                            context: context, moneys: balance.currentBalance);
                      })
                    ],
                  ),
                ),
                bottomNavigationBar: taxManager.currentTax <= 0.0
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: ElevatedButton(
                          onPressed: () async => await taxManager.payTax(context),
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
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: AutoSizeText(
                              'Оплатить',
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        )),
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .surface,
                                          width: 3.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          AutoSizeText(
                                            NumberFormat.simpleCurrency(
                                                    locale:
                                                        ui.Platform.localeName)
                                                .format(taxManager.currentTax),
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .appBarTheme
                                                .titleTextStyle!
                                                .copyWith(fontSize: 25.0),
                                          ),
                                          AutoSizeText(
                                            'Текущий налог\n${taxManager.currentTax > 0 ? 'Оплатите его до ${DateFormat.MMMMd(ui.Platform.localeName).format(taxManager.lastDayPaymentDate)}' : ''}',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          taxManager.currentTax > 0
                                              ? AutoSizeText(
                                                  'Оплатите его до ${DateFormat.MMMMd(ui.Platform.localeName).format(taxManager.lastDayPaymentDate)}',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15.0),
                                  smallHelperPanel(
                                    context: context,
                                    icon: FontAwesomeIcons.circleInfo,
                                    text:
                                        'Каждая ставка облагается налогом в размере 1.2% от ставки. Налог можно оплатить в любое время до истечения срока действия. Если вы не оплатите его вовремя, то не сможете продолжать играть в игры.\n\nP.S. Если у вас есть Premium-подписка, то налог платить не нужно!',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
