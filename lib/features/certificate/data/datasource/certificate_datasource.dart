import '../../domain/models/certificate_model.dart';

class CertificateRemoteDataSource {
  Future<List<Certificate>> fetchCertificates() async {
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data
    return List.generate(10, (index) {
      return Certificate(
        name: 'Abishola Christiana Davis',
        dob: 'Jan 05, 2025',
        placeOfBirth: ['Oyo', 'Lagos', 'Calabar', 'Benin', 'Osun'][index % 5],
        nin: '12093848542993',
        dateRegistered: 'Jan 07, 2025',
      );
    });
  }
}
