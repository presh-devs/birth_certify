// lib/features/registration/data/datasource/registration_firestore_datasource.dart
import 'package:birth_certify/features/registration/data/repository/enhanced_registration_repository.dart';
import 'package:birth_certify/features/registration/domain/models/registration_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationFirestoreDatasource {
  final _collection = FirebaseFirestore.instance.collection(
    'birth_registrations',
  );
  
  // 👈 NEW METHOD: Store complete registration data
  Future<String> submitCompleteRegistrationData(
    Map<String, dynamic> completeData,
  ) async {
    try {
      print('📝 Storing complete registration data to Firestore:');
      print('Certificate ID: ${completeData['certificate_id']}');
      print('NFT Token ID: ${completeData['nft_token_id']}');
      print('Certificate CID: ${completeData['certificate_cid']}');
      
      final docRef = await _collection.add(completeData);
      
      print('✅ Complete registration data stored with ID: ${docRef.id}');
      return docRef.id;
      
    } catch (e) {
      print('❌ Failed to store registration data: $e');
      rethrow;
    }
  }
  
  // 👈 LEGACY METHOD: Keep for backward compatibility
  // Future<String> submitAndGetId(
  //   OriginalRegistrationRequest request,
  //   String submittedBy,
  // ) async {
  //   final data = request.toJson()
  //     ..addAll({
  //       'submitted_at': DateTime.now().toIso8601String(),
  //       'submitted_by': submittedBy,
  //     });

  //   final docRef = await _collection.add(data);
  //   return docRef.id;
  // }

  // 👈 NEW METHOD: Get registration by certificate ID
  Future<Map<String, dynamic>?> getRegistrationByCertificateId(
    String certificateId,
  ) async {
    try {
      final querySnapshot = await _collection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Failed to get registration: $e');
      return null;
    }
  }

  // 👈 NEW METHOD: Get all registrations by user
  Future<List<Map<String, dynamic>>> getRegistrationsByUser(
    String userId,
  ) async {
    try {
      final querySnapshot = await _collection
          .where('submitted_by', isEqualTo: userId)
          .orderBy('submitted_at', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
    } catch (e) {
      print('❌ Failed to get user registrations: $e');
      return [];
    }
  }

  // 👈 NEW METHOD: Update NFT information after successful minting
  Future<void> updateNFTInfo(
    String registrationId, {
    required int tokenId,
    required String transactionHash,
    required String contractAddress,
    required String ownerAddress,
    String? imageUrl,
    String? metadataUrl,
  }) async {
    try {
      await _collection.doc(registrationId).update({
        'nft_token_id': tokenId,
        'nft_transaction_hash': transactionHash,
        'nft_contract_address': contractAddress,
        'nft_owner_address': ownerAddress,
        'nft_image_url': imageUrl,
        'nft_metadata_url': metadataUrl,
        'nft_minted_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ NFT info updated for registration: $registrationId');
    } catch (e) {
      print('❌ Failed to update NFT info: $e');
      rethrow;
    }
  }
}