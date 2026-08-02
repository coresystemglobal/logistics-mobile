class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String surname;
  final String? phone;
  final String role; // SUPER_ADMIN, ADMIN, MANAGER, RIDER, USER, BUSINESS_OWNER
  final String? type;
  final String? profilePhoto;
  final bool? emailVerified;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.surname,
    this.phone,
    required this.role,
    this.type,
    this.profilePhoto,
    this.emailVerified,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        firstName: json['first_name'] ?? json['firstName'] ?? '',
        surname: json['surname'] ?? json['last_name'] ?? json['lastName'] ?? '',
        phone: json['phone'],
        role: json['role'] ?? 'USER',
        type: json['type'],
        profilePhoto: json['profile_photo'] ?? json['profilePhoto'],
        emailVerified: json['email_verified'] ?? json['emailVerified'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  String get fullName => '$firstName $surname'.trim();
  String get businessName => fullName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'surname': surname,
        'phone': phone,
        'role': role,
        'type': type,
        'profile_photo': profilePhoto,
        'email_verified': emailVerified,
      };

  bool get isRider => role == 'RIDER';
  bool get isUser => role == 'USER';
  bool get isBusinessOwner => role == 'BUSINESS_OWNER';
  bool get isAdmin =>
      role == 'ADMIN' || role == 'SUPER_ADMIN' || role == 'MANAGER';
}
