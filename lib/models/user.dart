class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final DateTime birthDate;
  final List<String> medicalHistory;
  final List<String> currentMedications;
  final Guardian? guardian;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.birthDate,
    this.medicalHistory = const [],
    this.currentMedications = const [],
    this.guardian,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birthDate']),
      medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
      currentMedications: List<String>.from(json['currentMedications'] ?? []),
      guardian: json['guardian'] != null ? Guardian.fromJson(json['guardian']) : null,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'medicalHistory': medicalHistory,
      'currentMedications': currentMedications,
      'guardian': guardian?.toJson(),
      'address': address,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
    List<String>? medicalHistory,
    List<String>? currentMedications,
    Guardian? guardian,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentMedications: currentMedications ?? this.currentMedications,
      guardian: guardian ?? this.guardian,
      address: address ?? this.address,
    );
  }
}

class Guardian {
  final String name;
  final String relationship;
  final String phoneNumber;

  Guardian({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
  });

  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      name: json['name'],
      relationship: json['relationship'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
    };
  }
} 