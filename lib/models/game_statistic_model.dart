class GameStatisticModel {
  int totalGames;
  int winGamesCount;
  double winningsMoneys;
  double lossesMoneys;
  double maxWin;
  double maxLoss;

  GameStatisticModel(
      {this.totalGames = 0,
      this.winningsMoneys = 0.0,
      this.maxWin = 0.0,
      this.winGamesCount = 0,
      this.maxLoss = 0.0,
      this.lossesMoneys = 0.0});
}
