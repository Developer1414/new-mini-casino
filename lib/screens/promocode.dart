import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:new_mini_casino/widgets/loading.dart';
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
              ? loading(context: context)
              : Scaffold(
                  bottomSheet: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
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
                                title: Promocode.promocodeController.text);

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
                          icon: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
                          )),
                    ),
                    title: AutoSizeText(
                      'Промокод',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: IconButton(
                            splashRadius: 25.0,
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                context.beamToNamed('/own-promocode'),
                            icon: FaIcon(
                              FontAwesomeIcons.plus,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme!
                                  .color,
                              size: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme!
                                  .copyWith(size: 28.0)
                                  .size,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              context.beamToNamed('/my-promocodes'),
                          icon: FaIcon(
                            FontAwesomeIcons.bars,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context)
                                .appBarTheme
                                .iconTheme!
                                .copyWith(size: 28.0)
                                .size,
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
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontSize: 30.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color!
                                            .withOpacity(0.5)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.5, color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.5,
                                        color: Colors.transparent))),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 30.0),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 12.0)),
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
