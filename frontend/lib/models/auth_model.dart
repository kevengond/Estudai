class User {
  final int? id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String role;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'ROLE_USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

class AuthResponse {
  final String token;
  final String type;
  final User user;

  AuthResponse({
    required this.token,
    required this.type,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      type: json['type'] as String? ?? 'Bearer',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
