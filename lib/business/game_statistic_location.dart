import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/screens/game_statistic.dart';

class GameStatisticLocation extends BeamLocation<BeamState> {
  GameStatisticLocation(BeamState state) : super();

  @override
  List<Pattern> get pathPatterns => ['/game-statistic/:game'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    List<BeamPage> pages = [];

    final String? gameName = this.state.pathParameters['game'];

    print(gameName);

    if (gameName != null) {
      pages.add(
        BeamPage(
          child: GameStatistic(game: gameName),
        ),
      );
    }
    return pages;
  }
}
