import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/login_custom_text_field.dart';
import 'package:pinput/pinput.dart';
import 'package:restart_app/restart_app.dart';

class VerifyPhoneNumber extends StatefulWidget {
  const VerifyPhoneNumber(
      {super.key, required this.email, this.isResetPassword = false});

  final String email;
  final bool isResetPassword;

  @override
  State<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static bool isLoading = false;

  static TextEditingController newPasswordController = TextEditingController();

  late Timer timer;
  int timeBeforeSendCodeAgain = 0;

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 25,
      color: Colors.white,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        width: 2.0,
        color: Colors.white54,
      ),
    ),
  );

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      timeBeforeSendCodeAgain = 60;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeBeforeSendCodeAgain--;
      });

      if (timeBeforeSendCodeAgain == 0) {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Color focusedBorderColor = Colors.white70;
    const fillColor = Color.fromRGBO(24, 133, 241, 0);

    return isLoading
        ? loading(context: context)
        : PopScope(
            canPop: false,
            child: Scaffold(
                key: _scaffoldKey,
                bottomNavigationBar: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 60.0,
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5.0)
                        ], color: Theme.of(context).cardColor),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (pinController.text.length < 6) {
                              return;
                            }

                            focusNode.unfocus();

                            setState(() {
                              isLoading = true;
                            });

                            if (!widget.isResetPassword) {
                              await SupabaseController().verifyEmail(
                                email: widget.email,
                                context: context,
                                verifyCode: pinController.text,
                              );

                              await alertDialogSuccess(
                                  context:
                                      _scaffoldKey.currentContext ?? context,
                                  title: 'Уведомление',
                                  canCloseAlert: false,
                                  confirmBtnText: 'Перезайти',
                                  text:
                                      'Для обновления настроек игры, пожалуйста, перезайдите!',
                                  onConfirmBtnTap: () => Restart.restartApp());
                            } else {
                              await SupabaseController().resetPassword(
                                  email: widget.email,
                                  context: context,
                                  verifyCode: pinController.text,
                                  newPassword: newPasswordController.text);
                            }

                            setState(() {
                              isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blueAccent,
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  'Подтвердить',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                                widget.isResetPassword
                                    ? 'Сброс пароля'
                                    : 'Верификация',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 5.0),
                            Text('Введите код из электронной почты',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        height: 1.4,
                                        color: Colors.white.withOpacity(0.5))),
                            const SizedBox(height: 5.0),
                            Text(widget.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        height: 1.4,
                                        color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 330.0,
                              height: 55.0,
                              child: Pinput(
                                length: 6,
                                controller: pinController,
                                focusNode: focusNode,
                                defaultPinTheme: defaultPinTheme,
                                separatorBuilder: (index) =>
                                    const SizedBox(width: 8),
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                cursor: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 9),
                                      width: 22,
                                      height: 1,
                                      color: focusedBorderColor,
                                    ),
                                  ],
                                ),
                                focusedPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: focusedBorderColor, width: 2.0),
                                  ),
                                ),
                                submittedPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(19),
                                    border:
                                        Border.all(color: focusedBorderColor),
                                  ),
                                ),
                                errorPinTheme: defaultPinTheme.copyBorderWith(
                                  border: Border.all(color: Colors.redAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            timeBeforeSendCodeAgain <= 0
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0),
                                    child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  if (!widget.isResetPassword) {
                                                    await SupabaseController()
                                                        .resendOTP(widget.email)
                                                        .whenComplete(() {
                                                      startTimer();
                                                    });
                                                  } else {
                                                    await SupabaseController()
                                                        .sendCodeToResetPassword(
                                                      context: context,
                                                      email: widget.email,
                                                    )
                                                        .whenComplete(() {
                                                      startTimer();
                                                    });
                                                  }

                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                },
                                              text: 'Отправить повторно',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    height: 1.4,
                                                    color: Colors.blue,
                                                  ))
                                        ])),
                                  )
                                : Text(
                                    'Отправить повторно (через $timeBeforeSendCodeAgain сек.)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            height: 1.4,
                                            color:
                                                Colors.white.withOpacity(0.5))),
                            !widget.isResetPassword
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 15.0),
                                    child: loginCustomTextField(
                                        context: context,
                                        keyboardType: TextInputType.text,
                                        controller: newPasswordController,
                                        isLastInput: true,
                                        isPassword: true,
                                        hintText: 'Новый пароль...'),
                                  ),
                          ],
                        ),
                        Container(),
                      ],
                    ),
                  ),
                )),
          );
  }
}
