import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final user = UserModel(
        id: response.user!.id,
        name: name,
        email: email,
        password: password,
      );

      // Insert into public.users table
      await _supabase.from(AppConstants.usersTable).insert(user.toJson());
      return user;
    }
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from(AppConstants.usersTable)
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      // Auto-repair missing profiles caused by previous RLS errors
      final newUser = UserModel(
        id: user.id,
        name: user.email?.split('@')[0] ?? 'User',
        email: user.email ?? '',
      );
      await _supabase.from(AppConstants.usersTable).insert(newUser.toJson());
      return newUser;
    }

    return UserModel.fromJson(data);
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
  }) async {
    await _supabase.from(AppConstants.usersTable).update({
      'name': name,
    }).eq('id', userId);
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
