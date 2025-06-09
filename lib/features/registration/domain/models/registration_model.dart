class RegistrationRequest {
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
  final String? documentUrl;

  RegistrationRequest({
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
    this.documentUrl,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'place_of_birth': placeOfBirth,
        'date_of_birth': dateOfBirth,
        'mother_first_name': motherFirstName,
        'mother_last_name': motherLastName,
        'father_first_name': fatherFirstName,
        'father_last_name': fatherLastName,
        'mother_nin': motherNIN,
        'father_nin': fatherNIN,
        'wallet': wallet,
        'document_url': documentUrl,
      };
}
