class Certificate {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String placeOfBirth;
  final String nin;
  final DateTime registeredAt;

  Certificate({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nin,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'place_of_birth': placeOfBirth,
      'nin': nin,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'],
      placeOfBirth: json['place_of_birth'],
      nin: json['nin'],
      registeredAt: DateTime.parse(json['registered_at']),
    );
  }
}
