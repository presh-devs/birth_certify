// lib/features/certificate/data/repository/enhanced_certificate_repository_impl.dart
import 'package:birth_certify/features/certificate/presentation/providers/enhanced_certificate_providers.dart';

import '../datasource/enhanced_certificate_datasource.dart';

class EnhancedCertificateRepositoryImpl {
  final EnhancedCertificateDatasource datasource;

  EnhancedCertificateRepositoryImpl(this.datasource);

  Future<List<EnhancedCertificate>> getEnhancedCertificates() async {
    try {
      return await datasource.getEnhancedCertificates();
    } catch (e) {
      throw Exception('Repository: Failed to get enhanced certificates - $e');
    }
  }

  Future<EnhancedCertificate?> getCertificateById(String certificateId) async {
    try {
      return await datasource.getCertificateById(certificateId);
    } catch (e) {
      throw Exception('Repository: Failed to get certificate by ID - $e');
    }
  }

  Future<PaginatedCertificates> getPaginatedCertificates(PaginationParams params) async {
    try {
      return await datasource.getPaginatedCertificates(params);
    } catch (e) {
      throw Exception('Repository: Failed to get paginated certificates - $e');
    }
  }

  Future<void> updateCertificateStatus(String certificateId, String status) async {
    try {
      await datasource.updateCertificateStatus(certificateId, status);
    } catch (e) {
      throw Exception('Repository: Failed to update certificate status - $e');
    }
  }

  Future<List<EnhancedCertificate>> searchCertificates(String searchQuery) async {
    try {
      return await datasource.searchCertificates(searchQuery);
    } catch (e) {
      throw Exception('Repository: Failed to search certificates - $e');
    }
  }

  Future<Map<String, int>> getCertificateStats() async {
    try {
      return await datasource.getCertificateStats();
    } catch (e) {
      throw Exception('Repository: Failed to get certificate stats - $e');
    }
  }
}