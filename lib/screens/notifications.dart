import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/notifications/friend_code_moneys_model.dart';
import 'package:new_mini_casino/widgets/notifications/news_model.dart';
import 'package:new_mini_casino/widgets/notifications/premium_gift_model.dart';
import 'package:new_mini_casino/widgets/notifications/transfer_moneys_model.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext mainContext) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, child) {
        return notificationController.isLoading
            ? loading(context: context)
            : Scaffold(
                appBar: AppBar(
                  toolbarHeight: 76.0,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  title: AutoSizeText(
                    'Уведомления',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Beamer.of(context).beamBack();
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Colors.redAccent,
                            size: 30.0,
                          )),
                    ),
                  ],
                ),
                body: StreamBuilder(
                  stream: SupabaseController.supabase
                      ?.from('notifications')
                      .stream(primaryKey: ['id']).inFilter('to', [
                    ProfileController.profileModel.nickname,
                    'all'
                  ]).order('date'),
                  builder: (context, snapshot) {
                    notificationController.mainContext = mainContext;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loading(context: context);
                    }

                    List<Map<dynamic, dynamic>> map =
                        snapshot.data as List<Map<dynamic, dynamic>>;

                    return map.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: smallHelperPanel(
                                context: context,
                                icon: FontAwesomeIcons.solidBellSlash,
                                text: 'Новых уведомлений нет',
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: map.length,
                            itemBuilder: (context, index) {
                              String action = map[index]['action'];

                              return action == 'transfer_moneys'
                                  ? transferMoneysModel(
                                      notificationController:
                                          notificationController,
                                      context: context,
                                      docs: map[index])
                                  : action == 'friend_code_moneys'
                                      ? friendCodeMoneysModel(
                                          notificationController:
                                              notificationController,
                                          context: context,
                                          docs: map[index])
                                      : action == 'news'
                                          ? newsModel(
                                              notificationController:
                                                  notificationController,
                                              context: context,
                                              docs: map[index])
                                          : action == 'premium_gift'
                                              ? premiumGiftModel(
                                                  notificationController:
                                                      notificationController,
                                                  context: context,
                                                  docs: map[index])
                                              : Container();
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 15.0),
                          );
                  },
                ),
              );
      },
    );
  }
}
