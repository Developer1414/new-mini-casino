import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<AccountController>(
          builder: (context, accountController, _) {
            return accountController.isLoading
                ? loading()
                : DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      bottomNavigationBar: SizedBox(
                          height: accountController.authorizationAction ==
                                  AuthorizationAction.register
                              ? 140
                              : 95,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 15.0),
                                  child: SizedBox(
                                    height: 65.0,
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
                                                  text: 'Вы не вписали имя!',
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
                                          await accountController.register(
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text,
                                              name: nameController.text.trim());
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
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                                                style: GoogleFonts.roboto(
                                                    textStyle: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                              ),
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
                        title: TabBar(
                          onTap: (index) {
                            accountController.changeAuthorizationAction(index);
                          },
                          tabs: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.userPlus,
                                    color: Colors.black87,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  AutoSizeText(
                                    'Регистрация',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.rightToBracket,
                                    color: Colors.black87,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  AutoSizeText(
                                    'Вход',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 30.0),
                            child: AutoSizeText(
                              'Добро пожаловать!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
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
                                            keyboardType: TextInputType.name,
                                            controller: Login.nameController,
                                            hintText: 'Имя...'),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0, bottom: 15.0),
                                  child: loginCustomTextField(
                                      keyboardType: TextInputType.emailAddress,
                                      controller: Login.emailController,
                                      hintText: 'Почта...'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  child: loginCustomTextField(
                                      keyboardType: TextInputType.text,
                                      controller: Login.passwordController,
                                      isLastInput: true,
                                      hintText: 'Пароль...'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget loginCustomTextField(
      {required String hintText,
      required TextEditingController controller,
      bool isLastInput = false,
      bool readOnly = false,
      TextInputType? keyboardType,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      textInputAction:
          isLastInput ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
              color: Colors.black87.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w700),
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(
                  width: 2.5, color: Colors.black87.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(
                  width: 2.5, color: Colors.black87.withOpacity(0.5)))),
      style: GoogleFonts.roboto(
          color: Colors.black87.withOpacity(0.7),
          fontSize: 20,
          fontWeight: FontWeight.w700),
    );
  }
}
