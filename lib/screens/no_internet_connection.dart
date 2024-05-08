import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/widgets/loading.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: isLoading
          ? loading(context: context)
          : Scaffold(
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await Connectivity().checkConnectivity().then((value) {
                        if (value.index == 1) {
                           Navigator.of(context).pop();
                        }
                      });

                      setState(() {
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: AutoSizeText(
                        'Переподключиться',
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
              body: Center(
                  child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Theme.of(context).appBarTheme.iconTheme?.color,
                      size: 80.0,
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 5.0),
                      child: AutoSizeText(
                          'Проблемы с подключением к интернету!',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                    ),
                    AutoSizeText(
                        'Проверьте подключение к Интернету и подключитесь повторно.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12.0,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .color!
                                .withOpacity(0.4))),
                  ],
                ),
              )),
            ),
    );
  }
}
