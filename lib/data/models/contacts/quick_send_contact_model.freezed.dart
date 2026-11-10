// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_send_contact_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuickSendContact {
  String get id;
  String get name;
  String? get phone;
  String? get avatarUrl;
  bool get isFavorite;
  DateTime? get lastTransferAt;

  /// Create a copy of QuickSendContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuickSendContactCopyWith<QuickSendContact> get copyWith =>
      _$QuickSendContactCopyWithImpl<QuickSendContact>(
          this as QuickSendContact, _$identity);

  /// Serializes this QuickSendContact to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuickSendContact &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.lastTransferAt, lastTransferAt) ||
                other.lastTransferAt == lastTransferAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, phone, avatarUrl, isFavorite, lastTransferAt);

  @override
  String toString() {
    return 'QuickSendContact(id: $id, name: $name, phone: $phone, avatarUrl: $avatarUrl, isFavorite: $isFavorite, lastTransferAt: $lastTransferAt)';
  }
}

/// @nodoc
abstract mixin class $QuickSendContactCopyWith<$Res> {
  factory $QuickSendContactCopyWith(
          QuickSendContact value, $Res Function(QuickSendContact) _then) =
      _$QuickSendContactCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? avatarUrl,
      bool isFavorite,
      DateTime? lastTransferAt});
}

/// @nodoc
class _$QuickSendContactCopyWithImpl<$Res>
    implements $QuickSendContactCopyWith<$Res> {
  _$QuickSendContactCopyWithImpl(this._self, this._then);

  final QuickSendContact _self;
  final $Res Function(QuickSendContact) _then;

  /// Create a copy of QuickSendContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? isFavorite = null,
    Object? lastTransferAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      lastTransferAt: freezed == lastTransferAt
          ? _self.lastTransferAt
          : lastTransferAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuickSendContact].
extension QuickSendContactPatterns on QuickSendContact {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_QuickSendContact value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_QuickSendContact value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_QuickSendContact value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name, String? phone, String? avatarUrl,
            bool isFavorite, DateTime? lastTransferAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact() when $default != null:
        return $default(_that.id, _that.name, _that.phone, _that.avatarUrl,
            _that.isFavorite, _that.lastTransferAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name, String? phone, String? avatarUrl,
            bool isFavorite, DateTime? lastTransferAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact():
        return $default(_that.id, _that.name, _that.phone, _that.avatarUrl,
            _that.isFavorite, _that.lastTransferAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name, String? phone, String? avatarUrl,
            bool isFavorite, DateTime? lastTransferAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickSendContact() when $default != null:
        return $default(_that.id, _that.name, _that.phone, _that.avatarUrl,
            _that.isFavorite, _that.lastTransferAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _QuickSendContact implements QuickSendContact {
  const _QuickSendContact(
      {required this.id,
      required this.name,
      this.phone,
      this.avatarUrl,
      this.isFavorite = false,
      this.lastTransferAt});
  factory _QuickSendContact.fromJson(Map<String, dynamic> json) =>
      _$QuickSendContactFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final DateTime? lastTransferAt;

  /// Create a copy of QuickSendContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuickSendContactCopyWith<_QuickSendContact> get copyWith =>
      __$QuickSendContactCopyWithImpl<_QuickSendContact>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuickSendContactToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuickSendContact &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.lastTransferAt, lastTransferAt) ||
                other.lastTransferAt == lastTransferAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, phone, avatarUrl, isFavorite, lastTransferAt);

  @override
  String toString() {
    return 'QuickSendContact(id: $id, name: $name, phone: $phone, avatarUrl: $avatarUrl, isFavorite: $isFavorite, lastTransferAt: $lastTransferAt)';
  }
}

/// @nodoc
abstract mixin class _$QuickSendContactCopyWith<$Res>
    implements $QuickSendContactCopyWith<$Res> {
  factory _$QuickSendContactCopyWith(
          _QuickSendContact value, $Res Function(_QuickSendContact) _then) =
      __$QuickSendContactCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? avatarUrl,
      bool isFavorite,
      DateTime? lastTransferAt});
}

/// @nodoc
class __$QuickSendContactCopyWithImpl<$Res>
    implements _$QuickSendContactCopyWith<$Res> {
  __$QuickSendContactCopyWithImpl(this._self, this._then);

  final _QuickSendContact _self;
  final $Res Function(_QuickSendContact) _then;

  /// Create a copy of QuickSendContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? isFavorite = null,
    Object? lastTransferAt = freezed,
  }) {
    return _then(_QuickSendContact(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      lastTransferAt: freezed == lastTransferAt
          ? _self.lastTransferAt
          : lastTransferAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
