import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Store extends StatelessWidget {
  const Store(
      {super.key,
      required this.storeName,
      required this.path,
      required this.models});

  final String storeName;
  final String path;
  final List<StoreItemModel> models;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => Beamer.of(context).beamBack(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<StoreManager>(
          builder: (context, storeManager, _) {
            return storeManager.isLoading
                ? loading()
                : Scaffold(
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            storeName,
                            style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900),
                          ),
                          Consumer<Balance>(builder: (ctx, balance, _) {
                            return AutoSizeText(
                              balance.currentBalanceString,
                              style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w900),
                            );
                          }),
                        ],
                      ),
                    ),
                    body: StoreManager.showOnlyBuyedItems
                        ? FutureBuilder(
                            future: storeManager.loadMyItems(path),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return loading();
                              }
                              return snapshot.data!.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: AutoSizeText(
                                          'У вас ещё нет имущества «$storeName».',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              color: Colors.black87
                                                  .withOpacity(0.4),
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )
                                  : loadItems(
                                      storeManager: storeManager,
                                      list: snapshot.data ?? [],
                                      onlyMyItems: true);
                            })
                        : loadItems(storeManager: storeManager),
                  );
          },
        ),
      ),
    );
  }

  Widget loadItems(
      {required StoreManager storeManager,
      List<int>? list,
      bool onlyMyItems = false}) {
    return GridView.custom(
      padding: const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15),
      childrenDelegate: SliverChildBuilderDelegate(
          childCount: onlyMyItems ? list!.length : models.length,
          (context, index) {
        StoreItemModel storeItemModel = models
            .where((element) =>
                element.imageId == (onlyMyItems ? list![index] : index))
            .first;

        return Material(
          clipBehavior: Clip.antiAlias,
          color: storeItemModel.color,
          borderRadius: BorderRadius.circular(15.0),
          elevation: 5.0,
          shadowColor: storeItemModel.color,
          child: InkWell(
            onTap: () {
              storeManager.selectStoreProduct(storeItemModel.imageId);
              Beamer.of(context).beamToNamed('/product-review');
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    storeItemModel.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(
                        'assets/$path/${storeItemModel.imageId}.png',
                      ),
                      width: path != 'pins' ? null : 100.0,
                      height: path != 'pins' ? null : 100.0,
                    ),
                  ),
                  onlyMyItems
                      ? Container()
                      : AutoSizeText(
                          NumberFormat.simpleCurrency(
                                  locale: ui.Platform.localeName)
                              .format(AccountController.isPremium &&
                                      storeItemModel.premium
                                  ? storeItemModel.price -
                                      (storeItemModel.price * 20 / 100)
                                  : storeItemModel.price),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900),
                        ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
