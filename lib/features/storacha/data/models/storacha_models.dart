// lib/features/storacha/data/models/storacha_models.dart
class StorachaUploadResponse {
  final bool success;
  final String certificateId;
  final CertificateData certificate;
  final CertificateImageData certificateImage; // 👈 Updated field name
  final MetadataData metadata;
  final SupportingDocumentData? supportingDocument;
  final NFTData? nft;
  final String registeredAt;

  StorachaUploadResponse({
    required this.success,
    required this.certificateId,
    required this.certificate,
    required this.certificateImage,
    required this.metadata,
    this.supportingDocument,
    this.nft,
    required this.registeredAt,
  });

  factory StorachaUploadResponse.fromJson(Map<String, dynamic> json) {
    return StorachaUploadResponse(
      success: json['success'] ?? false,
      certificateId: json['certificateId'] ?? '',
      certificate: CertificateData.fromJson(json['certificate']),
      certificateImage: CertificateImageData.fromJson(json['certificateImage']), // 👈 Updated
      metadata: MetadataData.fromJson(json['metadata']),
      supportingDocument: json['supportingDocument'] != null
          ? SupportingDocumentData.fromJson(json['supportingDocument'])
          : null,
      nft: json['nft'] != null ? NFTData.fromJson(json['nft']) : null,
      registeredAt: json['registeredAt'] ?? '',
    );
  }
}

class CertificateData {
  final String cid;
  final String gatewayUrl;
  final String ipfsUrl;

  CertificateData({
    required this.cid,
    required this.gatewayUrl,
    required this.ipfsUrl,
  });

  factory CertificateData.fromJson(Map<String, dynamic> json) {
    return CertificateData(
      cid: json['cid'] ?? '',
      gatewayUrl: json['gatewayUrl'] ?? '',
      ipfsUrl: json['ipfsUrl'] ?? '',
    );
  }
}

class CertificateImageData {
  final String cid;
  final String gatewayUrl;
  final String ipfsUrl;

  CertificateImageData({
    required this.cid,
    required this.gatewayUrl,
    required this.ipfsUrl,
  });

  factory CertificateImageData.fromJson(Map<String, dynamic> json) {
    return CertificateImageData(
      cid: json['cid'] ?? '',
      gatewayUrl: json['gatewayUrl'] ?? '',
      ipfsUrl: json['ipfsUrl'] ?? '',
    );
  }
}

class MetadataData {
  final String cid;
  final String gatewayUrl;
  final String ipfsUrl;

  MetadataData({
    required this.cid,
    required this.gatewayUrl,
    required this.ipfsUrl,
  });

  factory MetadataData.fromJson(Map<String, dynamic> json) {
    return MetadataData(
      cid: json['cid'] ?? '',
      gatewayUrl: json['gatewayUrl'] ?? '',
      ipfsUrl: json['ipfsUrl'] ?? '',
    );
  }
}

class SupportingDocumentData {
  final String cid;
  final String gatewayUrl;
  final String ipfsUrl;

  SupportingDocumentData({
    required this.cid,
    required this.gatewayUrl,
    required this.ipfsUrl,
  });

  factory SupportingDocumentData.fromJson(Map<String, dynamic> json) {
    return SupportingDocumentData(
      cid: json['cid'] ?? '',
      gatewayUrl: json['gatewayUrl'] ?? '',
      ipfsUrl: json['ipfsUrl'] ?? '',
    );
  }
}

class NFTData {
  final int tokenId;
  final String transactionHash;
  final String contractAddress;
  final String ownerAddress;
  final String? imageUrl; // 👈 NEW: Direct NFT image URL
  final String? metadataUrl; // 👈 NEW: NFT metadata URL

  NFTData({
    required this.tokenId,
    required this.transactionHash,
    required this.contractAddress,
    required this.ownerAddress,
    this.imageUrl,
    this.metadataUrl,
  });

  factory NFTData.fromJson(Map<String, dynamic> json) {
    return NFTData(
      tokenId: json['tokenId'] ?? 0,
      transactionHash: json['transactionHash'] ?? '',
      contractAddress: json['contractAddress'] ?? '',
      ownerAddress: json['ownerAddress'] ?? '',
      imageUrl: json['imageUrl'], // 👈 NEW
      metadataUrl: json['metadataUrl'], // 👈 NEW
    );
  }
}

class WalletData {
  final String address;
  final String? privateKey;
  final String? mnemonic;

  WalletData({
    required this.address,
    this.privateKey,
    this.mnemonic,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      address: json['address'] ?? '',
      privateKey: json['privateKey'],
      mnemonic: json['mnemonic'],
    );
  }
}