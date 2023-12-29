import 'package:flutter/foundation.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendCodeController {
  Future<bool> findFriendCode(String friendCode) async {
    int count = 0;

    try {
      final res = await SupabaseController.supabase!
          .from('users')
          .select(
            'uid',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('uid', friendCode);

      count = res.count;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('checkFriendCodeOnExist: $e');
      }
    }

    return count > 0;
  }
}
