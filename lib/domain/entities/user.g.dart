// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      subscriptionType: json['subscriptionType'] as String? ?? 'free',
      lastLoginDate: json['lastLoginDate'] == null
          ? null
          : DateTime.parse(json['lastLoginDate'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'subscriptionType': instance.subscriptionType,
      'lastLoginDate': instance.lastLoginDate?.toIso8601String(),
    };
