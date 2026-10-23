import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.phoneNumber,
    super.profilePhotoUrl,
  });

  /// Factory constructor to create a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      profilePhotoUrl:
          json['profilePhotoUrl'] as String? ??
          json['profile_photo_url'] as String?,
    );
  }

  /// Converts this [UserModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  /// Creates a copy of this [UserModel] with given attributes updated.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: ${role.value})';
  }
}
