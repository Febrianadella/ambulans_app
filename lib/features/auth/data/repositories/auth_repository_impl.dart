import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phoneNumber,
  }) async {
    return await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}
