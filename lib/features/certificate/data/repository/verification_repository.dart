// lib/features/certificate/data/repository/verification_repository_impl.dart
import 'package:birth_certify/features/certificate/presentation/providers/verification_providers.dart';

import '../datasource/verification_datasource.dart';

class VerificationRepositoryImpl {
  final VerificationDatasource datasource;

  VerificationRepositoryImpl(this.datasource);

  Future<VerificationResult> verifyCertificateById(String certificateId) async {
    try {
      print('🔍 Repository: Verifying certificate ID: $certificateId');
      
      // Debug the certificate first
      await datasource.debugCertificateId(certificateId);
      
      // Try to find the certificate
      final certificateData = await datasource.getCertificateById(certificateId);
      
      if (certificateData == null) {
        print('❌ Repository: Certificate not found');
        return VerificationResult.failure('Certificate not found with ID: $certificateId');
      }

      print('✅ Repository: Certificate found, creating result...');
      final certificate = Certificate.fromJson(certificateData);

      // Extract additional info if available
      String? certificateUrl = certificateData['certificate_url'];
      NFTInfo? nftInfo;

      if (certificateData['nft_token_id'] != null) {
        nftInfo = NFTInfo.fromJson(certificateData);
      }

      return VerificationResult.success(
        certificate: certificate,
        certificateUrl: certificateUrl,
        nftInfo: nftInfo,
      );
    } catch (e) {
      print('❌ Repository: Verification failed with error: $e');
      return VerificationResult.failure('Verification failed: $e');
    }
  }

  Future<VerificationResult> verifyCertificateByCid(String cid) async {
    try {
      print('🔍 Repository: Verifying certificate CID: $cid');
      
      // Try to find the certificate by IPFS CID
      final certificateData = await datasource.getCertificateByCid(cid);
      
      if (certificateData == null) {
        print('❌ Repository: Certificate not found by CID');
        return VerificationResult.failure('Certificate not found with CID: $cid');
      }

      print('✅ Repository: Certificate found by CID, creating result...');
      final certificate = Certificate.fromJson(certificateData);

      // Build the IPFS gateway URL
      String certificateUrl = 'https://$cid.ipfs.storacha.link';

      NFTInfo? nftInfo;
      if (certificateData['nft_token_id'] != null) {
        nftInfo = NFTInfo.fromJson(certificateData);
      }

      return VerificationResult.success(
        certificate: certificate,
        certificateUrl: certificateUrl,
        nftInfo: nftInfo,
      );
    } catch (e) {
      print('❌ Repository: CID verification failed with error: $e');
      return VerificationResult.failure('Verification failed: $e');
    }
  }

  // Method to fix missing certificate IDs (run this once to fix your data)
  Future<void> fixCertificateIds() async {
    await datasource.fixCertificateIds();
  }
}