import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController referalCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AccountController.context = context;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Consumer<AccountController>(
        builder: (context, accountController, _) {
          return accountController.isLoading
              ? loading(text: accountController.loadingText, context: context)
              : DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    bottomNavigationBar: SizedBox(
                        height: accountController.authorizationAction ==
                                AuthorizationAction.register
                            ? 60
                            : 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              accountController.authorizationAction ==
                                      AuthorizationAction.login
                                  ? Container(height: 0.0)
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: RichText(
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
                                                    context.beamToNamed(
                                                        '/privacy-policy'),
                                              text:
                                                  'Политику Конфиденциальности',
                                              style: GoogleFonts.roboto(
                                                  textStyle: const TextStyle(
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue,
                                              )),
                                            )
                                          ])),
                                    ),
                            ],
                          ),
                        )),
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      title: TabBar(
                        onTap: (index) {
                          accountController.changeAuthorizationAction(index);
                        },
                        tabs: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.userPlus,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .iconTheme!
                                      .color,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 10.0),
                                AutoSizeText('Регистрация',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 20.0)),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.rightToBracket,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .iconTheme!
                                      .color,
                                  size: 20.0,
                                ),
                                const SizedBox(width: 10.0),
                                AutoSizeText('Вход',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 20.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0, top: 30.0),
                                child: Image(
                                    image: AssetImage(
                                        'assets/other_images/${DarkThemeProvider().darkTheme ? 'DarkLogo' : 'logo'}.png'),
                                    width: 300.0,
                                    height: 300.0)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                accountController.authorizationAction ==
                                        AuthorizationAction.register
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0,
                                            right: 15.0,
                                            bottom: 15.0,
                                            top: 15.0),
                                        child: loginCustomTextField(
                                            context: context,
                                            keyboardType: TextInputType.name,
                                            limitSymbols: true,
                                            controller: nameController,
                                            hintText: 'Никнейм...'),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                  ),
                                  child: loginCustomTextField(
                                      context: context,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: emailController,
                                      hintText: 'Почта...'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0, top: 15.0),
                                  child: loginCustomTextField(
                                      context: context,
                                      keyboardType: TextInputType.text,
                                      controller: passwordController,
                                      isLastInput: true,
                                      isPassword: true,
                                      hintText: 'Пароль...'),
                                ),
                                /*accountController.authorizationAction ==
                                          AuthorizationAction.register
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              right: 15.0,
                                              top: 15.0),
                                          child: loginCustomTextField(
                                              keyboardType: TextInputType.text,
                                              controller: referalCode,
                                              hintText: 'Реферальный код...'),
                                        )
                                      : Container(),*/
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    height: 60.0,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (accountController
                                                .authorizationAction ==
                                            AuthorizationAction.register) {
                                          if (accountController
                                                  .authorizationAction ==
                                              AuthorizationAction.register) {
                                            if (nameController.text.isEmpty) {
                                              QuickAlert.show(
                                                  context: context,
                                                  type: QuickAlertType.error,
                                                  title: 'Упс...',
                                                  text:
                                                      'Вы не вписали никнейм!',
                                                  confirmBtnText: 'Окей',
                                                  animType: QuickAlertAnimType
                                                      .slideInDown);

                                              return;
                                            }
                                          }
                                        }

                                        if (emailController.text.isEmpty) {
                                          QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              title: 'Упс...',
                                              text: 'Вы не вписали почту!',
                                              confirmBtnText: 'Окей',
                                              animType: QuickAlertAnimType
                                                  .slideInDown);

                                          return;
                                        }

                                        if (passwordController.text.isEmpty) {
                                          QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              title: 'Упс...',
                                              text: 'Вы не вписали пароль!',
                                              confirmBtnText: 'Окей',
                                              animType: QuickAlertAnimType
                                                  .slideInDown);

                                          return;
                                        }

                                        if (passwordController.text.length <
                                            6) {
                                          QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              title: 'Упс...',
                                              text: 'Пароль слишком короткий!',
                                              confirmBtnText: 'Окей',
                                              animType: QuickAlertAnimType
                                                  .slideInDown);

                                          return;
                                        }

                                        if (accountController
                                                .authorizationAction ==
                                            AuthorizationAction.register) {
                                          if (nameController.text.length < 4) {
                                            AccountExceptionController
                                                .showException(
                                                    context: context,
                                                    code: 'nickname_too_short');

                                            return;
                                          }

                                          await accountController
                                              .checkOnExistNickname(
                                                  nameController.text.trim())
                                              .then((value) async {
                                            if (!value) {
                                              AccountExceptionController
                                                  .showException(
                                                      context: context,
                                                      code:
                                                          'nickname_already_exist');
                                              return;
                                            } else {
                                              await accountController.register(
                                                  email: emailController.text
                                                      .trim(),
                                                  password:
                                                      passwordController.text,
                                                  name: nameController.text
                                                      .trim(),
                                                  referalCode:
                                                      referalCode.text);
                                            }
                                          });
                                        } else {
                                          await accountController.login(
                                              email:
                                                  emailController.text.trim(),
                                              password:
                                                  passwordController.text);
                                        }
                                      },
                                      child: AutoSizeText(
                                        accountController.authorizationAction ==
                                                AuthorizationAction.register
                                            ? 'Зарегистрироваться'
                                            : 'Войти',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      accountController.authorizationAction ==
                                          AuthorizationAction.register,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0, bottom: 15.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                              color: Colors.orangeAccent,
                                              width: 2.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                            'Указывайте существующую почту, на неё будет отправлена ссылка для подтверждения.',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(fontSize: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget loginCustomTextField(
      {required String hintText,
      required TextEditingController controller,
      required BuildContext context,
      bool isLastInput = false,
      bool readOnly = false,
      bool limitSymbols = false,
      TextInputType? keyboardType,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      inputFormatters: limitSymbols
          ? [
              LengthLimitingTextInputFormatter(12),
              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9]'))
            ]
          : null,
      textInputAction:
          isLastInput ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .color!
                  .withOpacity(0.5)),
          enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder),
      style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 20.0),
    );
  }
}
