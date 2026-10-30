class User {
  final int? id;
  final String nome;
  final String nomeUsuario;
  final String email;
  final String? telefone;
  final String papel;

  User({
    this.id,
    required this.nome,
    required this.nomeUsuario,
    required this.email,
    this.telefone,
    required this.papel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      nome: json['name'] as String? ?? '',
      nomeUsuario: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['phone'] as String?,
      papel: json['role'] as String? ?? 'ROLE_USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'username': nomeUsuario,
      'email': email,
      'phone': telefone,
      'role': papel,
    };
  }
}

class AuthResponse {
  final String token;
  final String tipoToken;
  final User usuario;

  AuthResponse({
    required this.token,
    required this.tipoToken,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      tipoToken: json['type'] as String? ?? 'Bearer',
      usuario: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
