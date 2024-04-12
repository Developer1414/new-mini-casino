import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInService {
  static Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        // serverClientId: APIKeys.googleSignInServerClientId,
        // clientId: APIKeys.googleSignInClientId,
      ).signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null || googleAuth.idToken == null) return;

      await SupabaseController.supabase!.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('LoginError: ${e.message}');
      }
    }
  }
}
