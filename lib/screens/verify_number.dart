import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:pinput/pinput.dart';

class VerifyPhoneNumber extends StatefulWidget {
  const VerifyPhoneNumber({super.key, required this.email});

  final String email;

  @override
  State<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  static bool isLoading = false;

  late Timer timer;
  int timeBeforeSendCodeAgain = 0;

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
    Color focusedBorderColor =
        Theme.of(context).buttonTheme.colorScheme!.background;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 25,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(width: 2.0, color: Theme.of(context).cardColor),
      ),
    );

    return isLoading
        ? loading(context: context)
        : Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                bottom: 15.0,
              ),
              child: buttonModel(
                  context: context,
                  buttonName: 'Подтвердить',
                  color: Colors.blueAccent,
                  onPressed: () async {
                    if (pinController.text.length < 6) {
                      return;
                    }

                    focusNode.unfocus();

                    setState(() {
                      isLoading = true;
                    });

                    await SupabaseController().verifyEmail(
                        email: widget.email,
                        context: context,
                        code: pinController.text);

                    setState(() {
                      isLoading = false;
                    });
                  }),
            ),
            body: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text('Верификация',
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
                        Pinput(
                          length: 6,
                          controller: pinController,
                          focusNode: focusNode,
                          androidSmsAutofillMethod:
                              AndroidSmsAutofillMethod.smsUserConsentApi,
                          listenForMultipleSmsOnAndroid: true,
                          defaultPinTheme: defaultPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (pin) {
                            debugPrint('onCompleted: $pin');
                          },
                          onChanged: (value) {
                            debugPrint('onChanged: $value');
                          },
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
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: focusedBorderColor, width: 2.0),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
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

                                              await SupabaseController()
                                                  .resendOTP(widget.email)
                                                  .whenComplete(() {
                                                startTimer();
                                              });

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
                                'Отправить повторно (через $timeBeforeSendCodeAgain секунд)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        height: 1.4,
                                        color: Colors.white.withOpacity(0.5)))
                      ],
                    ),
                    Container(),
                  ],
                ),
              ),
            ));
  }
}
