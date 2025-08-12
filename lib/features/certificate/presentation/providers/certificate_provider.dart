import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:birth_certify/features/registration/data/datasource/registration_firestore_datasource.dart';
import 'package:birth_certify/features/registration/data/repository/enhanced_registration_repository.dart';
import 'package:birth_certify/features/registration/domain/models/enhanced_registration_model.dart';
import 'package:birth_certify/features/storacha/data/repositories/storacha_repository_impl.dart';
import 'package:birth_certify/features/storacha/presentation/providers/storacha_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/certificate_repository_impl.dart';
import '../../domain/models/certificate_model.dart';
import '../../domain/repository/certificate_repository.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(CertificateFirestoreDatasource());
});

final certificateListProvider = FutureProvider<List<Certificate>>((ref) async {
  final repo = ref.read(certificateRepositoryProvider);
  return repo.fetchCertificates();
});

final addCertificateProvider = Provider.family<Future<void>, Certificate>((ref, cert) {
  final repo = ref.read(certificateRepositoryProvider);
  return repo.addCertificate(cert);
});


// Provider for the enhanced repository
final enhancedRegistrationRepositoryProvider = Provider<EnhancedRegistrationRepositoryImpl>((ref) {
  final storachaRepo = ref.read(storachaRepositoryProvider);
  return EnhancedRegistrationRepositoryImpl(
    firestore: RegistrationFirestoreDatasource(),
    certificates: CertificateFirestoreDatasource(),
    storacha: storachaRepo as StorachaRepositoryImpl,
  );
});

// Provider for submitting enhanced registration
final submitEnhancedRegistrationProvider = FutureProvider.family<RegistrationResult, ({
  EnhancedRegistrationRequest request,
  String submittedBy,
})>((ref, params) async {
  final repository = ref.read(enhancedRegistrationRepositoryProvider);
  return await repository.submitEnhancedRegistration(
    params.request,
    params.submittedBy,
  );
});

// State notifier for managing the registration flow
class EnhancedRegistrationController extends StateNotifier<AsyncValue<RegistrationResult?>> {
  final EnhancedRegistrationRepositoryImpl repository;

  EnhancedRegistrationController(this.repository) : super(const AsyncValue.data(null));

  Future<void> submitRegistration(EnhancedRegistrationRequest request, String submittedBy) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await repository.submitEnhancedRegistration(request, submittedBy);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final enhancedRegistrationControllerProvider = 
    StateNotifierProvider<EnhancedRegistrationController, AsyncValue<RegistrationResult?>>((ref) {
  final repository = ref.read(enhancedRegistrationRepositoryProvider);
  return EnhancedRegistrationController(repository);
});
