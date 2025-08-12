import 'package:birth_certify/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:birth_certify/features/registration/domain/models/registration_model.dart';

import '../../domain/repository/registration_repository.dart';
import '../datasource/registration_firestore_datasource.dart';



// class RegistrationRepositoryImpl implements RegistrationRepository {
//   final RegistrationFirestoreDatasource remote;
//   final CertificateFirestoreDatasource certs;

//   RegistrationRepositoryImpl(this.remote, this.certs);

//   @override
//   Future<void> submitRegistration(RegistrationRequest request, String submittedBy) async {
//     final regId = await remote.submitAndGetId(request, submittedBy); // 1. Save registration

//     await certs.createCertificateFromRegistration(                // 2. Create certificate
//       registrationId: regId,
//       name: '${request.firstName} ${request.lastName}',
//       dob: request.dateOfBirth,
//       placeOfBirth: request.placeOfBirth,
//       nin: request.motherNIN, // Or fatherNIN depending on your spec
//     );
//   }
// }
