import 'package:birth_certify/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<bool> logout();
  Future<UserModel?> fetchCurrentUserDetails();
}
