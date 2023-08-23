import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/loan_moneys_manager.dart';
import 'package:new_mini_casino/models/button_model.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class LoanMoneys extends StatelessWidget {
  const LoanMoneys({super.key});

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
                'Кредит',
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
            future: Provider.of<LoanMoneysManager>(context, listen: false)
                .getLoan(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loading(context: context);
              }
              return Consumer<LoanMoneysManager>(
                builder: (context, loanMoneysManager, child) {
                  return loanMoneysManager.isLoading
                      ? loading(context: context)
                      : Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                loanMoneysManager.userLoan != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(35.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                const FaIcon(
                                                  FontAwesomeIcons.lock,
                                                  color: Colors.white,
                                                  size: 80.0,
                                                ),
                                                const SizedBox(height: 10.0),
                                                AutoSizeText(
                                                  'Уже есть кредит',
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
                                            const SizedBox(height: 20.0),
                                            Column(
                                              children: [
                                                buttonModel(
                                                    context: context,
                                                    buttonName:
                                                        'Погасить кредит',
                                                    subtitle: NumberFormat
                                                            .simpleCurrency(
                                                                locale: ui
                                                                    .Platform
                                                                    .localeName)
                                                        .format((loanMoneysManager
                                                                    .userLoan
                                                                    ?.amount ??
                                                                0) +
                                                            (loanMoneysManager
                                                                        .userLoan
                                                                        ?.amount ??
                                                                    0) *
                                                                (loanMoneysManager
                                                                        .userLoan
                                                                        ?.percent ??
                                                                    1) /
                                                                100),
                                                    onPressed: () {
                                                      loanMoneysManager
                                                          .repayLoan(
                                                              context: context);
                                                    },
                                                    color: Colors.redAccent),
                                                const SizedBox(height: 20.0),
                                                AutoSizeText(
                                                  'Вы можете погасить кредит до ${DateFormat.MMMMd('ru_RU').format(loanMoneysManager.userLoan?.loanMaturity ?? DateTime.now())}. Если не погасите его в срок, то каждый день он будет увеличиваться на 3%.',
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
                                      )
                                    : Padding(
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
                                                  'Кредит',
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
                                                    textInputFormatter:
                                                        betFormatter,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: betController,
                                                    context: context,
                                                    hintText: 'Количество...'),
                                                const SizedBox(height: 20.0),
                                                buttonModel(
                                                    context: context,
                                                    buttonName: 'Взять кредит',
                                                    onPressed: () =>
                                                        loanMoneysManager.takeLoan(
                                                            amount: double.parse(
                                                                betFormatter
                                                                    .getUnformattedValue()
                                                                    .toString()),
                                                            context: context),
                                                    color: Colors.blueAccent),
                                                const SizedBox(height: 20.0),
                                                AutoSizeText(
                                                  'Через каждую 1000 игр вы сможете брать кредит больше на ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(10000)}. Сейчас ваш максимально допустимый кредит - ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(loanMoneysManager.maxLoan)}. После взятия кредита вам нужно будет погасить его в течение 7 дней на 10% больше (или на 5%, если у вас есть подписка Premium). Если не погасите его в срок, то каждый день он будет увеличиваться на 3%. Кстати, с подпиской Premium кредит можно взять в 2 раза больше!',
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
                              ],
                            ),
                          ),
                        );
                },
              );
            }),
      ),
    );
  }
}
