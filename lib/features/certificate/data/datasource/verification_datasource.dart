// lib/features/certificate/data/datasource/verification_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationDatasource {
  final _certificatesCollection = FirebaseFirestore.instance.collection('certificates');
  final _registrationsCollection = FirebaseFirestore.instance.collection('birth_registrations');

  Future<Map<String, dynamic>?> getCertificateById(String certificateId) async {
    try {
      print('🔍 Searching for certificate ID: $certificateId');
      
      // First, try to find by certificate ID in the certificate collection
      final certificateQuery = await _certificatesCollection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();

      if (certificateQuery.docs.isNotEmpty) {
        print('✅ Found certificate in certificates collection');
        final certData = certificateQuery.docs.first.data();
        
        // Get additional registration data if available
        if (certData['registration_id'] != null) {
          final regDoc = await _registrationsCollection
              .doc(certData['registration_id'])
              .get();
          
          if (regDoc.exists) {
            final regData = regDoc.data()!;
            return {
              ...certData,
              ...regData,
              'certificate_id': certificateId,
              'name': certData['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            };
          }
        }
        
        return {
          ...certData,
          'certificate_id': certificateId,
        };
      }

      print('❌ Certificate not found in certificates collection, searching registrations...');

      // If not found in certificates, search in registrations collection
      final registrationQuery = await _registrationsCollection
          .where('certificate_id', isEqualTo: certificateId)
          .limit(1)
          .get();

      if (registrationQuery.docs.isNotEmpty) {
        print('✅ Found certificate in registrations collection');
        final regData = registrationQuery.docs.first.data();
        final regId = registrationQuery.docs.first.id;
        
        // Try to find corresponding certificate document
        final certQuery = await _certificatesCollection
            .where('registration_id', isEqualTo: regId)
            .limit(1)
            .get();

        Map<String, dynamic> certificateData;
        
        if (certQuery.docs.isNotEmpty) {
          // Merge certificate and registration data
          final certData = certQuery.docs.first.data();
          certificateData = {
            ...certData,
            ...regData,
            'certificate_id': certificateId,
            'name': certData['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            'date_of_birth': certData['date_of_birth'] ?? regData['dateOfBirth'],
            'place_of_birth': certData['place_of_birth'] ?? regData['placeOfBirth'],
            'nin': certData['nin'] ?? regData['motherNIN'] ?? regData['fatherNIN'],
            'created_at': certData['created_at'] ?? regData['submitted_at'],
          };
        } else {
          // Create certificate data from registration only
          certificateData = {
            ...regData,
            'name': '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            'date_of_birth': regData['dateOfBirth'] ?? '',
            'place_of_birth': regData['placeOfBirth'] ?? '',
            'nin': regData['motherNIN'] ?? regData['fatherNIN'] ?? '',
            'created_at': regData['submitted_at'] ?? DateTime.now().toIso8601String(),
            'certificate_id': certificateId,
            'blockchain_verified': regData['nft_token_id'] != null,
            'status': 'active',
          };
        }
        
        return certificateData;
      }

      print('❌ Certificate not found in either collection');
      return null;
    } catch (e) {
      print('❌ Error getting certificate by ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCertificateByCid(String cid) async {
    try {
      print('🔍 Searching for certificate CID: $cid');
      
      // Search by certificate CID in certificates collection
      final certificateQuery = await _certificatesCollection
          .where('certificate_cid', isEqualTo: cid)
          .limit(1)
          .get();

      if (certificateQuery.docs.isNotEmpty) {
        print('✅ Found certificate by CID in certificates collection');
        final certData = certificateQuery.docs.first.data();
        
        // Get additional registration data if available
        if (certData['registration_id'] != null) {
          final regDoc = await _registrationsCollection
              .doc(certData['registration_id'])
              .get();
          
          if (regDoc.exists) {
            final regData = regDoc.data()!;
            return {
              ...certData,
              ...regData,
              'name': certData['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
            };
          }
        }
        
        return certData;
      }

      print('❌ Certificate not found in certificates collection, searching registrations...');

      // Search in registrations collection
      final registrationQuery = await _registrationsCollection
          .where('certificate_cid', isEqualTo: cid)
          .limit(1)
          .get();

      if (registrationQuery.docs.isNotEmpty) {
        print('✅ Found certificate by CID in registrations collection');
        final regData = registrationQuery.docs.first.data();
        final regId = registrationQuery.docs.first.id;
        
        // Try to find corresponding certificate
        final certQuery = await _certificatesCollection
            .where('registration_id', isEqualTo: regId)
            .limit(1)
            .get();

        if (certQuery.docs.isNotEmpty) {
          final certData = certQuery.docs.first.data();
          return {
            ...certData,
            ...regData,
            'name': certData['name'] ?? '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
          };
        }

        // Return registration data formatted as certificate
        return {
          ...regData,
          'name': '${regData['firstName'] ?? ''} ${regData['lastName'] ?? ''}'.trim(),
          'date_of_birth': regData['dateOfBirth'] ?? '',
          'place_of_birth': regData['placeOfBirth'] ?? '',
          'nin': regData['motherNIN'] ?? regData['fatherNIN'] ?? '',
          'created_at': regData['submitted_at'] ?? DateTime.now().toIso8601String(),
          'certificate_cid': cid,
          'blockchain_verified': regData['nft_token_id'] != null,
          'status': 'active',
        };
      }

      print('❌ Certificate not found by CID in either collection');
      return null;
    } catch (e) {
      print('❌ Error getting certificate by CID: $e');
      return null;
    }
  }

  // Helper method to fix missing certificate_id in certificate documents
  Future<void> fixCertificateIds() async {
    try {
      print('🔧 Starting certificate ID fix...');
      
      // Get all certificates without certificate_id
      final certificatesSnapshot = await _certificatesCollection
          .where('certificate_id', isEqualTo: null)
          .get();

      for (var certDoc in certificatesSnapshot.docs) {
        final certData = certDoc.data();
        final registrationId = certData['registration_id'];
        
        if (registrationId != null) {
          // Get the registration document
          final regDoc = await _registrationsCollection.doc(registrationId).get();
          
          if (regDoc.exists) {
            final regData = regDoc.data()!;
            final certificateId = regData['certificate_id'];
            
            if (certificateId != null) {
              // Update the certificate document with the certificate_id
              await certDoc.reference.update({
                'certificate_id': certificateId,
                'updated_at': DateTime.now().toIso8601String(),
              });
              
              print('✅ Fixed certificate ${certDoc.id} with ID: $certificateId');
            }
          }
        }
      }
      
      print('🎉 Certificate ID fix completed');
    } catch (e) {
      print('❌ Error fixing certificate IDs: $e');
    }
  }

  // Debug method to check certificate data
  Future<void> debugCertificateId(String certificateId) async {
    try {
      print('🐛 Debug: Searching for certificate ID: $certificateId');
      
      // Check registrations collection
      final regQuery = await _registrationsCollection
          .where('certificate_id', isEqualTo: certificateId)
          .get();
      
      print('📊 Found ${regQuery.docs.length} registration(s) with this certificate ID');
      
      for (var doc in regQuery.docs) {
        print('📄 Registration ID: ${doc.id}');
        print('📄 Registration data: ${doc.data()}');
      }
      
      // Check certificates collection
      final certQuery = await _certificatesCollection
          .where('certificate_id', isEqualTo: certificateId)
          .get();
      
      print('📊 Found ${certQuery.docs.length} certificate(s) with this certificate ID');
      
      for (var doc in certQuery.docs) {
        print('📄 Certificate ID: ${doc.id}');
        print('📄 Certificate data: ${doc.data()}');
      }
      
      // Check certificates by registration_id
      if (regQuery.docs.isNotEmpty) {
        final regId = regQuery.docs.first.id;
        final certByRegQuery = await _certificatesCollection
            .where('registration_id', isEqualTo: regId)
            .get();
        
        print('📊 Found ${certByRegQuery.docs.length} certificate(s) with registration ID: $regId');
        
        for (var doc in certByRegQuery.docs) {
          print('📄 Certificate data: ${doc.data()}');
        }
      }
      
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}