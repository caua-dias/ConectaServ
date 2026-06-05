/// Modelo de usuário retornado pelo backend após autenticação ou registro.
///
/// Utilizado por:
/// - [AuthService] → login, recoverPassword
/// - [ClientService] → registerClient
/// - [CompanyService] → registerCompany
/// - [AuthRepository] → login
class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? phone;

  /// Tipo do usuário: 'client' | 'company'
  final String userType;

  /// CNPJ preenchido apenas quando [userType] == 'company'
  final String? cnpj;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.userType,
    this.phone,
    this.cnpj,
  });

  // ---------------------------------------------------------------------------
  // Serialização
  // ---------------------------------------------------------------------------

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      userType: json['userType'] as String? ?? 'client',
      phone: json['phone'] as String?,
      cnpj: json['cnpj'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'userType': userType,
      if (phone != null) 'phone': phone,
      if (cnpj != null) 'cnpj': cnpj,
    };
  }

  // ---------------------------------------------------------------------------
  // Utilitários
  // ---------------------------------------------------------------------------

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? userType,
    String? phone,
    String? cnpj,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      cnpj: cnpj ?? this.cnpj,
    );
  }

  bool get isCompany => userType == 'company';
  bool get isClient => userType == 'client';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.token == token &&
        other.userType == userType &&
        other.phone == phone &&
        other.cnpj == cnpj;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      token.hashCode ^
      userType.hashCode ^
      (phone?.hashCode ?? 0) ^
      (cnpj?.hashCode ?? 0);

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, userType: $userType)';
}