import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});

  Future<UserModel> register({
    required String username,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({String? fullName, String? avatarUrl});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final String finalEmail = '${username.trim().toLowerCase()}@lemon.com';

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
      'username': username.trim().toLowerCase(),
      'full_name': response.user!.userMetadata?['full_name'] as String?,
    });

    return UserModel(
      id: response.user!.id,
      username: username.trim().toLowerCase(),
      fullName: response.user!.userMetadata?['full_name'] as String?,
    );
  }

  @override
  Future<UserModel> register({
    required String username,
    required String password,
    required String fullName,
  }) async {
    final String finalEmail = '${username.trim().toLowerCase()}@lemon.com';
    
    final response = await supabaseClient.auth.signUp(
      email: finalEmail,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) {
      throw Exception('Registration failed: User is null');
    }

    // Also insert into our public 'users' table using upsert to avoid duplicate key errors
    await supabaseClient.from('users').upsert({
      'id': response.user!.id,
      'username': username.trim().toLowerCase(),
      'full_name': fullName,
    });

    return UserModel(
      id: response.user!.id,
      username: username.trim().toLowerCase(),
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

    // Fetch username from public table
    final userData = await supabaseClient
        .from('users')
        .select('username')
        .eq('id', user.id)
        .single();

    return UserModel(
      id: user.id,
      username: userData['username'] as String? ?? user.email!.split('@')[0],
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? avatarUrl}) async {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    final response = await supabaseClient.auth.updateUser(
      UserAttributes(data: data),
    );

    if (response.user == null) {
      throw Exception('Update failed: User is null');
    }

    // Sync to public.users table
    final Map<String, dynamic> publicData = {'id': response.user!.id};
    if (fullName != null) publicData['full_name'] = fullName;
    if (avatarUrl != null) publicData['avatar_url'] = avatarUrl;

    await supabaseClient.from('users').upsert(publicData);

    // Get current username for the model return
    final userData = await supabaseClient
        .from('users')
        .select('username')
        .eq('id', response.user!.id)
        .single();

    return UserModel(
      id: response.user!.id,
      username: userData['username'] as String? ?? response.user!.email!.split('@')[0],
      fullName: response.user!.userMetadata?['full_name'] as String?,
      avatarUrl: response.user!.userMetadata?['avatar_url'] as String?,
    );
  }
}
