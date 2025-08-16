// lib/features/certificate/presentation/providers/enhanced_certificate_provider.dart
import 'package:birth_certify/features/certificate/data/repository/enhanced_certificate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/enhanced_certificate_datasource.dart';

// Enhanced Certificate Model with blockchain info
class EnhancedCertificate {
  final String name;
  final String dateOfBirth;
  final String placeOfBirth;
  final String nin;
  final DateTime registeredAt;
  final String? registrationId;
  final String? certificateId;
  final String? certificateCid;
  final String? certificateUrl;
  final String? metadataCid;
  final String? metadataUrl;
  final String? supportingDocumentCid;
  final String? supportingDocumentUrl;
  final int? nftTokenId;
  final String? nftTransactionHash;
  final String? nftContractAddress;
  final String? nftOwnerAddress;
  final bool blockchainVerified;
  final String status;

  EnhancedCertificate({
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nin,
    required this.registeredAt,
    this.registrationId,
    this.certificateId,
    this.certificateCid,
    this.certificateUrl,
    this.metadataCid,
    this.metadataUrl,
    this.supportingDocumentCid,
    this.supportingDocumentUrl,
    this.nftTokenId,
    this.nftTransactionHash,
    this.nftContractAddress,
    this.nftOwnerAddress,
    this.blockchainVerified = false,
    this.status = 'active',
  });

  factory EnhancedCertificate.fromJson(Map<String, dynamic> json) {
    return EnhancedCertificate(
      name: json['name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? '',
      nin: json['nin'] ?? '',
      registeredAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      registrationId: json['registration_id'],
      certificateId: json['certificate_id'],
      certificateCid: json['certificate_cid'],
      certificateUrl: json['certificate_url'],
      metadataCid: json['metadata_cid'],
      metadataUrl: json['metadata_url'],
      supportingDocumentCid: json['supporting_document_cid'],
      supportingDocumentUrl: json['supporting_document_url'],
      nftTokenId: json['nft_token_id'],
      nftTransactionHash: json['nft_transaction_hash'],
      nftContractAddress: json['nft_contract_address'],
      nftOwnerAddress: json['nft_owner_address'],
      blockchainVerified: json['blockchain_verified'] ?? false,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth,
      'place_of_birth': placeOfBirth,
      'nin': nin,
      'created_at': registeredAt.toIso8601String(),
      'registration_id': registrationId,
      'certificate_id': certificateId,
      'certificate_cid': certificateCid,
      'certificate_url': certificateUrl,
      'metadata_cid': metadataCid,
      'metadata_url': metadataUrl,
      'supporting_document_cid': supportingDocumentCid,
      'supporting_document_url': supportingDocumentUrl,
      'nft_token_id': nftTokenId,
      'nft_transaction_hash': nftTransactionHash,
      'nft_contract_address': nftContractAddress,
      'nft_owner_address': nftOwnerAddress,
      'blockchain_verified': blockchainVerified,
      'status': status,
    };
  }
}

// Repository provider
final enhancedCertificateRepositoryProvider = Provider<EnhancedCertificateRepositoryImpl>((ref) {
  return EnhancedCertificateRepositoryImpl(EnhancedCertificateDatasource());
});

// Enhanced certificate list provider
final enhancedCertificateListProvider = FutureProvider<List<EnhancedCertificate>>((ref) async {
  final repository = ref.read(enhancedCertificateRepositoryProvider);
  return await repository.getEnhancedCertificates();
});

// Provider for getting certificate by ID
final enhancedCertificateByIdProvider = FutureProvider.family<EnhancedCertificate?, String>((ref, certificateId) async {
  final repository = ref.read(enhancedCertificateRepositoryProvider);
  return await repository.getCertificateById(certificateId);
});

// Provider for getting certificates with pagination
final paginatedCertificatesProvider = FutureProvider.family<PaginatedCertificates, PaginationParams>((ref, params) async {
  final repository = ref.read(enhancedCertificateRepositoryProvider);
  return await repository.getPaginatedCertificates(params);
});

// Pagination models
class PaginationParams {
  final int page;
  final int limit;
  final String? searchQuery;
  final String? filter;

  PaginationParams({
    required this.page,
    required this.limit,
    this.searchQuery,
    this.filter,
  });
}

class PaginatedCertificates {
  final List<EnhancedCertificate> certificates;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  PaginatedCertificates({
    required this.certificates,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}