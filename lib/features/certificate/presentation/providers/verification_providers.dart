// lib/features/certificate/presentation/providers/verification_provider.dart
import 'package:birth_certify/features/certificate/data/repository/verification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/verification_datasource.dart';

// Verification result model
class VerificationResult {
  final bool isValid;
  final Certificate? certificate;
  final String? certificateUrl;
  final NFTInfo? nftInfo;
  final String? error;

  VerificationResult({
    required this.isValid,
    this.certificate,
    this.certificateUrl,
    this.nftInfo,
    this.error,
  });

  factory VerificationResult.success({
    required Certificate certificate,
    String? certificateUrl,
    NFTInfo? nftInfo,
  }) {
    return VerificationResult(
      isValid: true,
      certificate: certificate,
      certificateUrl: certificateUrl,
      nftInfo: nftInfo,
    );
  }

  factory VerificationResult.failure(String error) {
    return VerificationResult(
      isValid: false,
      error: error,
    );
  }
}

// NFT Info model
class NFTInfo {
  final int tokenId;
  final String transactionHash;
  final String contractAddress;
  final String ownerAddress;

  NFTInfo({
    required this.tokenId,
    required this.transactionHash,
    required this.contractAddress,
    required this.ownerAddress,
  });

  factory NFTInfo.fromJson(Map<String, dynamic> json) {
    return NFTInfo(
      tokenId: _parseToInt(json['nft_token_id']),
      transactionHash: json['nft_transaction_hash']?.toString() ?? '',
      contractAddress: json['nft_contract_address']?.toString() ?? '',
      ownerAddress: json['nft_owner_address']?.toString() ?? '',
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// Certificate model with better error handling
class Certificate {
  final String name;
  final String dateOfBirth;
  final String placeOfBirth;
  final String nin;
  final DateTime registeredAt;
  final String? registrationId;

  Certificate({
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nin,
    required this.registeredAt,
    this.registrationId,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Creating Certificate from JSON: ${json.keys.toList()}');
      
      // Parse the date with better error handling
      DateTime parsedDate;
      try {
        final dateString = json['created_at'] ?? json['submitted_at'];
        if (dateString != null) {
          parsedDate = DateTime.parse(dateString);
        } else {
          parsedDate = DateTime.now();
        }
      } catch (e) {
        print('⚠️ Date parsing failed, using current date: $e');
        parsedDate = DateTime.now();
      }

      final certificate = Certificate(
        name: json['name']?.toString() ?? 'Unknown',
        dateOfBirth: json['date_of_birth']?.toString() ?? json['dateOfBirth']?.toString() ?? 'Unknown',
        placeOfBirth: json['place_of_birth']?.toString() ?? json['placeOfBirth']?.toString() ?? 'Unknown',
        nin: json['nin']?.toString() ?? json['motherNIN']?.toString() ?? json['fatherNIN']?.toString() ?? 'Unknown',
        registeredAt: parsedDate,
        registrationId: json['registration_id']?.toString(),
      );

      print('✅ Certificate created successfully');
      return certificate;
    } catch (e) {
      print('❌ Error creating Certificate from JSON: $e');
      print('📄 JSON data: $json');
      
      // Return a fallback certificate to prevent crashes
      return Certificate(
        name: 'Error parsing certificate',
        dateOfBirth: 'Unknown',
        placeOfBirth: 'Unknown',
        nin: 'Unknown',
        registeredAt: DateTime.now(),
        registrationId: json['registration_id']?.toString(),
      );
    }
  }
}

// Repository provider
final verificationRepositoryProvider = Provider<VerificationRepositoryImpl>((ref) {
  return VerificationRepositoryImpl(VerificationDatasource());
});

// Verification providers with timeout
final verifyCertificateByIdProvider = FutureProvider.family<VerificationResult, String>((ref, certificateId) async {
  try {
    print('🚀 Starting verification for: $certificateId');
    final repository = ref.read(verificationRepositoryProvider);
    
    // Add timeout to prevent hanging
    final result = await repository.verifyCertificateById(certificateId)
        .timeout(const Duration(seconds: 30));
    
    print('🎉 Verification completed successfully');
    return result;
  } catch (e) {
    print('❌ Verification failed: $e');
    return VerificationResult.failure('Verification failed: $e');
  }
});

final verifyCertificateByCidProvider = FutureProvider.family<VerificationResult, String>((ref, cid) async {
  try {
    print('🚀 Starting CID verification for: $cid');
    final repository = ref.read(verificationRepositoryProvider);
    
    // Add timeout to prevent hanging
    final result = await repository.verifyCertificateByCid(cid)
        .timeout(const Duration(seconds: 30));
    
    print('🎉 CID verification completed successfully');
    return result;
  } catch (e) {
    print('❌ CID verification failed: $e');
    return VerificationResult.failure('CID verification failed: $e');
  }
});