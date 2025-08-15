class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String id;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.id
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      id:json['id'] ?? ''
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
  };
}
