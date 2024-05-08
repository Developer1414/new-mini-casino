import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/login_custom_text_field.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController friendCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SupabaseController.context = context;

    Future auth({
      required SupabaseController accountController,
      bool isGoogleAuth = false,
    }) async {
      if (accountController.authorizationAction ==
          AuthorizationAction.register) {
        if (nameController.text.isEmpty) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            text: 'Вы не вписали никнейм!',
          );

          return;
        }
      }

      if (!isGoogleAuth) {
        if (emailController.text.isEmpty) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            text: 'Вы не вписали почту!',
          );

          return;
        }

        if (passwordController.text.isEmpty) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            text: 'Вы не вписали пароль!',
          );

          return;
        }

        if (passwordController.text.length < 6) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            text: 'Пароль слишком короткий!',
          );

          return;
        }
      }

      if (accountController.authorizationAction ==
          AuthorizationAction.register) {
        if (nameController.text.length < 4) {
          AccountExceptionController.showException(
              context: context, code: 'nickname_too_short');

          return;
        }

        if (!isGoogleAuth) {
          await accountController.signUp(
              email: emailController.text.trim(),
              password: passwordController.text,
              friendCode: friendCodeController.text,
              name: nameController.text.trim());
        } else {
          await accountController.signUpWithGoogle(nameController.text.trim());
        }
      } else {
        if (!isGoogleAuth) {
          await accountController.signInWithPassword(
              email: emailController.text.trim(),
              password: passwordController.text);
        } else {
          await accountController.signInWithGoogle();
        }
      }
    }

    return Consumer<SupabaseController>(
      builder: (context, accountController, _) {
        return accountController.isLoading
            ? loading(text: accountController.loadingText, context: context)
            : DefaultTabController(
                length: 2,
                child: Scaffold(
                  bottomNavigationBar: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60.0,
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5.0)
                            ], color: Theme.of(context).cardColor),
                            child: ElevatedButton(
                              onPressed: () async => await auth(
                                  accountController: accountController),
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
                      ),
                      // SizedBox(
                      //   height: 60.0,
                      //   child: ElevatedButton(
                      //       style: ElevatedButton.styleFrom(
                      //         elevation: 0,
                      //         shape: const RoundedRectangleBorder(),
                      //       ),
                      //       onPressed: () async => await auth(
                      //             accountController: accountController,
                      //             isGoogleAuth: true,
                      //           ),
                      //       child: Image.asset(
                      //         'assets/other_images/google-icon.png',
                      //         width: 30.0,
                      //         height: 30.0,
                      //       )),
                      // ),
                    ],
                  ),
                  appBar: AppBar(
                    elevation: 0,
                    toolbarHeight: 76.0,
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60.0,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => accountController
                                  .changeAuthorizationAction(0),
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                shadowColor: Colors.blueAccent.withOpacity(0.8),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  side: accountController.authorizationAction ==
                                          AuthorizationAction.register
                                      ? const BorderSide(
                                          width: 2.0, color: Colors.redAccent)
                                      : BorderSide.none,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.userPlus,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(height: 3.0),
                                  AutoSizeText(
                                    'Регистрация',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: SizedBox(
                            height: 60.0,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => accountController
                                  .changeAuthorizationAction(1),
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                shadowColor: Colors.green.withOpacity(0.8),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  side: accountController.authorizationAction ==
                                          AuthorizationAction.login
                                      ? const BorderSide(
                                          width: 2.0, color: Colors.redAccent)
                                      : BorderSide.none,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.rightToBracket,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(height: 3.0),
                                  AutoSizeText(
                                    'Авторизация',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                                          email: emailController
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
                                      const SizedBox(height: 15.0),
                                      smallHelperPanel(
                                        context: context,
                                        icon: FontAwesomeIcons.circleInfo,
                                        text:
                                            'Указывайте существующую почту, на неё будет отправлен код подтверждения.',
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
                                                    .copyWith(fontSize: 12.0)),
                                            TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () =>
                                                    Navigator.of(context)
                                                        .pushNamed(
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
    );
  }
}
