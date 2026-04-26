import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collex/core/constants/app_constants.dart';

void main() {
  test('Supabase Connection Test', () async {
    final supabase = SupabaseClient(
      AppConstants.supabaseUrl,
      AppConstants.supabaseAnonKey,
    );
    
    try {
      final response = await supabase.from(AppConstants.usersTable).select().limit(1);
      print('Connection successful: $response');
      expect(response, isNotNull);
    } catch (e) {
      fail('Database test failed: $e');
    }
});
}
