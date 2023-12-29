import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
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
                      return currencyNormalFormat(
                          context: context, moneys: balance.currentBalance);
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
                              AutoSizeText(balance.currentBalanceString,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .appBarTheme
                                      .titleTextStyle!),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
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
                                        context: context,
                                        buttonName: 'В хранилище',
                                        icon: FontAwesomeIcons.arrowUp,
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
                                        context: context,
                                        buttonName: 'На основной счёт',
                                        icon: FontAwesomeIcons.arrowDown,
                                        onPressed: () => storageManager
                                            .transferToMainAccount(
                                                amount: double.parse(
                                                    betFormatter
                                                        .getUnformattedValue()
                                                        .toString()),
                                                context: context),
                                        color: Colors.blueAccent),
                                    const SizedBox(height: 15.0),
                                    smallHelperPanel(
                                        context: context,
                                        text:
                                            'Перевод в хранилище доступен от ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}'),
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
}
