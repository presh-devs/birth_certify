
// lib/features/storacha/presentation/providers/storacha_provider.dart
import 'dart:io';

import 'package:birth_certify/features/storacha/data/models/storacha_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../storacha/data/datasources/storacha_datasource.dart';
import '../../../storacha/data/repositories/storacha_repository_impl.dart';
import '../../../storacha/domain/repository/storacha_repository.dart';

final storachaDatasourceProvider = Provider<StorachaDatasource>((ref) {
  return StorachaDatasource();
});

final storachaRepositoryProvider = Provider<StorachaRepository>((ref) {
  final datasource = ref.read(storachaDatasourceProvider);
  return StorachaRepositoryImpl(datasource);
});

// Enhanced registration provider that includes Storacha integration
final submitRegistrationWithStorachaProvider = FutureProvider.family<StorachaUploadResponse, ({
  Map<String, dynamic> birthData,
  File? supportingDocument
})>((ref, params) async {
  final repository = ref.read(storachaRepositoryProvider);
  return await repository.submitBirthRegistration(
    birthData: params.birthData,
    supportingDocument: params.supportingDocument,
  );
});

final generateWalletProvider = FutureProvider<WalletData>((ref) async {
  final repository = ref.read(storachaRepositoryProvider);
  return await repository.generateWallet();
});

final healthStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(storachaRepositoryProvider);
  return await repository.getHealthStatus();
});
