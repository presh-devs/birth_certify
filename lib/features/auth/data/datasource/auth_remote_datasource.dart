class AuthRemoteDataSource {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    return email == 'presh@birthcertify.ng' && password == 'password123';
  }
}
