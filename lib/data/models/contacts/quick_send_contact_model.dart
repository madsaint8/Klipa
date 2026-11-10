import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_send_contact_model.freezed.dart';
part 'quick_send_contact_model.g.dart';

@freezed
class QuickSendContact with _$QuickSendContact {
  const factory QuickSendContact({
    required String id,
    required String name,
    String? phone,
    String? avatarUrl,
    @Default(false) bool isFavorite,
    DateTime? lastTransferAt,
  }) = _QuickSendContact;

  factory QuickSendContact.fromJson(Map<String, dynamic> json) =>
      _$QuickSendContactFromJson(json);
      
        @override
        // TODO: implement avatarUrl
        String? get avatarUrl => throw UnimplementedError();
      
        @override
        // TODO: implement id
        String get id => throw UnimplementedError();
      
        @override
        // TODO: implement isFavorite
        bool get isFavorite => throw UnimplementedError();
      
        @override
        // TODO: implement lastTransferAt
        DateTime? get lastTransferAt => throw UnimplementedError();
      
        @override
        // TODO: implement name
        String get name => throw UnimplementedError();
      
        @override
        // TODO: implement phone
        String? get phone => throw UnimplementedError();
      
        @override
        Map<String, dynamic> toJson() {
          // TODO: implement toJson
          throw UnimplementedError();
        }
}
