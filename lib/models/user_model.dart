class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String userName;
  final bool isActive;
  final DateTime createdAt;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userName,
    required this.isActive,
    required this.createdAt,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'userName': userName,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'roles': roles,
      };

  bool get isAdmin => roles.contains('Admin');

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? userName,
    bool? isActive,
    DateTime? createdAt,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
    );
  }
}

class AuthResponse {
  final String token;
  final String email;
  final String fullName;
  final List<String> roles;
  final DateTime expiration;

  AuthResponse({
    required this.token,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.expiration,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      expiration:
          DateTime.tryParse(json['expiration'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isAdmin => roles.contains('Admin');
}
