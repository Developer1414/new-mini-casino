import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/controllers/online_games_controller.dart';
import 'package:new_mini_casino/controllers/online_games_logic/online_crash_logic.dart';
import 'package:new_mini_casino/controllers/online_games_logic/online_slide_logic.dart';
import 'package:new_mini_casino/widgets/menu_game_button.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';

class OnlineGamesMainPage extends StatelessWidget {
  const OnlineGamesMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Navigator.of(context).pop();
              },
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: Theme.of(context).appBarTheme.iconTheme!.size,
              )),
        ),
        title: AutoSizeText(
          'Онлайн-игры',
          maxLines: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              smallHelperPanel(
                context: context,
                icon: FontAwesomeIcons.triangleExclamation,
                text:
                    'Онлайн-игры находятся на стадии бета-тестирования и могут функционировать с некоторыми проблемами или нестабильностью.',
              ),
              const SizedBox(height: 15.0),
              GridView.custom(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  childCount: OnlineGamesController.games.length,
                  (context, index) => gameButtonModel(
                      context: context,
                      gameLogo: OnlineGamesController.games[index].gameLogo,
                      forPremium: OnlineGamesController.games[index].forPremium,
                      isNew: OnlineGamesController.games[index].isNew,
                      buttonTitle: OnlineGamesController.games[index].title,
                      onTap: () {
                        switch (OnlineGamesController.games[index].title) {
                          case 'Crash':
                            Provider.of<OnlineCrashLogic>(context,
                                    listen: false)
                                .connectToGame();
                            break;
                          case 'Slide':
                            Provider.of<OnlineSlideLogic>(context,
                                    listen: false)
                                .connectToGame();
                            break;
                        }

                        Navigator.of(context).pushNamed(
                            OnlineGamesController.games[index].nextScreen);
                      },
                      buttonColor:
                          OnlineGamesController.games[index].buttonColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25.0))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
