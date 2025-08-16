
// final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
//   return EnRegistrationRepositoryImpl(
//     RegistrationFirestoreDatasource(),
//     CertificateFirestoreDatasource(),
//   );
// });

// final submitRegistrationProvider = Provider.family<Future<void>, (RegistrationRequest, String)>((ref, data) {
//   final repo = ref.read(registrationRepositoryProvider);
//   final (request, submittedBy) = data;
//   return repo.submitRegistration(request, submittedBy);
// });

