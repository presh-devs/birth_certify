
import 'package:birth_certify/features/registration/domain/models/registration_model.dart';

abstract class RegistrationRepository {
  Future<void> submitRegistration(RegistrationRequest request, String submittedBy);
}
