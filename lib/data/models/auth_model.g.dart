// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) => AuthModel(
      id: (json['id'] as num?)?.toInt(),
      token: json['token'] as String,
      userEmail: json['user_email'] as String,
      userDisplayName: json['user_display_name'] as String,
      userNiceName: json['user_nicename'] as String,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'user_email': instance.userEmail,
      'user_display_name': instance.userDisplayName,
      'user_nicename': instance.userNiceName,
      'roles': instance.roles,
    };
