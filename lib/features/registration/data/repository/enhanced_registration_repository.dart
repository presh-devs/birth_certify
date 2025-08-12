
import 'package:birth_certify/features/certificate/data/datasource/enhanced_certificate_datasource.dart';

import '../../domain/models/enhanced_registration_model.dart';
import '../../../storacha/data/repositories/storacha_repository_impl.dart';
import '../../../certificate/data/datasource/certificate_datasource.dart';
import '../datasource/registration_firestore_datasource.dart';

class EnhancedRegistrationRepositoryImpl {
  final RegistrationFirestoreDatasource firestore;
  final CertificateFirestoreDatasource certificates;
  final StorachaRepositoryImpl storacha;

  EnhancedRegistrationRepositoryImpl({
    required this.firestore,
    required this.certificates,
    required this.storacha,
  });

  Future<RegistrationResult> submitEnhancedRegistration(
    EnhancedRegistrationRequest request,
    String submittedBy,
  ) async {
    try {
      // 1. Submit to Storacha backend (generates PDF, uploads to IPFS, mints NFT)
      final storachaResponse = await storacha.submitBirthRegistration(
        birthData: request.toJson(),
        supportingDocument: request.supportingDocument,
      );

      // 2. Save to Firestore with additional blockchain info
      final registrationData = request.toJson()
        ..addAll({
          'submitted_at': DateTime.now().toIso8601String(),
          'submitted_by': submittedBy,
          'certificate_cid': storachaResponse.certificate.cid,
          'certificate_url': storachaResponse.certificate.gatewayUrl,
          'metadata_cid': storachaResponse.metadata.cid,
          'metadata_url': storachaResponse.metadata.gatewayUrl,
          'supporting_document_cid': storachaResponse.supportingDocument?.cid,
          'supporting_document_url': storachaResponse.supportingDocument?.gatewayUrl,
          'nft_token_id': storachaResponse.nft?.tokenId,
          'nft_transaction_hash': storachaResponse.nft?.transactionHash,
          'nft_contract_address': storachaResponse.nft?.contractAddress,
          'nft_owner_address': storachaResponse.nft?.ownerAddress,
        });

      final regId = await firestore.submitAndGetId(
        // Convert back to your original RegistrationRequest format
        OriginalRegistrationRequest(
          firstName: request.firstName,
          middleName: request.middleName,
          lastName: request.lastName,
          placeOfBirth: request.placeOfBirth,
          dateOfBirth: request.dateOfBirth,
          motherFirstName: request.motherFirstName,
          motherLastName: request.motherLastName,
          fatherFirstName: request.fatherFirstName,
          fatherLastName: request.fatherLastName,
          motherNIN: request.motherNIN,
          fatherNIN: request.fatherNIN,
          wallet: request.wallet,
          documentUrl: storachaResponse.certificate.gatewayUrl,
        ),
        submittedBy,
      );

      // 3. Create certificate record with blockchain info
      await certificates.createEnhancedCertificateFromRegistration(
        registrationId: regId,
        name: '${request.firstName} ${request.lastName}',
        dob: request.dateOfBirth,
        placeOfBirth: request.placeOfBirth,
        nin: request.motherNIN,
        certificateCid: storachaResponse.certificate.cid,
        certificateUrl: storachaResponse.certificate.gatewayUrl,
        nftInfo: storachaResponse.nft,
      );

      // 4. Return comprehensive result
      return RegistrationResult(
        success: true,
        certificateId: storachaResponse.certificateId,
        certificateCid: storachaResponse.certificate.cid,
        certificateUrl: storachaResponse.certificate.gatewayUrl,
        metadataCid: storachaResponse.metadata.cid,
        metadataUrl: storachaResponse.metadata.gatewayUrl,
        supportingDocumentCid: storachaResponse.supportingDocument?.cid,
        supportingDocumentUrl: storachaResponse.supportingDocument?.gatewayUrl,
        nftInfo: storachaResponse.nft != null 
            ? NFTInfo(
                tokenId: storachaResponse.nft!.tokenId,
                transactionHash: storachaResponse.nft!.transactionHash,
                contractAddress: storachaResponse.nft!.contractAddress,
                ownerAddress: storachaResponse.nft!.ownerAddress,
              )
            : null,
        registeredAt: storachaResponse.registeredAt,
      );

    } catch (e) {
      throw Exception('Enhanced registration failed: $e');
    }
  }
}

// Helper class to maintain compatibility with your existing code
class OriginalRegistrationRequest {
  final String firstName;
  final String middleName;
  final String lastName;
  final String placeOfBirth;
  final String dateOfBirth;
  final String motherFirstName;
  final String motherLastName;
  final String fatherFirstName;
  final String fatherLastName;
  final String motherNIN;
  final String fatherNIN;
  final String wallet;
  final String? documentUrl;

  OriginalRegistrationRequest({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.motherFirstName,
    required this.motherLastName,
    required this.fatherFirstName,
    required this.fatherLastName,
    required this.motherNIN,
    required this.fatherNIN,
    required this.wallet,
    this.documentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'placeOfBirth': placeOfBirth,
      'dateOfBirth': dateOfBirth,
      'motherFirstName': motherFirstName,
      'motherLastName': motherLastName,
      'fatherFirstName': fatherFirstName,
      'fatherLastName': fatherLastName,
      'motherNIN': motherNIN,
      'fatherNIN': fatherNIN,
      'wallet': wallet,
      'documentUrl': documentUrl,
    };
  }
}
