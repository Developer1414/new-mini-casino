import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/notification_service.dart';
import 'package:ntp/ntp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderDayController {
  static Future createNewLeader({
    required double bet,
    required double profit,
    required String gameName,
    required BuildContext context,
  }) async {
    try {
      await SupabaseController.supabase!
          .from('leader_day')
          .select('*')
          .eq('id', 1)
          .then((value) async {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;
        DateTime leaderDate = DateTime.parse('${map['date']}');

        if (leaderDate.day == DateTime.now().toUtc().day &&
            leaderDate.month == DateTime.now().toUtc().month) {
          if (double.parse(map['profit'].toString()) > profit) {
            return;
          } else {
            await create(
                bet: bet, profit: profit, gameName: gameName, context: context);
          }
        } else {
          await create(
              bet: bet, profit: profit, gameName: gameName, context: context);
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print('leaderDayError: $e');
      }
    }
  }

  static Future create({
    required double bet,
    required double profit,
    required String gameName,
    required BuildContext context,
  }) async {
    const path =
        '/storage/emulated/0/Android/data/com.revens.mini.casino/images/';

    String fileName = '${DateTime.now().microsecondsSinceEpoch}.png';

    Directory directory = Directory(path);

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    Uint8List? captured = await screenshotController.capture();

    File file = File('$path$fileName');
    file.writeAsBytes(captured!);

    // Uint8List bytes = await screenshotController.captureFromWidget(Stack(
    //   alignment: AlignmentDirectional.center,
    //   children: [
    //     Image.memory(captured!),
    //     Opacity(
    //       opacity: 0.5,
    //       child: Transform.translate(
    //         offset: const Offset(60.0, -120.0),
    //         child: Transform.rotate(
    //           angle: 0.3,
    //           child: Container(
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(15.0),
    //                 color: Colors.blueAccent),
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(
    //                   vertical: 10.0, horizontal: 10.0),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   AutoSizeText(
    //                     ProfileController.profileModel.nickname,
    //                     textAlign: TextAlign.center,
    //                     style: GoogleFonts.roboto(
    //                       color: Colors.white,
    //                       fontSize: 20.0,
    //                       letterSpacing: 0.5,
    //                       fontWeight: FontWeight.w900,
    //                     ),
    //                   ),
    //                   AutoSizeText(
    //                     'Игра: ${gameName[0].toUpperCase()}${gameName.substring(1)}',
    //                     textAlign: TextAlign.center,
    //                     style: GoogleFonts.roboto(
    //                       color: Colors.white,
    //                       fontSize: 15.0,
    //                       letterSpacing: 0.5,
    //                       fontWeight: FontWeight.w900,
    //                     ),
    //                   ),
    //                   AutoSizeText(
    //                     'Ставка: ${bet < 100000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(bet) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(bet)}',
    //                     textAlign: TextAlign.center,
    //                     style: GoogleFonts.roboto(
    //                       color: Colors.white,
    //                       fontSize: 10.0,
    //                       letterSpacing: 0.5,
    //                       fontWeight: FontWeight.w900,
    //                     ),
    //                   ),
    //                   AutoSizeText(
    //                     'Выигрыш: ${profit < 100000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(profit) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(profit)}',
    //                     textAlign: TextAlign.center,
    //                     style: GoogleFonts.roboto(
    //                       color: Colors.white,
    //                       fontSize: 10.0,
    //                       letterSpacing: 0.5,
    //                       fontWeight: FontWeight.w900,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // ));

    //await screenshotController.captureAndSave(path, fileName: fileName);

    if (context.mounted) {
      NotificationService.showInAppNotification(
        context: context,
        title: 'Поздравляем!',
        notificationType: NotificationType.success,
        content: 'Вы стали лидером дня!',
      );
    }

    DateTime dateTimeNow = await NTP.now();
    dateTimeNow = dateTimeNow.toUtc();

    await SupabaseController.supabase!.from('leader_day').update({
      'name': ProfileController.profileModel.nickname,
      'profit': profit,
      'bet': bet,
      'game': gameName,
      'date': dateTimeNow.toIso8601String(),
      'uid': SupabaseController.supabase!.auth.currentUser!.id,
    }).eq('id', 1);

    await SupabaseController.supabase!.storage.from('leader').update(
        'leader.png', file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

    await file.delete();
  }
}
