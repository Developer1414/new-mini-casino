import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void autoClickerDetected({required BuildContext context}) {
  TextEditingController controller = TextEditingController();

  int symbol = Random.secure().nextInt(2) + 0;

  int num1 = Random.secure().nextInt(451) + 50;
  int num2 = Random.secure().nextInt(451) + 50;

  void checkResult() {
    if (controller.text.isEmpty) return;

    if (double.parse(controller.text) ==
        (symbol == 0 ? num1 + num2 : num1 - num2)) {
      Navigator.pop(context);
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.2),
          body: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40.0),
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
                          AutoSizeText(
                            'Защита от автокликера',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '$num1 ${symbol == 0 ? '+' : '-'} $num2 = ?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30.0, right: 30.0, bottom: 10.0),
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                  hintText: 'Ответ...',
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
                              bottomRight: Radius.circular(15.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => checkResult(),
                              child: Container(
                                width: 57,
                                height: 57,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Center(
                                  child: Text(
                                    'Готово',
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
        ),
      );
    },
  );
}
