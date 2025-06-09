import '../models/certificate_model.dart';

abstract class CertificateRepository {
  Future<List<Certificate>> fetchCertificates();
}
