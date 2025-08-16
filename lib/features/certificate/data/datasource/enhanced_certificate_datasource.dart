// lib/features/certificate/data/datasource/enhanced_certificate_datasource.dart
import 'package:birth_certify/features/certificate/presentation/providers/enhanced_certificate_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedCertificateDatasource {
  final _certificatesCollection = FirebaseFirestore.instance.collection('certificates');
  final _registrationsCollection = FirebaseFirestore.instance.collection('birth_registrations');

  Future<List<EnhancedCertificate>> getEnhancedCertificates() async {
    try {
      // Get all certificates with their enhanced data
      final certificatesSnapshot = await _certificatesCollection
          .orderBy('created_at', descending: true)
          .get();

      List<EnhancedCertificate> certificates = [];

      for (var doc in certificatesSnapshot.docs) {
        final data = doc.data();
        
        // If there's a registration_id, get additional data from registrations
        if (data['registration_id'] != null) {
          try {
            final registrationDoc = await _registrationsCollection
                .doc(data['registration_id'])
                .get();
            
            if (registrationDoc.exists) {
              final regData = registrationDoc.data()!;
              // Merge certificate and registration data
              final mergedData = {
                ...data,
                ...regData,
                'name': data['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
                'date_of_birth': data['date_of_birth'] ?? regData['dateOfBirth'],
                'place_of_birth': data['place_of_birth'] ?? regData['placeOfBirth'],
                'nin': data['nin'] ?? regData['motherNIN'] ?? regData['fatherNIN'],
              };
              certificates.add(EnhancedCertificate.fromJson(mergedData));
            } else {
              certificates.add(EnhancedCertificate.fromJson(data));
            }
          } catch (e) {
            print('Error fetching registration data: $e');
            certificates.add(EnhancedCertificate.fromJson(data));
          }
        } else {
          certificates.add(EnhancedCertificate.fromJson(data));
        }
      }

      // Also get any registrations that might not have corresponding certificates yet
      final registrationsSnapshot = await _registrationsCollection
          .orderBy('submitted_at', descending: true)
          .get();

      for (var doc in registrationsSnapshot.docs) {
        final regData = doc.data();
        
        // Check if this registration already has a certificate
        final existingCert = certificates.any((cert) => cert.registrationId == doc.id);
        
        if (!existingCert) {
          // Create a certificate from registration data
          final certificateData = {
            'registration_id': doc.id,
            'name': '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            'date_of_birth': regData['dateOfBirth'] ?? '',
            'place_of_birth': regData['placeOfBirth'] ?? '',
            'nin': regData['motherNIN'] ?? regData['fatherNIN'] ?? '',
            'created_at': regData['submitted_at'] ?? DateTime.now().toIso8601String(),
            'certificate_id': regData['certificate_id'],
            'certificate_cid': regData['certificate_cid'],
            'certificate_url': regData['certificate_url'],
            'metadata_cid': regData['metadata_cid'],
            'metadata_url': regData['metadata_url'],
            'supporting_document_cid': regData['supporting_document_cid'],
            'supporting_document_url': regData['supporting_document_url'],
            'nft_token_id': regData['nft_token_id'],
            'nft_transaction_hash': regData['nft_transaction_hash'],
            'nft_contract_address': regData['nft_contract_address'],
            'nft_owner_address': regData['nft_owner_address'],
            'blockchain_verified': regData['nft_token_id'] != null,
            'status': 'active',
          };
          
          certificates.add(EnhancedCertificate.fromJson(certificateData));
        }
      }

      // Sort by registration date, newest first
      certificates.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

      return certificates;
    } catch (e) {
      print('Error fetching enhanced certificates: $e');
      throw Exception('Failed to fetch certificates: $e');
    }
  }

  Future<EnhancedCertificate?> getCertificateById(String certificateId) async {
    try {
      // First, try to find in certificates collection
      final certQuery = await _certificatesCollection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();

      if (certQuery.docs.isNotEmpty) {
        final data = certQuery.docs.first.data();
        
        // Get additional registration data if available
        if (data['registration_id'] != null) {
          final regDoc = await _registrationsCollection
              .doc(data['registration_id'])
              .get();
          
          if (regDoc.exists) {
            final regData = regDoc.data()!;
            final mergedData = {
              ...data,
              ...regData,
              'name': data['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            };
            return EnhancedCertificate.fromJson(mergedData);
          }
        }
        
        return EnhancedCertificate.fromJson(data);
      }

      // If not found in certificates, try registrations collection
      final regQuery = await _registrationsCollection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();

      if (regQuery.docs.isNotEmpty) {
        final regData = regQuery.docs.first.data();
        final certificateData = {
          'registration_id': regQuery.docs.first.id,
          'name': '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
          'date_of_birth': regData['dateOfBirth'] ?? '',
          'place_of_birth': regData['placeOfBirth'] ?? '',
          'nin': regData['motherNIN'] ?? regData['fatherNIN'] ?? '',
          'created_at': regData['submitted_at'] ?? DateTime.now().toIso8601String(),
          'certificate_id': regData['certificate_id'],
          'certificate_cid': regData['certificate_cid'],
          'certificate_url': regData['certificate_url'],
          'metadata_cid': regData['metadata_cid'],
          'metadata_url': regData['metadata_url'],
          'supporting_document_cid': regData['supporting_document_cid'],
          'supporting_document_url': regData['supporting_document_url'],
          'nft_token_id': regData['nft_token_id'],
          'nft_transaction_hash': regData['nft_transaction_hash'],
          'nft_contract_address': regData['nft_contract_address'],
          'nft_owner_address': regData['nft_owner_address'],
          'blockchain_verified': regData['nft_token_id'] != null,
          'status': 'active',
        };
        
        return EnhancedCertificate.fromJson(certificateData);
      }

      return null;
    } catch (e) {
      print('Error getting certificate by ID: $e');
      throw Exception('Failed to get certificate: $e');
    }
  }

  Future<PaginatedCertificates> getPaginatedCertificates(PaginationParams params) async {
    try {
      // For simplicity, we'll get all certificates and paginate in memory
      // In production, you might want to implement proper Firestore pagination
      final allCertificates = await getEnhancedCertificates();
      
      // Apply search filter first
      List<EnhancedCertificate> filteredCertificates = allCertificates;
      
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        filteredCertificates = allCertificates.where((cert) =>
            cert.name.toLowerCase().contains(params.searchQuery!.toLowerCase()) ||
            (cert.certificateId?.toLowerCase().contains(params.searchQuery!.toLowerCase()) ?? false) ||
            cert.nin.toLowerCase().contains(params.searchQuery!.toLowerCase())).toList();
      }

      // Apply additional filters
      if (params.filter != null) {
        switch (params.filter) {
          case 'verified':
            filteredCertificates = filteredCertificates.where((cert) => cert.blockchainVerified).toList();
            break;
          case 'nft':
            filteredCertificates = filteredCertificates.where((cert) => cert.nftTokenId != null).toList();
            break;
          case 'recent':
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            filteredCertificates = filteredCertificates.where((cert) => 
                cert.registeredAt.isAfter(thirtyDaysAgo)).toList();
            break;
        }
      }

      final totalCount = filteredCertificates.length;
      final totalPages = (totalCount / params.limit).ceil();
      
      // Apply pagination in memory
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalCount);
      
      final paginatedCertificates = filteredCertificates.sublist(
        startIndex, 
        endIndex
      );

      return PaginatedCertificates(
        certificates: paginatedCertificates,
        totalCount: totalCount,
        currentPage: params.page,
        totalPages: totalPages,
      );
    } catch (e) {
      print('Error getting paginated certificates: $e');
      throw Exception('Failed to get paginated certificates: $e');
    }
  }

  Future<void> updateCertificateStatus(String certificateId, String status) async {
    try {
      final query = await _certificatesCollection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error updating certificate status: $e');
      throw Exception('Failed to update certificate status: $e');
    }
  }

  Future<List<EnhancedCertificate>> searchCertificates(String searchQuery) async {
    try {
      // Get all certificates and filter in memory
      // In a production app, you might want to use Algolia or similar for better search
      final allCertificates = await getEnhancedCertificates();
      
      return allCertificates.where((cert) =>
          cert.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (cert.certificateId?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          cert.nin.toLowerCase().contains(searchQuery.toLowerCase()) ||
          cert.placeOfBirth.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    } catch (e) {
      print('Error searching certificates: $e');
      throw Exception('Failed to search certificates: $e');
    }
  }

  Future<Map<String, int>> getCertificateStats() async {
    try {
      final certificates = await getEnhancedCertificates();
      
      final total = certificates.length;
      final recent = certificates.where((cert) =>
          cert.registeredAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length;
      final verified = certificates.where((cert) => cert.blockchainVerified).length;
      final nftMinted = certificates.where((cert) => cert.nftTokenId != null).length;

      return {
        'total': total,
        'recent': recent,
        'verified': verified,
        'nft_minted': nftMinted,
      };
    } catch (e) {
      print('Error getting certificate stats: $e');
      return {
        'total': 0,
        'recent': 0,
        'verified': 0,
        'nft_minted': 0,
      };
    }
  }

  // Alternative method for true Firestore pagination (if needed)
  Future<PaginatedCertificates> getPaginatedCertificatesWithFirestore({
    required int page,
    required int limit,
    DocumentSnapshot? lastDocument,
    String? filter,
  }) async {
    try {
      Query query = _certificatesCollection.orderBy('created_at', descending: true);

      // Apply filters
      if (filter != null) {
        switch (filter) {
          case 'verified':
            query = query.where('blockchain_verified', isEqualTo: true);
            break;
          case 'nft':
            query = query.where('nft_token_id', isNotEqualTo: null);
            break;
          case 'recent':
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            query = query.where('created_at', isGreaterThan: thirtyDaysAgo.toIso8601String());
            break;
        }
      }

      // Apply pagination using startAfterDocument
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.limit(limit).get();
      
      List<EnhancedCertificate> certificates = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Get additional registration data if available
        if (data['registration_id'] != null) {
          try {
            final regDoc = await _registrationsCollection
                .doc(data['registration_id'])
                .get();
            
            if (regDoc.exists) {
              final regData = regDoc.data()!;
              final mergedData = {
                ...data,
                ...regData,
                'name': data['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
              };
              certificates.add(EnhancedCertificate.fromJson(mergedData));
            } else {
              certificates.add(EnhancedCertificate.fromJson(data));
            }
          } catch (e) {
            certificates.add(EnhancedCertificate.fromJson(data));
          }
        } else {
          certificates.add(EnhancedCertificate.fromJson(data));
        }
      }

      // Get total count (this is expensive, consider caching)
      final totalSnapshot = await _certificatesCollection.get();
      final totalCount = totalSnapshot.docs.length;
      final totalPages = (totalCount / limit).ceil();

      return PaginatedCertificates(
        certificates: certificates,
        totalCount: totalCount,
        currentPage: page,
        totalPages: totalPages,
      );
    } catch (e) {
      print('Error getting paginated certificates with Firestore: $e');
      throw Exception('Failed to get paginated certificates: $e');
    }
  }
}