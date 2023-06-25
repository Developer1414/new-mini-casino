import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import 'package:new_mini_casino/screens/banned_user.dart';

class FreeraspService {
  void errorDetected(BuildContext context, String error) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => BannedUser(
            reason: error, date: DateTime.now(), isBannedAccount: false)));
  }

  Future<void> initSecurityState(BuildContext context) async {
    TalsecConfig config = TalsecConfig(
      androidConfig: AndroidConfig(
          packageName: 'com.revens.mini.casino',
          signingCertHashes: ['SmdUsJDwb6ZlkQS+B2iQKpRVeQsKsIgbO5uEA4tkiJU=']),
      watcherMail: 'develope14000@gmail.com',
    );

    ThreatCallback callback = ThreatCallback(
        onHooks: () => errorDetected(context, 'Hooks detected'),
        onAppIntegrity: () => errorDetected(context, 'onAppIntegrity'),
        onObfuscationIssues: () => errorDetected(context, 'Obfuscation issues'),
        onDebug: () {
          if (kDebugMode) {
            print("Debugging");
          }
        },
        onDeviceBinding: () => errorDetected(context, 'Device binding'),
        onPrivilegedAccess: () => errorDetected(context,
            'На вашем устройстве были обнаружены повышенные права. Возможно, у вас установлены Root-права и т.д. Если это так, пожалуйста, удалите их, иначе вы не сможете использовать это приложение.'),
        /* onSecureHardwareNotAvailable: () =>
            print("Secure hardware not available"),*/
        onSimulator: () {
          if (kDebugMode) {
            print("Simulator detected");
          }
        },
        onUnofficialStore: () => errorDetected(context, 'Unofficial store'));

    Talsec.instance.attachListener(callback);
    await Talsec.instance.start(config);
  }
}