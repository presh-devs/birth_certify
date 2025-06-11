class Certificate {
  final String name;

  final String dateOfBirth;
  final String placeOfBirth;
  final String nin;
  final DateTime registeredAt;
  final String? registrationId;

  Certificate({
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nin,
    required this.registeredAt,
    required this.registrationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth,
      'place_of_birth': placeOfBirth,
      'nin': nin,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      registrationId: json['registration_id'],
      name: json['name'],
      dateOfBirth: json['date_of_birth'],
      placeOfBirth: json['place_of_birth'],
      nin: json['nin'],
      registeredAt: DateTime.parse(json['created_at']),
    );
  }
}
