import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phoneNumber,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // Implementasi panggilan HTTP / Firebase / Supabase
    return UserModel(
      id: 'USR-001',
      name: 'User Demo',
      email: email,
      role: UserRole.pengguna,
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phoneNumber,
  }) async {
    return UserModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return null;
  }

  @override
  Future<void> logout() async {
    // Clear token / session
  }
}
