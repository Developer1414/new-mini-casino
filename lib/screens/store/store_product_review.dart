import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
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

        return storeManager.isLoading
            ? loading(context: context)
            : Scaffold(
                bottomNavigationBar: StoreManager.storeViewer ==
                        StoreViewer.otherUser
                    ? Container(
                        height: 0.0,
                      )
                    : Container(
                        color: storeItemModel.color,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: SizedBox(
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    storeManager.selectedPath != 'pins'
                                        ? Container()
                                        : FutureBuilder<bool>(
                                            future: storeManager
                                                .checkItemOnSelected(
                                                    itemId:
                                                        storeItemModel.imageId,
                                                    path: storeManager
                                                        .selectedPath),
                                            builder: (ctx, snapshot) {
                                              return snapshot.data ?? false
                                                  ? Container()
                                                  : Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 15.0),
                                                        child: SizedBox(
                                                          height: 60.0,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              storeManager.selectItem(
                                                                  itemId:
                                                                      storeItemModel
                                                                          .imageId,
                                                                  path: storeManager
                                                                      .selectedPath);
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 5,
                                                              backgroundColor: snapshot
                                                                          .data ??
                                                                      false
                                                                  ? Colors
                                                                      .redAccent
                                                                  : Colors
                                                                      .blueAccent,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            25.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            25.0)),
                                                              ),
                                                            ),
                                                            child: snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting
                                                                ? const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            18.0),
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          26.0,
                                                                      height:
                                                                          26.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            5.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : AutoSizeText(
                                                                    'Выбрать',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts
                                                                        .roboto(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          22.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                            }),
                                    Expanded(
                                      child: SizedBox(
                                        height: 60.0,
                                        child: FutureBuilder<bool>(
                                            future:
                                                storeManager.checkItemOnMine(
                                                    itemId:
                                                        storeItemModel.imageId,
                                                    path: storeManager
                                                        .selectedPath),
                                            builder: (ctx, snapshot) {
                                              return ElevatedButton(
                                                onPressed: () async {
                                                  if (snapshot.data ?? false) {
                                                    storeManager.sellProduct(
                                                        context: context,
                                                        itemName: storeItemModel
                                                            .title,
                                                        itemId: storeItemModel
                                                            .imageId,
                                                        price: storeItemModel
                                                            .price);
                                                  } else {
                                                    storeManager.buyProduct(
                                                        context: context,
                                                        itemName: storeItemModel
                                                            .title,
                                                        itemid: storeItemModel
                                                            .imageId,
                                                        price: storeItemModel
                                                            .price);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 5,
                                                  backgroundColor:
                                                      snapshot.data ?? false
                                                          ? Colors.redAccent
                                                          : Colors.green,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    25.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    25.0)),
                                                  ),
                                                ),
                                                child: snapshot
                                                            .connectionState ==
                                                        ConnectionState.waiting
                                                    ? const Padding(
                                                        padding: EdgeInsets.all(
                                                            18.0),
                                                        child: SizedBox(
                                                          width: 26.0,
                                                          height: 26.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 5.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          AutoSizeText(
                                                            snapshot.data ??
                                                                    false
                                                                ? 'Продать'
                                                                : 'Купить',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 22.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          AutoSizeText(
                                                            snapshot.data ??
                                                                    false
                                                                ? NumberFormat.simpleCurrency(
                                                                        locale: ui
                                                                            .Platform
                                                                            .localeName)
                                                                    .format(storeItemModel
                                                                            .price -
                                                                        (storeItemModel.price *
                                                                            20 /
                                                                            100))
                                                                : NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(SupabaseController
                                                                            .isPremium &&
                                                                        storeItemModel
                                                                            .premium
                                                                    ? storeItemModel
                                                                            .price -
                                                                        (storeItemModel.price *
                                                                            20 /
                                                                            100)
                                                                    : storeItemModel
                                                                        .price),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              );
                                            }),
                                      ),
                                    ),
                                  ],
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
                        icon: FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                  title: AutoSizeText(
                    storeItemModel.title,
                    style: Theme.of(context).appBarTheme.titleTextStyle,
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
                            Theme.of(context).scaffoldBackgroundColor,
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
                              StoreManager.storeViewer == StoreViewer.deafult &&
                                      storeItemModel.premium &&
                                      !SupabaseController.isPremium
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
