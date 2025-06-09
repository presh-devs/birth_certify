import '../../domain/models/registration_model.dart';

class RegistrationRemoteDataSource {
  Future<void> register(RegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 2));

    print("Simulating registration API call with: ${request.toJson()}");

    // In real app, use Dio/http to send request.toJson() to backend
  }
}
