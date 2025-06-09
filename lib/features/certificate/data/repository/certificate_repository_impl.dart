// import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
// import '../../domain/models/certificate_model.dart';
// import '../../domain/repository/certificate_repository.dart';

// class CertificateRepositoryImpl implements CertificateRepository {
//   final CertificateRemoteDataSource remote;

//   CertificateRepositoryImpl(this.remote);

//   @override
//   Future<List<Certificate>> fetchCertificates() {
//     return remote.fetchCertificates();
//   }
// }


import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';

import '../../domain/models/certificate_model.dart';
import '../../domain/repository/certificate_repository.dart';
class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateFirestoreDatasource datasource;

  CertificateRepositoryImpl(this.datasource);

  @override
  Future<void> addCertificate(Certificate cert) {
    return datasource.addCertificate(cert);
  }

  @override
  Future<List<Certificate>> fetchCertificates() {
    return datasource.getCertificates();
  }
}
