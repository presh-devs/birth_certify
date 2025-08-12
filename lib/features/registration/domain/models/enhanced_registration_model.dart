// lib/features/registration/domain/models/enhanced_registration_model.dart
import 'dart:io';

class EnhancedRegistrationRequest {
  final String firstName;
  final String middleName;
  final String lastName;
  final String placeOfBirth;
  final String dateOfBirth;
  final String motherFirstName;
  final String motherLastName;
  final String fatherFirstName;
  final String fatherLastName;
  final String motherNIN;
  final String fatherNIN;
  final String wallet;
  final File? supportingDocument;

  EnhancedRegistrationRequest({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.motherFirstName,
    required this.motherLastName,
    required this.fatherFirstName,
    required this.fatherLastName,
    required this.motherNIN,
    required this.fatherNIN,
    required this.wallet,
    this.supportingDocument,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'placeOfBirth': placeOfBirth,
      'dateOfBirth': dateOfBirth,
      'motherFirstName': motherFirstName,
      'motherLastName': motherLastName,
      'fatherFirstName': fatherFirstName,
      'fatherLastName': fatherLastName,
      'motherNIN': motherNIN,
      'fatherNIN': fatherNIN,
      'wallet': wallet,
    };
  }
}

class RegistrationResult {
  final bool success;
  final String certificateId;
  final String certificateCid;
  final String certificateUrl;
  final String? metadataCid;
  final String? metadataUrl;
  final String? supportingDocumentCid;
  final String? supportingDocumentUrl;
  final NFTInfo? nftInfo;
  final String registeredAt;

  RegistrationResult({
    required this.success,
    required this.certificateId,
    required this.certificateCid,
    required this.certificateUrl,
    this.metadataCid,
    this.metadataUrl,
    this.supportingDocumentCid,
    this.supportingDocumentUrl,
    this.nftInfo,
    required this.registeredAt,
  });

  factory RegistrationResult.fromStorachaResponse(Map<String, dynamic> json) {
    return RegistrationResult(
      success: json['success'] ?? false,
      certificateId: json['certificateId'] ?? '',
      certificateCid: json['certificate']['cid'] ?? '',
      certificateUrl: json['certificate']['gatewayUrl'] ?? '',
      metadataCid: json['metadata']?['cid'],
      metadataUrl: json['metadata']?['gatewayUrl'],
      supportingDocumentCid: json['supportingDocument']?['cid'],
      supportingDocumentUrl: json['supportingDocument']?['gatewayUrl'],
      nftInfo: json['nft'] != null ? NFTInfo.fromJson(json['nft']) : null,
      registeredAt: json['registeredAt'] ?? '',
    );
  }
}

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
      tokenId: json['tokenId'] ?? 0,
      transactionHash: json['transactionHash'] ?? '',
      contractAddress: json['contractAddress'] ?? '',
      ownerAddress: json['ownerAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'transactionHash': transactionHash,
      'contractAddress': contractAddress,
      'ownerAddress': ownerAddress,
    };
  }
}



// // lib/features/registration/presentation/providers/enhanced_registration_provider.dart
// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/models/enhanced_registration_model.dart';
// import '../../../storacha/presentation/providers/storacha_provider.dart';
// import '../../data/repositories/enhanced_registration_repository_impl.dart';
// import '../../data/datasource/registration_firestore_datasource.dart';
// import '../../../certificate/data/datasource/certificate_datasource.dart';

// // lib/main.dart - Integration example
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'features/registration/presentation/widgets/enhanced_registration_form.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
  
//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Birth Certificate NFT',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const BirthCertificateApp(),
//     );
//   }
// }

// class BirthCertificateApp extends StatelessWidget {
//   const BirthCertificateApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Birth Certificate NFT System'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Register', icon: Icon(Icons.person_add)),
//               Tab(text: 'Certificates', icon: Icon(Icons.description)),
//               Tab(text: 'NFT Gallery', icon: Icon(Icons.token)),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             EnhancedRegistrationForm(),
//             CertificatesPage(),
//             NFTGalleryPage(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Placeholder pages for the other tabs
// class CertificatesPage extends StatelessWidget {
//   const CertificatesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.description, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text('Certificates will be displayed here'),
//         ],
//       ),
//     );
//   }
// }

// class NFTGalleryPage extends StatelessWidget {
//   const NFTGalleryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.token, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text('NFT Gallery will be displayed here'),
//         ],
//       ),
//     );
//   }
// }