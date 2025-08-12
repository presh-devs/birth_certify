// lib/features/certificate/data/datasource/enhanced_certificate_datasource.dart
import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../storacha/data/models/storacha_models.dart';

extension EnhancedCertificateFirestoreDatasource on CertificateFirestoreDatasource {
  Future<void> createEnhancedCertificateFromRegistration({
    required String registrationId,
    required String name,
    required String dob,
    required String placeOfBirth,
    required String nin,
    required String certificateCid,
    required String certificateUrl,
    NFTData? nftInfo,
  }) async {
    final certificateData = {
      'registration_id': registrationId,
      'name': name,
      'date_of_birth': dob,
      'place_of_birth': placeOfBirth,
      'nin': nin,
      'certificate_cid': certificateCid,
      'certificate_url': certificateUrl,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'active',
      'blockchain_verified': nftInfo != null,
    };

    if (nftInfo != null) {
      certificateData.addAll({
        'nft_token_id': nftInfo.tokenId,
        'nft_transaction_hash': nftInfo.transactionHash,
        'nft_contract_address': nftInfo.contractAddress,
        'nft_owner_address': nftInfo.ownerAddress,
        'nft_minted_at': DateTime.now().toIso8601String(),
      });
    }

    await FirebaseFirestore.instance
        .collection('certificates')
        .add(certificateData);
  }
}