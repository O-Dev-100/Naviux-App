import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel {
  final int? id;
  final String token;
  
  @JsonKey(name: 'user_email')
  final String userEmail;
  
  @JsonKey(name: 'user_display_name')
  final String userDisplayName;
  
  @JsonKey(name: 'user_nicename')
  final String userNiceName;

  final List<String>? roles;

  AuthModel({
    this.id,
    required this.token,
    required this.userEmail,
    required this.userDisplayName,
    required this.userNiceName,
    this.roles,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => _$AuthModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthModelToJson(this);

  // Helpers para Roles
  bool get isPharmacy {
    if (roles == null) return false;
    final rolesLower = roles!.map((r) => r.toLowerCase().trim()).toList();
    return rolesLower.contains('pharmacy') || rolesLower.contains('farmacias');
  }
  bool get isRegularCustomer => roles?.contains('subscriber') ?? roles?.contains('customer') ?? true;
  bool get isAdmin => roles?.contains('administrator') ?? false;
}
