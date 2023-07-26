import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class StoreProductReview extends StatelessWidget {
  const StoreProductReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreManager>(
      builder: (context, storeManager, _) {
        StoreItemModel storeItemModel = storeManager
            .stores[storeManager.selectedStore].models
            .where((element) => element.imageId == storeManager.selectedProduct)
            .first;

        storeManager.checkCarOnMine(storeItemModel.imageId);

        return storeManager.isLoading
            ? loading()
            : Scaffold(
                bottomNavigationBar: Container(
                  color: storeItemModel.color,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: SizedBox(
                      height: 60.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 60.0,
                            width: double.infinity,
                            child: FutureBuilder<bool>(
                                future: storeManager
                                    .checkCarOnMine(storeItemModel.imageId),
                                builder: (ctx, snapshot) {
                                  return ElevatedButton(
                                    onPressed: () async {
                                      if (snapshot.data!) {
                                        storeManager.sellProduct(
                                            context: context,
                                            carName: storeItemModel.title,
                                            carId: storeItemModel.imageId,
                                            price: storeItemModel.price);
                                      } else {
                                        storeManager.buyProduct(
                                            context: context,
                                            carName: storeItemModel.title,
                                            carId: storeItemModel.imageId,
                                            price: storeItemModel.price);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      backgroundColor: snapshot.data ?? false
                                          ? Colors.redAccent
                                          : Colors.green,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(25.0),
                                            topRight: Radius.circular(25.0)),
                                      ),
                                    ),
                                    child: snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const Padding(
                                            padding: EdgeInsets.all(18.0),
                                            child: SizedBox(
                                              width: 26.0,
                                              height: 26.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 5.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : AutoSizeText(
                                            '${snapshot.data ?? false ? 'Продать' : 'Купить'} за ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(snapshot.data ?? false ? (storeItemModel.price / 2) : AccountController.isPremium && storeItemModel.premium ? storeItemModel.price - (storeItemModel.price * 20 / 100) : storeItemModel.price)}',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w700,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 20.0,
                                                )
                                              ],
                                            ),
                                          ),
                                  );
                                }),
                          ),
                        ],
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
                    storeItemModel.title,
                    style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade50,
                            storeItemModel.color,
                          ],
                        )),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage(
                                  'assets/${storeManager.selectedPath}/${storeItemModel.imageId}.png',
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              storeItemModel.premium &&
                                      !AccountController.isPremium
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Colors.redAccent.withOpacity(0.4),
                                          border: Border.all(
                                              color: Colors.redAccent,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          'С Premium подпиской скидка 20% (можно купить за: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(storeItemModel.price - (storeItemModel.price * 20 / 100))})',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w700,
                                          )),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
