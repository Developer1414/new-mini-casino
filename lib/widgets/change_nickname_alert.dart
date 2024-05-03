import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';

void changeNicknameAlert({required BuildContext context}) {
  TextEditingController controller = TextEditingController();

  bool isLoading = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return isLoading
              ? loading(context: context)
              : Scaffold(
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
                                  Text(
                                    'Смена никнейма',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  AutoSizeText(
                                    'За ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(100000)}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0, bottom: 10.0),
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.text,
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.done,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12),
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[a-z A-Z 0-9]'))
                                      ],
                                      decoration: InputDecoration(
                                          hintText: 'Ваш никнейм...',
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
                                      onTap: () async {
                                        if (controller.text.isEmpty) {
                                          return;
                                        }

                                        if (controller.text.length < 4) {
                                          AccountExceptionController
                                              .showException(
                                                  context: context,
                                                  code: 'nickname_too_short');

                                          return;
                                        }

                                        final balance = Provider.of<Balance>(
                                            context,
                                            listen: false);

                                        if (balance.currentBalance < 100000) {
                                          alertDialogError(
                                            context: context,
                                            title: 'Ошибка',
                                            confirmBtnText: 'Окей',
                                            text:
                                                'Недостаточно средств на балансе!',
                                          );

                                          return;
                                        }

                                        setState(() => isLoading = true);

                                        await SupabaseController()
                                            .checkNameOnAvailability(
                                                name: controller.text.trim())
                                            .then((isExist) async {
                                          if (isExist) {
                                            setState(() => isLoading = false);

                                            AccountExceptionController
                                                .showException(
                                                    context: context,
                                                    code:
                                                        'nickname_already_exist');
                                          } else {
                                            await SupabaseController.supabase!
                                                .from('users')
                                                .update({
                                              'name': controller.text.trim()
                                            }).eq(
                                                    'uid',
                                                    SupabaseController.supabase
                                                        ?.auth.currentUser!.id);

                                            balance.subtractMoney(100000);

                                            setState(() {
                                              isLoading = false;
                                            });

                                            if (context.mounted) {
                                              alertDialogSuccess(
                                                  context: context,
                                                  title: 'Успех',
                                                  text:
                                                      'Никнейм успешно изменён!',
                                                  onConfirmBtnTap: () {
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                            }
                                          }
                                        });
                                      },
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
                                Expanded(
                                  child: Material(
                                    color: Colors.redAccent,
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(15.0),
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
      );
    },
  );
}
