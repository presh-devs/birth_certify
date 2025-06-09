
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/certificate_model.dart';

class CertificateFirestoreDatasource {
  final _collection = FirebaseFirestore.instance.collection('certificates');

  Future<void> addCertificate(Certificate cert) async {
    await _collection.add(cert.toJson());
  }

  Future<List<Certificate>> getCertificates() async {
    final snapshot = await _collection.orderBy('registered_at', descending: true).get();
    return snapshot.docs.map((doc) => Certificate.fromJson(doc.data())).toList();
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
}
