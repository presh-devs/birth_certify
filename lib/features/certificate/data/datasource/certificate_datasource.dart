// lib/features/certificate/data/datasource/certificate_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/certificate_model.dart';
import '../../../storacha/data/models/storacha_models.dart';

class CertificateFirestoreDatasource {
  final _collection = FirebaseFirestore.instance.collection('certificates');

  Future<void> addCertificate(Certificate cert) async {
    await _collection.add(cert.toJson());
  }

  Future<List<Certificate>> getCertificates() async {
    final snapshot =
        await _collection.orderBy('created_at', descending: true).get();
    if (snapshot.docs.isEmpty) {
      print('Empty certificate collection');
    }
    // Debugging: Print the number of certificates fetched
    final certificates =
        snapshot.docs.map((doc) => Certificate.fromJson(doc.data())).toList();
    print(certificates.length);
    return snapshot.docs
        .map((doc) => Certificate.fromJson(doc.data()))
        .toList();
  }

  Future<void> createCertificateFromRegistration({
    required String registrationId,
    required String name,
    required String dob,
    required String placeOfBirth,
    required String nin,
  }) async {
    await _collection.add({
      'registration_id': registrationId,
      'name': name,
      'date_of_birth': dob,
      'place_of_birth': placeOfBirth,
      'nin': nin,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Enhanced method for creating certificates with blockchain info
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

    await _collection.add(certificateData);
  }

  // Additional enhanced methods for better certificate management
  Future<void> updateCertificateBlockchainInfo({
    required String registrationId,
    required String certificateCid,
    required String certificateUrl,
    NFTData? nftInfo,
  }) async {
    final query =
        await _collection
            .where('registration_id', isEqualTo: registrationId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final updateData = {
        'certificate_cid': certificateCid,
        'certificate_url': certificateUrl,
        'blockchain_verified': nftInfo != null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nftInfo != null) {
        updateData.addAll({
          'nft_token_id': nftInfo.tokenId,
          'nft_transaction_hash': nftInfo.transactionHash,
          'nft_contract_address': nftInfo.contractAddress,
          'nft_owner_address': nftInfo.ownerAddress,
          'nft_minted_at': DateTime.now().toIso8601String(),
        });
      }

      await query.docs.first.reference.update(updateData);
    }
  }

  Future<Map<String, dynamic>?> getCertificateByRegistrationId(
    String registrationId,
  ) async {
    try {
      final query =
          await _collection
              .where('registration_id', isEqualTo: registrationId)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting certificate by registration ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCertificateByCertificateId(
    String certificateId,
  ) async {
    try {
      final query =
          await _collection
              .where('certificate_id', isEqualTo: certificateId)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting certificate by certificate ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCertificatesWithBlockchainInfo() async {
    try {
      final snapshot =
          await _collection
              .where('blockchain_verified', isEqualTo: true)
              .orderBy('created_at', descending: true)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error getting certificates with blockchain info: $e');
      return [];
    }
  }

  Future<int> getCertificateCount() async {
    try {
      final snapshot = await _collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting certificate count: $e');
      return 0;
    }
  }

  Future<int> getBlockchainVerifiedCount() async {
    try {
      final snapshot =
          await _collection
              .where('blockchain_verified', isEqualTo: true)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting blockchain verified count: $e');
      return 0;
    }
  }

  Future<int> getNFTMintedCount() async {
    try {
      final snapshot =
          await _collection
              .where('nft_token_id', isNotEqualTo: null)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting NFT minted count: $e');
      return 0;
    }
  }
}
