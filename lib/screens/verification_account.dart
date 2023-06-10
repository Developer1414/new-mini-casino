import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/models/loading.dart';

class VerificationAcount extends StatefulWidget {
  const VerificationAcount(
      {super.key,
      required this.email,
      required this.username,
      required this.isRegister});

  final String email;
  final String username;
  final String isRegister;

  @override
  State<VerificationAcount> createState() => _VerificationAcountState();
}

class _VerificationAcountState extends State<VerificationAcount> {
  TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: isLoading
          ? loading()
          : Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Проверьте свою электронную почту на наличие 6-значного кода для подтверждения!',
                      style: GoogleFonts.roboto(
                        color: Colors.black87.withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                          ],
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              hintText: '6-значный код...',
                              hintStyle: GoogleFonts.roboto(
                                  color: Colors.black87.withOpacity(0.5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.3))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.5)))),
                          style: GoogleFonts.roboto(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        height: 60.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () async {
                            if (codeController.text.isEmpty) return;

                            setState(() {
                              isLoading = true;
                            });

                            /*try {
                              await AccountController().verifyAccount(
                                  token: codeController.text,
                                  name: widget.username,
                                  isRegister: widget.isRegister,
                                  email: widget.email);
                            } on AuthException catch (e) {
                              if (kDebugMode) {
                                print(e.message);
                              }
                            }*/

                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: AutoSizeText(
                            'Подтвердить',
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
                  ],
                ),
              ),
            ),
    );
  }
}
