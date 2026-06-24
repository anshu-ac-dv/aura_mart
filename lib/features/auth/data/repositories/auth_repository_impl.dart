import 'package:aura_mart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aura_mart/features/auth/domain/entities/user_entity.dart';
import 'package:aura_mart/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    return await remoteDataSource.signIn(email, password);
  }

  @override
  Future<UserEntity?> signUp(String email, String password, String name) async {
    return await remoteDataSource.signUp(email, password, name);
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get userStream => remoteDataSource.userStream;
}
