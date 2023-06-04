import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:platform_device_id/platform_device_id.dart';

class RaffleController {
  Future participate() async {
    String? deviceId = await PlatformDeviceId.getDeviceId;
    String? ipAddress = await IpAddress().getIpAddress();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'participant': true,
    });
  }
}
