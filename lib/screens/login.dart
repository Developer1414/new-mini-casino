import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/login_custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController friendCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SupabaseController.context = context;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Consumer<SupabaseController>(
        builder: (context, accountController, _) {
          return accountController.isLoading
              ? loading(text: accountController.loadingText, context: context)
              : DefaultTabController(
                  length: 2,
                  child: Scaffold(
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
                                if (accountController.authorizationAction ==
                                    AuthorizationAction.register) {
                                  if (nameController.text.isEmpty) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Упс...',
                                        text: 'Вы не вписали никнейм!',
                                        confirmBtnText: 'Окей',
                                        animType:
                                            QuickAlertAnimType.slideInDown);

                                    return;
                                  }
                                }

                                if (emailController.text.isEmpty) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'Упс...',
                                      text: 'Вы не вписали почту!',
                                      confirmBtnText: 'Окей',
                                      animType: QuickAlertAnimType.slideInDown);

                                  return;
                                }

                                if (passwordController.text.isEmpty) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'Упс...',
                                      text: 'Вы не вписали пароль!',
                                      confirmBtnText: 'Окей',
                                      animType: QuickAlertAnimType.slideInDown);

                                  return;
                                }

                                if (passwordController.text.length < 6) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'Упс...',
                                      text: 'Пароль слишком короткий!',
                                      confirmBtnText: 'Окей',
                                      animType: QuickAlertAnimType.slideInDown);

                                  return;
                                }

                                if (accountController.authorizationAction ==
                                    AuthorizationAction.register) {
                                  if (nameController.text.length < 4) {
                                    AccountExceptionController.showException(
                                        context: context,
                                        code: 'nickname_too_short');

                                    return;
                                  }
                                  await accountController.signUp(
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                      friendCode: friendCodeController.text,
                                      name: nameController.text.trim());
                                } else {
                                  await accountController.signInWithPassword(
                                      email: emailController.text.trim(),
                                      password: passwordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromARGB(255, 179, 242, 31),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      accountController.authorizationAction ==
                                              AuthorizationAction.register
                                          ? 'Зарегистрироваться'
                                          : 'Войти',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                        color:
                                            const Color.fromARGB(255, 5, 2, 1),
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
                    appBar: AppBar(
                      elevation: 0,
                      toolbarHeight: 76.0,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => accountController
                                    .changeAuthorizationAction(0),
                                icon: FaIcon(
                                  FontAwesomeIcons.userPlus,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .iconTheme!
                                      .color,
                                  size: 18.0,
                                ),
                                label: AutoSizeText('Регистрация',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 20.0)),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => accountController
                                    .changeAuthorizationAction(1),
                                icon: FaIcon(
                                  FontAwesomeIcons.rightToBracket,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .iconTheme!
                                      .color,
                                  size: 18.0,
                                ),
                                label: AutoSizeText('Вход',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 20.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  accountController.authorizationAction ==
                                          AuthorizationAction.register
                                      ? loginCustomTextField(
                                          context: context,
                                          keyboardType: TextInputType.name,
                                          limitSymbols: true,
                                          controller: nameController,
                                          hintText: 'Никнейм...')
                                      : Container(),
                                  const SizedBox(height: 15.0),
                                  loginCustomTextField(
                                      context: context,
                                      keyboardType: TextInputType.text,
                                      controller: emailController,
                                      hintText: 'Почта...'),
                                  const SizedBox(height: 15.0),
                                  loginCustomTextField(
                                      context: context,
                                      keyboardType: TextInputType.text,
                                      controller: passwordController,
                                      isLastInput: true,
                                      isPassword: true,
                                      hintText: 'Пароль...'),
                                  const SizedBox(height: 15.0),
                                  accountController.authorizationAction ==
                                          AuthorizationAction.register
                                      ? loginCustomTextField(
                                          context: context,
                                          keyboardType: TextInputType.text,
                                          controller: friendCodeController,
                                          hintText: 'Код друга... (если есть)')
                                      : Container(),
                                  accountController.authorizationAction !=
                                          AuthorizationAction.login
                                      ? Container()
                                      : RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  if (emailController
                                                      .text.isNotEmpty) {
                                                    await accountController
                                                        .sendCodeToResetPassword(
                                                            email:
                                                                emailController
                                                                    .text,
                                                            context: context);
                                                  } else {
                                                    alertDialogError(
                                                        context: context,
                                                        title: 'Ошибка',
                                                        confirmBtnText: 'Окей',
                                                        text:
                                                            'Для восстановления пароля впишите вашу почту!');
                                                  }
                                                },
                                              text: 'Забыл(а) пароль',
                                              style: GoogleFonts.roboto(
                                                  textStyle: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue,
                                              )),
                                            )
                                          ])),
                                  Visibility(
                                    visible:
                                        accountController.authorizationAction ==
                                            AuthorizationAction.register,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 15.0),
                                          decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              border: Border.all(
                                                  color: Colors.orangeAccent,
                                                  width: 2.0)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                                'Указывайте существующую почту, на неё будет отправлен код подтверждения.',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(fontSize: 12.0)),
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      'Регистрируясь, Вы принимаете нашу ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontSize: 12.0)),
                                              TextSpan(
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () =>
                                                          context.beamToNamed(
                                                              '/privacy-policy'),
                                                text:
                                                    'Политику Конфиденциальности',
                                                style: GoogleFonts.roboto(
                                                    textStyle: const TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  letterSpacing: 0.5,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.blue,
                                                )),
                                              )
                                            ])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
