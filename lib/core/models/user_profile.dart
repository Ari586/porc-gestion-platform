import 'json_helpers.dart';

class UserProfile {
  final String id;
  final String code;
  final String name;
  final String role;
  final String avatar;
  final String address;
  final String contact;
  final String fokontany;
  final String commune;
  final String district;
  final String region;
  final String bio;
  final String profileImageBase64;
  final String coverImageBase64;
  final String login;
  final String password;

  const UserProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.role,
    required this.avatar,
    this.address = '',
    this.contact = '',
    this.fokontany = '',
    this.commune = '',
    this.district = '',
    this.region = '',
    this.bio = '',
    this.profileImageBase64 = '',
    this.coverImageBase64 = '',
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'role': role,
      'avatar': avatar,
      'address': address,
      'contact': contact,
      'fokontany': fokontany,
      'commune': commune,
      'district': district,
      'region': region,
      'bio': bio,
      'profileImageBase64': profileImageBase64,
      'coverImageBase64': coverImageBase64,
      'login': login,
      'password': password,
    };
  }

  static UserProfile? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final code = JsonHelpers.readString(json['code']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final role = JsonHelpers.readString(json['role']).trim();
    final avatar = JsonHelpers.readString(json['avatar']).trim();
    final login = JsonHelpers.readString(json['login']).trim();
    final password = JsonHelpers.readString(json['password']);
    if (id.isEmpty ||
        code.isEmpty ||
        name.isEmpty ||
        role.isEmpty ||
        avatar.isEmpty ||
        login.isEmpty ||
        password.isEmpty) {
      return null;
    }
    return UserProfile(
      id: id,
      code: code,
      name: name,
      role: role,
      avatar: avatar,
      address: JsonHelpers.readString(json['address']).trim(),
      contact: JsonHelpers.readString(json['contact']).trim(),
      fokontany: JsonHelpers.readString(json['fokontany']).trim(),
      commune: JsonHelpers.readString(json['commune']).trim(),
      district: JsonHelpers.readString(json['district']).trim(),
      region: JsonHelpers.readString(json['region']).trim(),
      bio: JsonHelpers.readString(json['bio']).trim(),
      profileImageBase64: JsonHelpers.readString(json['profileImageBase64']).trim(),
      coverImageBase64: JsonHelpers.readString(json['coverImageBase64']).trim(),
      login: login,
      password: password,
    );
  }

  UserProfile copyWith({
    String? id,
    String? code,
    String? name,
    String? role,
    String? avatar,
    String? address,
    String? contact,
    String? fokontany,
    String? commune,
    String? district,
    String? region,
    String? bio,
    String? profileImageBase64,
    String? coverImageBase64,
    String? login,
    String? password,
  }) {
    return UserProfile(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      fokontany: fokontany ?? this.fokontany,
      commune: commune ?? this.commune,
      district: district ?? this.district,
      region: region ?? this.region,
      bio: bio ?? this.bio,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      coverImageBase64: coverImageBase64 ?? this.coverImageBase64,
      login: login ?? this.login,
      password: password ?? this.password,
    );
  }
}
