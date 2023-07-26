import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';

class StoreItems extends StatefulWidget {
  const StoreItems({super.key});

  @override
  State<StoreItems> createState() => _StoreItemsState();
}

class _StoreItemsState extends State<StoreItems> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                    title: AutoSizeText(
                      StoreManager.showOnlyMyItems ? 'Имущество' : 'Магазин',
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: GridView.custom(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15),
                      childrenDelegate: SliverChildBuilderDelegate(
                          childCount: storeManager.stores.length,
                          (context, index) {
                        return ElevatedButton(
                          onPressed: storeManager.stores[index].isSoon
                              ? null
                              : () {
                                  storeManager.selectStore(
                                      id: index,
                                      path:
                                          storeManager.stores[index].pathTitle);

                                  Beamer.of(context).beamToNamed(
                                      '/store/${storeManager.stores[index].title}/${storeManager.stores[index].pathTitle}/${storeManager.stores[index].imagesCount}/${jsonEncode(storeManager.stores[index].models)}');
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor:
                                storeManager.stores[index].buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  storeManager.stores[index].icon,
                                  color: Colors.white,
                                  size: 40.0,
                                ),
                                const SizedBox(height: 10.0),
                                AutoSizeText(
                                  storeManager.stores[index].title,
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w800),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
