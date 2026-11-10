// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_send_contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuickSendContact _$QuickSendContactFromJson(Map<String, dynamic> json) =>
    _QuickSendContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastTransferAt: json['lastTransferAt'] == null
          ? null
          : DateTime.parse(json['lastTransferAt'] as String),
    );

Map<String, dynamic> _$QuickSendContactToJson(_QuickSendContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'isFavorite': instance.isFavorite,
      'lastTransferAt': instance.lastTransferAt?.toIso8601String(),
    };
