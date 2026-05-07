import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    String finalEmail = email.trim();
    if (!finalEmail.contains('@')) {
      // For convenience, if no @ is provided, assume it's the test domain
      finalEmail = '$finalEmail@lemon.com';
    }

    final response = await supabaseClient.auth.signInWithPassword(
      email: finalEmail,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed: User is null');
    }

    // Sync to public.users table to ensure profile exists
    await supabaseClient.from('users').upsert({
      'id': response.user!.id,
      'full_name': response.user!.userMetadata?['full_name'] as String?,
    });

    return UserModel(
      id: response.user!.id,
      email: response.user!.email!,
      fullName: response.user!.userMetadata?['full_name'] as String?,
    );
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) {
      throw Exception('Registration failed: User is null');
    }

    // Also insert into our public 'users' table using upsert to avoid duplicate key errors
    await supabaseClient.from('users').upsert({
      'id': response.user!.id,
      'full_name': fullName,
    });

    return UserModel(
      id: response.user!.id,
      email: response.user!.email!,
      fullName: fullName,
    );
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }
}
