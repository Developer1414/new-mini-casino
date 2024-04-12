import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';

Future<double> getCustomBet(BuildContext context) async {
  TextEditingController controller = TextEditingController();

  CurrencyTextInputFormatter controllerFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.2),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10.0),
                              Text(
                                'Ваша ставка',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15.0),
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    controllerFormatter,
                                  ],
                                  onChanged: (value) {
                                    if (controllerFormatter
                                                .getUnformattedValue()
                                                .toDouble() <=
                                            0.0 ||
                                        controller.text.isEmpty) {
                                      controller.text =
                                          controllerFormatter.format('0.00');

                                      return;
                                    }

                                    if (controllerFormatter
                                            .getUnformattedValue()
                                            .toDouble()
                                            .truncate() >
                                        100000000) {
                                      controller.text = controllerFormatter
                                          .format('100000000.00');
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Ставка...',
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 2,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(179, 84, 90, 104)),
                      ),
                      SizedBox(
                        height: 55.0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.green,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 57,
                                    height: 57,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Center(
                                      child: Text(
                                        'Применить',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.redAccent,
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    controller.clear();
                                    controllerFormatter.format('0.00');
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 57,
                                    height: 57,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Center(
                                      child: Text(
                                        'Отмена',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );

  return controllerFormatter.getUnformattedValue().toDouble();
}
