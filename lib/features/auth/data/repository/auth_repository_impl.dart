import 'package:birth_certify/features/auth/data/datasource/auth_remote_datasource.dart';

import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<bool> login(String email, String password) {
    return remote.login(email, password);
  }

  @override
  Future<bool> logout() {
    return remote.logout();
  }
}
