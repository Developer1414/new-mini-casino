// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:freerasp/freerasp.dart';
// import 'package:new_mini_casino/screens/banned_user.dart';

// class FreeraspService {
//   void errorDetected(BuildContext context, String error) {
//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (ctx) => BannedUser(
//             reason: error, date: DateTime.now(), isBannedAccount: false)));
//   }

//   Future<void> initSecurityState(BuildContext context) async {
//     TalsecConfig config = TalsecConfig(
//       androidConfig: AndroidConfig(
//           packageName: 'com.revens.mini.casino',
//           signingCertHashes: ['SmdUsJDwb6ZlkQS+B2iQKpRVeQsKsIgbO5uEA4tkiJU=']),
//       watcherMail: 'develope14000@gmail.com',
//     );

//     ThreatCallback callback = ThreatCallback(
//       onHooks: () => errorDetected(context, 'Hooks detected'),
//       onAppIntegrity: () => errorDetected(context, 'onAppIntegrity'),
//       onUnofficialStore: () => errorDetected(context, 'Unofficial store'),
//       onObfuscationIssues: () => errorDetected(context, 'Obfuscation issues'),
//       onDebug: () {
//         exit(0);
//       },
//       onDeviceBinding: () => errorDetected(context, 'Device binding'),
//       onPrivilegedAccess: () => errorDetected(context,
//           'На вашем устройстве были обнаружены повышенные права. Возможно, у вас установлены Root-права и т.д. Если это так, пожалуйста, удалите их, иначе вы не сможете использовать это приложение.'),
//       onSecureHardwareNotAvailable: () {
//         if (kDebugMode) {
//           print("Secure hardware not available");
//         }
//       },
//       onSimulator: () {
//         errorDetected(
//           context,
//           """Уведомление о нарушении правил

// Мы заметили, что вы используете эмулятор в игре, что противоречит нашим правилам. В целях поддержания честной и равной среды для всех участников, использование любых эмуляторов в игре строго запрещено.""",
//         );
//       },
//     );

//     Talsec.instance.attachListener(callback);
//     await Talsec.instance.start(config);
//   }
// }
