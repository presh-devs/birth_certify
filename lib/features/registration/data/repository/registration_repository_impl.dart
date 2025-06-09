import '../../domain/models/registration_model.dart';
import '../../domain/repository/registration_repository.dart';
import '../datasource/registration_remote_datasource.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDataSource remote;

  RegistrationRepositoryImpl(this.remote);

  @override
  Future<void> registerBirth(RegistrationRequest request) {
    return remote.register(request);
  }
}
