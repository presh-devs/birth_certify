import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/certificate_repository_impl.dart';
import '../../domain/models/certificate_model.dart';
import '../../domain/repository/certificate_repository.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(CertificateRemoteDataSource());
});

final certificateListProvider = FutureProvider<List<Certificate>>((ref) async {
  final repository = ref.read(certificateRepositoryProvider);
  return repository.fetchCertificates();
});
