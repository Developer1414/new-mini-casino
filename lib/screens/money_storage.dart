import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';

class MoneyStorage extends StatelessWidget {
  const MoneyStorage({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('100000'));

  @override
  Widget build(BuildContext context) {
    final storageManager =
        Provider.of<MoneyStorageManager>(context, listen: false);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: storageManager.isLoading
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
                      'Хранилище',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    Consumer<Balance>(builder: (ctx, balance, _) {
                      return AutoSizeText(
                        balance.currentBalanceString,
                        style: Theme.of(context).textTheme.displaySmall,
                      );
                    }),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Consumer<MoneyStorageManager>(
                          builder: (ctx, balance, _) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme!
                                    .background,
                                width: 3.0),
                          ),
                          child: Column(
                            children: [
                              AutoSizeText(
                                balance.currentBalanceString,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle!
                                    .copyWith(fontSize: 25.0),
                              ),
                              const SizedBox(height: 5.0),
                              AutoSizeText('Баланс',
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color!
                                              .withOpacity(0.7))),
                            ],
                          ),
                        );
                      })),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: SingleChildScrollView(
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
                                    customTextField(
                                        currencyTextInputFormatter:
                                            betFormatter,
                                        textInputFormatter: betFormatter,
                                        keyboardType: TextInputType.number,
                                        controller: betController,
                                        context: context,
                                        hintText: 'Количество...'),
                                    const SizedBox(height: 20.0),
                                    buttonModel(
                                        buttonName: 'В хранилище',
                                        onPressed: () =>
                                            storageManager.transferToStorage(
                                                amount: double.parse(
                                                    betFormatter
                                                        .getUnformattedValue()
                                                        .toString()),
                                                context: context),
                                        color: Colors.blueAccent),
                                    const SizedBox(height: 20.0),
                                    buttonModel(
                                        buttonName: 'На основной счёт',
                                        onPressed: () => storageManager
                                            .transferToMainAccount(
                                                amount: double.parse(
                                                    betFormatter
                                                        .getUnformattedValue()
                                                        .toString()),
                                                context: context),
                                        color: Colors.blueAccent),
                                    const SizedBox(height: 15.0),
                                    AutoSizeText(
                                      'Перевод в хранилище доступен от ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}',
                                      style: GoogleFonts.roboto(
                                          color: Colors.white.withOpacity(0.5),
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
                    ),
                  ),
                ],
              )),
    );
  }

  Widget buttonModel(
      {required String buttonName,
      required Color color,
      Function()? onPressed}) {
    return SizedBox(
      height: 60.0,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shadowColor: color.withOpacity(0.8),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: AutoSizeText(
          buttonName,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22.0,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
