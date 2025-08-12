
// lib/features/storacha/data/repositories/storacha_repository_impl.dart
import 'dart:io';
import '../../domain/repository/storacha_repository.dart';
import '../datasources/storacha_datasource.dart';
import '../models/storacha_models.dart';

class StorachaRepositoryImpl implements StorachaRepository {
  final StorachaDatasource datasource;
  
  StorachaRepositoryImpl(this.datasource);
  
  @override
  Future<StorachaUploadResponse> submitBirthRegistration({
    required Map<String, dynamic> birthData,
    File? supportingDocument,
  }) async {
    return await datasource.submitBirthRegistration(
      birthData: birthData,
      supportingDocument: supportingDocument,
    );
  }
  
  @override
  Future<WalletData> generateWallet() async {
    return await datasource.generateWallet();
  }
  
  @override
  Future<Map<String, dynamic>> verifyNFT(int tokenId) async {
    return await datasource.verifyNFT(tokenId);
  }
  
  @override
  Future<Map<String, dynamic>> getHealthStatus() async {
    return await datasource.getHealthStatus();
  }
}