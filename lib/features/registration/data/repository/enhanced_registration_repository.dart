// lib/features/registration/data/repository/enhanced_registration_repository.dart

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

      // 2. Create the COMPLETE registration data for Firestore
      final completeRegistrationData = {
        // 👈 BASIC BIRTH INFORMATION
        'firstName': request.firstName,
        'middleName': request.middleName,
        'lastName': request.lastName,
        'dateOfBirth': request.dateOfBirth,
        'placeOfBirth': request.placeOfBirth,
        'motherFirstName': request.motherFirstName,
        'motherLastName': request.motherLastName,
        'fatherFirstName': request.fatherFirstName,
        'fatherLastName': request.fatherLastName,
        'motherNIN': request.motherNIN,
        'fatherNIN': request.fatherNIN,
        'wallet': request.wallet,
        
        // 👈 SUBMISSION METADATA
        'submitted_at': DateTime.now().toIso8601String(),
        'submitted_by': submittedBy,
        
        // 👈 CERTIFICATE DATA
        'certificate_id': storachaResponse.certificateId,
        'certificate_cid': storachaResponse.certificate.cid,
        'certificate_url': storachaResponse.certificate.gatewayUrl,
        'documentUrl': storachaResponse.certificate.gatewayUrl, // For compatibility
        
        // 👈 CERTIFICATE IMAGE DATA
        'certificate_image_cid': storachaResponse.certificateImage.cid,
        'certificate_image_url': storachaResponse.certificateImage.gatewayUrl,
        
        // 👈 METADATA
        'metadata_cid': storachaResponse.metadata.cid,
        'metadata_url': storachaResponse.metadata.gatewayUrl,
        
        // 👈 SUPPORTING DOCUMENT (nullable)
        'supporting_document_cid': storachaResponse.supportingDocument?.cid,
        'supporting_document_url': storachaResponse.supportingDocument?.gatewayUrl,
        
        // 👈 NFT DATA (nullable if minting failed)
        'nft_token_id': storachaResponse.nft?.tokenId,
        'nft_transaction_hash': storachaResponse.nft?.transactionHash,
        'nft_contract_address': storachaResponse.nft?.contractAddress,
        'nft_owner_address': storachaResponse.nft?.ownerAddress,
        'nft_image_url': storachaResponse.nft?.imageUrl,
        'nft_metadata_url': storachaResponse.nft?.metadataUrl,
      };

      // 3. Save the COMPLETE data to Firestore
      final regId = await firestore.submitCompleteRegistrationData(
        completeRegistrationData,
      );

      // 4. Create certificate record with blockchain info
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

      // 5. Return comprehensive result
      return RegistrationResult(
        success: true,
        certificateId: storachaResponse.certificateId,
        certificateCid: storachaResponse.certificate.cid,
        certificateUrl: storachaResponse.certificate.gatewayUrl,
        certificateImageCid: storachaResponse.certificateImage.cid,
        certificateImageUrl: storachaResponse.certificateImage.gatewayUrl,
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
                imageUrl: storachaResponse.nft!.imageUrl,
                metadataUrl: storachaResponse.nft!.metadataUrl,
              )
            : null,
        registeredAt: storachaResponse.registeredAt,
      );

    } catch (e) {
      throw Exception('Enhanced registration failed: $e');
    }
  }
}