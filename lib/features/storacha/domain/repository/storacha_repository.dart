// lib/features/storacha/domain/repository/storacha_repository.dart
import 'dart:io';
import '../../../storacha/data/models/storacha_models.dart';

abstract class StorachaRepository {
  Future<StorachaUploadResponse> submitBirthRegistration({
    required Map<String, dynamic> birthData,
    File? supportingDocument,
  });
  
  Future<WalletData> generateWallet();
  Future<Map<String, dynamic>> verifyNFT(int tokenId);
  Future<Map<String, dynamic>> getHealthStatus();
}