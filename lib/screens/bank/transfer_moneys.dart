import 'package:auto_size_text/auto_size_text.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/transfer_moneys_manager.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class TransferMoneys extends StatelessWidget {
  const TransferMoneys({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter.currency(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController = TextEditingController();
  static TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Consumer<TransferMoneysManager>(
          builder: (context, transferManager, child) {
        return transferManager.isLoading
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
                        'Перевод',
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
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => transferManager.transfer(
                                    amount: double.parse(betFormatter
                                        .getUnformattedValue()
                                        .toString()),
                                    context: context,
                                    name: usernameController.text.trim()),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.moneyBillTransfer,
                                        color: Theme.of(context)
                                            .appBarTheme
                                            .iconTheme!
                                            .color,
                                        size: Theme.of(context)
                                            .appBarTheme
                                            .iconTheme!
                                            .size,
                                      ),
                                      const SizedBox(width: 10.0),
                                      AutoSizeText(
                                        'Перевести',
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
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  TextField(
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                        hintText: 'Никнейм...',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall!
                                                    .color!
                                                    .withOpacity(0.5)),
                                        enabledBorder: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder,
                                        focusedBorder: Theme.of(context)
                                            .inputDecorationTheme
                                            .focusedBorder),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 20.0),
                                  ),
                                  const SizedBox(height: 15.0),
                                  TextField(
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    controller: betController,
                                    inputFormatters: [betFormatter],
                                    onTap: () {
                                      betController.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              betController.text.length);
                                    },
                                    onChanged: (value) {
                                      transferManager.changeAmount(double.parse(
                                          betFormatter
                                              .getUnformattedValue()
                                              .toString()));
                                    },
                                    decoration: InputDecoration(
                                        hintText: 'Количество...',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall!
                                                    .color!
                                                    .withOpacity(0.5)),
                                        enabledBorder: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder,
                                        focusedBorder: Theme.of(context)
                                            .inputDecorationTheme
                                            .focusedBorder),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 20.0),
                                  ),
                                  SupabaseController.isPremium
                                      ? Container()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AutoSizeText(
                                                'C комиссией:',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              AutoSizeText(
                                                transferManager.currentAmount,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                  const SizedBox(height: 15.0),
                                  smallHelperPanel(
                                    icon: FontAwesomeIcons.circleInfo,
                                    context: context,
                                    text:
                                        '${SupabaseController.isPremium ? '' : 'Комиссия 60%.\nP.S. c Premium комиссии нет.\n\n'}Перевести можно не больше ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(5000000)} за день!',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
      }),
    );
  }
}
