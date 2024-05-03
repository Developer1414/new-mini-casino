import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:ntp/ntp.dart';

void giftPremiumAlert(
    {required BuildContext mainContext, required Payment paymentController}) {
  TextEditingController controller = TextEditingController();

  bool isLoading = false;

  Future<bool> checkOnExistPremium(String name) async {
    bool result = false;

    DateTime dateTimeNow = await NTP.now();

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('name', name)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      DateTime expiredSubscriptionDate = DateTime.parse(map['premium']);

      if (expiredSubscriptionDate.difference(dateTimeNow).inDays <= 0 &&
          expiredSubscriptionDate.difference(dateTimeNow).inHours <= 0 &&
          expiredSubscriptionDate.difference(dateTimeNow).inMinutes <= 0) {
        result = false;
      } else {
        result = true;
      }
    });

    return result;
  }

  Future<bool> checkOnExistGift(String name) async {
    bool result = false;

    await SupabaseController.supabase!
        .from('notifications')
        .select('*')
        .eq('action', 'premium_gift')
        .eq('to', name)
        .then((value) {
      result = value.isNotEmpty;
    });

    return result;
  }

  showDialog(
    context: mainContext,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return isLoading
                ? loading(context: context)
                : Scaffold(
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
                                      'Premium в подарок',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    AutoSizeText(
                                      'Учитывайте регистр!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
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
                                            hintText: 'Никнейм игрока...',
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText('Месяц',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!),
                                          const SizedBox(width: 8.0),
                                          // Switch(
                                          //   value: paymentController
                                          //       .isYearSubscription,
                                          //   onChanged: (value) {
                                          //     setState(() {
                                          //       paymentController
                                          //           .chooseSubscriptionDuration(
                                          //               value);
                                          //     });
                                          //   },
                                          // ),
                                          const SizedBox(width: 8.0),
                                          AutoSizeText('Год',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!),
                                        ],
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

                                          setState(() => isLoading = true);

                                          await SupabaseController()
                                              .checkNameOnAvailability(
                                                  name: controller.text)
                                              .then((value) async {
                                            if (!value) {
                                              setState(() => isLoading = false);
                                              alertDialogError(
                                                  context: context,
                                                  title: 'Ошибка',
                                                  text:
                                                      'Игрока с таким никнеймом не существует!',
                                                  onConfirmBtnTap: () {
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                            } else {
                                              await checkOnExistGift(
                                                      controller.text)
                                                  .then((value) async {
                                                if (value) {
                                                  setState(
                                                      () => isLoading = false);

                                                  alertDialogError(
                                                      context: context,
                                                      title: 'Ошибка',
                                                      text:
                                                          'Игроку уже подарили Premium!',
                                                      onConfirmBtnTap: () {
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                } else {
                                                  await checkOnExistPremium(
                                                          controller.text
                                                              .trim())
                                                      .then((value) async {
                                                    if (value) {
                                                      setState(() =>
                                                          isLoading = false);

                                                      alertDialogError(
                                                          context: context,
                                                          title: 'Ошибка',
                                                          text:
                                                              'У игрока уже есть Premium!',
                                                          onConfirmBtnTap: () {
                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          });
                                                    } else {
                                                      paymentController
                                                          .premiumForGift(
                                                              controller.text);

                                                      Navigator.pop(context);

                                                      paymentController
                                                          .getPremium(
                                                              context:
                                                                  mainContext);

                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  });
                                                }
                                              });
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
                                              'Подарить',
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
        ),
      );
    },
  );
}
