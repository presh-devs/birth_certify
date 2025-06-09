import 'package:birth_certify/features/registration/domain/models/registration_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationFirestoreDatasource {
  final _collection = FirebaseFirestore.instance.collection(
    'birth_registrations',
  );
  Future<String> submitAndGetId(
    RegistrationRequest request,
    String submittedBy,
  ) async {
    final data =
        request.toJson()..addAll({
          'submitted_at': DateTime.now().toIso8601String(),
          'submitted_by': submittedBy,
        });

    final docRef = await _collection.add(data);
    return docRef.id; // 👈 return the new document ID
  }
}
