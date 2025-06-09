import '../models/certificate_model.dart';

abstract class CertificateRepository {
  Future<void> addCertificate(Certificate cert);
  Future<List<Certificate>> fetchCertificates();
}
