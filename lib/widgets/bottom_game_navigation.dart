import 'package:auto_size_text/auto_size_text.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';

Widget bottomGameNavigation({
  required BuildContext context,
  required CurrencyTextInputFormatter betFormatter,
  required TextEditingController betController,
  bool? isAutoBets = false,
  required bool isPlaying,
  bool? switchValue,
  bool? isCanSwitch = false,
  required VoidCallback onPressed,
  ValueChanged<bool>? onSwitched,
}) {
  bool isShowInputBet = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 60.0,
                    width: 80.0,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isShowInputBet = !isShowInputBet;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: const Color(0xFF366ecc),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: FaIcon(
                        isShowInputBet
                            ? FontAwesomeIcons.arrowLeft
                            : FontAwesomeIcons.keyboard,
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ),
                  ),
                  isShowInputBet || !isCanSwitch!
                      ? Container()
                      : SizedBox(
                          height: 60.0,
                          width: 80.0,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5.0)
                              ],
                              color: const Color(0xFF3d7ce6),
                            ),
                            child: Switch(
                              value: switchValue!,
                              onChanged: (value) => onSwitched!.call(value),
                            ),
                          ),
                        ),
                ],
              ),
              Visibility(
                visible: isShowInputBet,
                child: Expanded(
                  child: SizedBox(
                    height: 60.0,
                    child: customTextField(
                        currencyTextInputFormatter: betFormatter,
                        textInputFormatter: betFormatter,
                        keyboardType: TextInputType.number,
                        isBetInput: true,
                        controller: betController,
                        context: context,
                        hintText: 'Ставка...'),
                  ),
                ),
              ),
              Visibility(
                visible: !isShowInputBet,
                child: Expanded(
                  child: SizedBox(
                    height: 60.0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5.0)
                      ], color: Theme.of(context).cardColor),
                      child: ElevatedButton(
                        onPressed: isAutoBets! || isPlaying
                            ? null
                            : () => onPressed.call(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.green,
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                'СТАВКА',
                                maxLines: 1,
                                style: GoogleFonts.roboto(
                                    color: isAutoBets || isPlaying
                                        ? Colors.white30
                                        : Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
