// lib/features/registration/domain/models/enhanced_registration_model.dart
import 'dart:io';

class EnhancedRegistrationRequest {
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
  final File? supportingDocument;

  EnhancedRegistrationRequest({
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
    this.supportingDocument,
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
    };
  }
}

class RegistrationResult {
  final bool success;
  final String certificateId;
  final String certificateCid;
  final String certificateUrl;
  final String? certificateImageCid; // 👈 NEW: Image CID
  final String? certificateImageUrl; // 👈 NEW: Image URL
  final String? metadataCid;
  final String? metadataUrl;
  final String? supportingDocumentCid;
  final String? supportingDocumentUrl;
  final NFTInfo? nftInfo;
  final String registeredAt;

  RegistrationResult({
    required this.success,
    required this.certificateId,
    required this.certificateCid,
    required this.certificateUrl,
    this.certificateImageCid, // 👈 NEW
    this.certificateImageUrl, // 👈 NEW
    this.metadataCid,
    this.metadataUrl,
    this.supportingDocumentCid,
    this.supportingDocumentUrl,
    this.nftInfo,
    required this.registeredAt,
  });

  factory RegistrationResult.fromStorachaResponse(Map<String, dynamic> json) {
    return RegistrationResult(
      success: json['success'] ?? false,
      certificateId: json['certificateId'] ?? '',
      certificateCid: json['certificate']['cid'] ?? '',
      certificateUrl: json['certificate']['gatewayUrl'] ?? '',
      certificateImageCid: json['certificateImage']?['cid'], // 👈 NEW
      certificateImageUrl: json['certificateImage']?['gatewayUrl'], // 👈 NEW
      metadataCid: json['metadata']?['cid'],
      metadataUrl: json['metadata']?['gatewayUrl'],
      supportingDocumentCid: json['supportingDocument']?['cid'],
      supportingDocumentUrl: json['supportingDocument']?['gatewayUrl'],
      nftInfo: json['nft'] != null ? NFTInfo.fromJson(json['nft']) : null,
      registeredAt: json['registeredAt'] ?? '',
    );
  }
}

class NFTInfo {
  final int tokenId;
  final String transactionHash;
  final String contractAddress;
  final String ownerAddress;
  final String? imageUrl; // 👈 NEW: Direct NFT image URL
  final String? metadataUrl; // 👈 NEW: NFT metadata URL

  NFTInfo({
    required this.tokenId,
    required this.transactionHash,
    required this.contractAddress,
    required this.ownerAddress,
    this.imageUrl, // 👈 NEW
    this.metadataUrl, // 👈 NEW
  });

  factory NFTInfo.fromJson(Map<String, dynamic> json) {
    return NFTInfo(
      tokenId: json['tokenId'] ?? 0,
      transactionHash: json['transactionHash'] ?? '',
      contractAddress: json['contractAddress'] ?? '',
      ownerAddress: json['ownerAddress'] ?? '',
      imageUrl: json['imageUrl'], // 👈 NEW
      metadataUrl: json['metadataUrl'], // 👈 NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'transactionHash': transactionHash,
      'contractAddress': contractAddress,
      'ownerAddress': ownerAddress,
      'imageUrl': imageUrl, // 👈 NEW
      'metadataUrl': metadataUrl, // 👈 NEW
    };
  }
}