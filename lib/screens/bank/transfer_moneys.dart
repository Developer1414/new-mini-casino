import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/transfer_moneys_manager.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class TransferMoneys extends StatelessWidget {
  const TransferMoneys({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
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
                  'Перевод',
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
          body: Consumer<TransferMoneysManager>(
            builder: (context, loanMoneysManager, child) {
              return loanMoneysManager.isLoading
                  ? loading(context: context)
                  : Center(
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
                                        FontAwesomeIcons.moneyBillTransfer,
                                        color: Colors.white,
                                        size: 80.0,
                                      ),
                                      const SizedBox(height: 10.0),
                                      AutoSizeText(
                                        'Перевод',
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
                                      const SizedBox(height: 20.0),
                                      TextField(
                                        textAlign: TextAlign.center,
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number,
                                        controller: betController,
                                        inputFormatters: [betFormatter],
                                        onTap: () {
                                          betController.selection =
                                              TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset: betController
                                                      .text.length);
                                        },
                                        onChanged: (value) {
                                          loanMoneysManager.changeAmount(
                                              double.parse(betFormatter
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
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AutoSizeText(
                                                    'C комиссией:',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                  AutoSizeText(
                                                    loanMoneysManager
                                                        .currentAmount,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                      const SizedBox(height: 20.0),
                                      buttonModel(
                                          context: context,
                                          buttonName: 'Перевести',
                                          onPressed: () =>
                                              loanMoneysManager.transfer(
                                                  amount: double.parse(
                                                      betFormatter
                                                          .getUnformattedValue()
                                                          .toString()),
                                                  context: context,
                                                  username: usernameController
                                                      .text
                                                      .trim()),
                                          color: Colors.blueAccent),
                                      const SizedBox(height: 20.0),
                                      SupabaseController.isPremium
                                          ? Container()
                                          : AutoSizeText(
                                              'Комиссия 60%.\nP.S. c Premium комиссии нет.',
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
                          ],
                        ),
                      ),
                    );
            },
          )),
    );
  }
}
