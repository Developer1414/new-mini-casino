import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Promocode extends StatefulWidget {
  const Promocode({super.key});

  static TextEditingController promocodeController = TextEditingController();

  @override
  State<Promocode> createState() => _PromocodeState();
}

class _PromocodeState extends State<Promocode> {
  @override
  Widget build(BuildContext context) {
    void unfocus() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    return GestureDetector(
      onTap: () => unfocus(),
      child: Consumer<PromocodeManager>(
        builder: (context, value, child) {
          return value.isLoading
              ? loading()
              : Scaffold(
                  bottomSheet: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          unfocus();

                          if (Promocode.promocodeController.text.isEmpty) {
                            return;
                          }

                          await value.usePromocode(
                              context: context,
                              myPromocode: Promocode.promocodeController.text);

                          Promocode.promocodeController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor:
                              const Color.fromARGB(255, 100, 34, 255),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                        ),
                        child: AutoSizeText(
                          'Использовать',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20.0,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  appBar: AppBar(
                    toolbarHeight: 76.0,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Beamer.of(context).beamBack();
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color: Colors.black87,
                            size: 30.0,
                          )),
                    ),
                    title: AutoSizeText(
                      'Промокод',
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: IconButton(
                            splashRadius: 25.0,
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                context.beamToNamed('/own-promocode'),
                            icon: const FaIcon(
                              FontAwesomeIcons.plus,
                              color: Colors.black87,
                              size: 28.0,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              context.beamToNamed('/my-promocodes'),
                          icon: const FaIcon(
                            FontAwesomeIcons.bars,
                            color: Colors.black87,
                            size: 28.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            controller: Promocode.promocodeController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                hintText: 'Ваш промокод...',
                                hintStyle: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.5),
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w700),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.5, color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.5,
                                        color: Colors.transparent))),
                            style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 30,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, bottom: 15.0),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Промокоды можно найти в нашем ',
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  )),
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (!await launchUrl(
                                          Uri.parse(
                                              'https://t.me/mini_casino_info'),
                                          mode: LaunchMode
                                              .externalNonBrowserApplication)) {
                                        throw Exception(
                                            'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                                      }
                                    },
                                  text: 'телеграм канале',
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  )),
                                )
                              ])),
                        ),
                      ],
                    ),
                  ));
        },
      ),
    );
  }
}
