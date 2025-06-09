import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:birth_certify/features/registration/domain/models/registration_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/registration_firestore_datasource.dart';
import '../../data/repository/registration_repository_impl.dart';
import '../../domain/repository/registration_repository.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepositoryImpl(
    RegistrationFirestoreDatasource(),
    CertificateFirestoreDatasource(),
  );
});

final submitRegistrationProvider = Provider.family<Future<void>, (RegistrationRequest, String)>((ref, data) {
  final repo = ref.read(registrationRepositoryProvider);
  final (request, submittedBy) = data;
  return repo.submitRegistration(request, submittedBy);
});

