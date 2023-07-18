import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AdService {
  static int countBet = 0;

  static Future loadCountBet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('countBetForAd')) {
      countBet = prefs.getInt('countBetForAd')!;
    }
  }

  static Future showInterstitialAd(
      {required BuildContext context,
      required Function func,
      bool isBet = true}) async {
    if (AccountController.isPremium) {
      if (isBet) {
        LocalPromocodes().getPromocode(context);
      }

      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isBet) {
      countBet++;
      prefs.setInt('countBetForAd', countBet);

      if (countBet < 50) {
        return;
      }
    }

    var isCanShow = await Appodeal.canShow(AppodealAdType.Interstitial);
    var isLoaded = await Appodeal.isLoaded(AppodealAdType.Interstitial);

    Appodeal.setInterstitialCallbacks(
        onInterstitialLoaded: (isPrecache) => {},
        onInterstitialFailedToLoad: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Не удалось загрузить рекламу. Пожалуйста, попробуйте позже!',
              )
            },
        onInterstitialShowFailed: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Не удалось показать рекламу. Пожалуйста, попробуйте позже!',
              )
            },
        onInterstitialClosed: () {
          func.call();
          countBet = 0;

          if (isBet) {
            prefs.setInt('countBetForAd', 0);
          }
        },
        onInterstitialExpired: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Срок действия рекламы истек. Пожалуйста, попробуйте позже!',
              )
            });

    if (isCanShow && isLoaded) {
      Appodeal.show(AppodealAdType.Interstitial);
    }
  }

  static Future showRewardedAd(
      {required BuildContext context, required Function func}) async {
    var isCanShow = await Appodeal.canShow(AppodealAdType.RewardedVideo);
    var isLoaded = await Appodeal.isLoaded(AppodealAdType.RewardedVideo);

    Appodeal.setRewardedVideoCallbacks(
        onRewardedVideoLoaded: (isPrecache) => {},
        onRewardedVideoFailedToLoad: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Не удалось загрузить рекламу. Пожалуйста, попробуйте позже!',
              )
            },
        onRewardedVideoShowFailed: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Не удалось показать рекламу. Пожалуйста, попробуйте позже!',
              )
            },
        onRewardedVideoFinished: (_, value) => func.call(),
        onRewardedVideoExpired: () => {
              alertDialogError(
                context: context,
                title: 'Ошибка',
                text:
                    'Срок действия рекламы истек. Пожалуйста, попробуйте позже!',
              )
            });

    if (isCanShow && isLoaded) {
      Appodeal.show(AppodealAdType.RewardedVideo);
    }
  }
}
