import '../models/registration_model.dart';

abstract class RegistrationRepository {
  Future<void> registerBirth(RegistrationRequest request);
}
