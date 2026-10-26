enum UserRole {
  pengguna('pengguna', 'Pengguna'),
  sopir('sopir', 'Sopir Ambulans'),
  admin('admin', 'Administrator');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'sopir':
      case 'driver':
        return UserRole.sopir;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'pengguna':
      case 'user':
      default:
        return UserRole.pengguna;
    }
  }

  bool get isPengguna => this == UserRole.pengguna;
  bool get isSopir => this == UserRole.sopir;
  bool get isAdmin => this == UserRole.admin;
}

class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ role.hashCode;
}
