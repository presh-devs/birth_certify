
import 'package:birth_certify/features/auth/domain/repository/auth_repository.dart';

import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<bool> login(String email, String password) {
    return remote.login(email, password);
  }
}
