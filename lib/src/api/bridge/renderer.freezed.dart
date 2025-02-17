// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'renderer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TextureEvent {
  /// ID of the texture.
  int get textureId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int textureId,
      int width,
      int height,
      int rotation,
    )
    onTextureChange,
    required TResult Function(int textureId) onFirstFrameRendered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult? Function(int textureId)? onFirstFrameRendered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult Function(int textureId)? onFirstFrameRendered,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextureEvent_OnTextureChange value)
    onTextureChange,
    required TResult Function(TextureEvent_OnFirstFrameRendered value)
    onFirstFrameRendered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult? Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextureEventCopyWith<TextureEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextureEventCopyWith<$Res> {
  factory $TextureEventCopyWith(
    TextureEvent value,
    $Res Function(TextureEvent) then,
  ) = _$TextureEventCopyWithImpl<$Res, TextureEvent>;
  @useResult
  $Res call({int textureId});
}

/// @nodoc
class _$TextureEventCopyWithImpl<$Res, $Val extends TextureEvent>
    implements $TextureEventCopyWith<$Res> {
  _$TextureEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? textureId = null}) {
    return _then(
      _value.copyWith(
            textureId:
                null == textureId
                    ? _value.textureId
                    : textureId // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TextureEvent_OnTextureChangeImplCopyWith<$Res>
    implements $TextureEventCopyWith<$Res> {
  factory _$$TextureEvent_OnTextureChangeImplCopyWith(
    _$TextureEvent_OnTextureChangeImpl value,
    $Res Function(_$TextureEvent_OnTextureChangeImpl) then,
  ) = __$$TextureEvent_OnTextureChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int textureId, int width, int height, int rotation});
}

/// @nodoc
class __$$TextureEvent_OnTextureChangeImplCopyWithImpl<$Res>
    extends _$TextureEventCopyWithImpl<$Res, _$TextureEvent_OnTextureChangeImpl>
    implements _$$TextureEvent_OnTextureChangeImplCopyWith<$Res> {
  __$$TextureEvent_OnTextureChangeImplCopyWithImpl(
    _$TextureEvent_OnTextureChangeImpl _value,
    $Res Function(_$TextureEvent_OnTextureChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textureId = null,
    Object? width = null,
    Object? height = null,
    Object? rotation = null,
  }) {
    return _then(
      _$TextureEvent_OnTextureChangeImpl(
        textureId:
            null == textureId
                ? _value.textureId
                : textureId // ignore: cast_nullable_to_non_nullable
                    as int,
        width:
            null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                    as int,
        height:
            null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int,
        rotation:
            null == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$TextureEvent_OnTextureChangeImpl extends TextureEvent_OnTextureChange {
  const _$TextureEvent_OnTextureChangeImpl({
    required this.textureId,
    required this.width,
    required this.height,
    required this.rotation,
  }) : super._();

  /// ID of the texture.
  @override
  final int textureId;

  /// Width of the last processed frame.
  @override
  final int width;

  /// Height of the last processed frame.
  @override
  final int height;

  /// Rotation of the last processed frame.
  @override
  final int rotation;

  @override
  String toString() {
    return 'TextureEvent.onTextureChange(textureId: $textureId, width: $width, height: $height, rotation: $rotation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextureEvent_OnTextureChangeImpl &&
            (identical(other.textureId, textureId) ||
                other.textureId == textureId) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, textureId, width, height, rotation);

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextureEvent_OnTextureChangeImplCopyWith<
    _$TextureEvent_OnTextureChangeImpl
  >
  get copyWith => __$$TextureEvent_OnTextureChangeImplCopyWithImpl<
    _$TextureEvent_OnTextureChangeImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int textureId,
      int width,
      int height,
      int rotation,
    )
    onTextureChange,
    required TResult Function(int textureId) onFirstFrameRendered,
  }) {
    return onTextureChange(textureId, width, height, rotation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult? Function(int textureId)? onFirstFrameRendered,
  }) {
    return onTextureChange?.call(textureId, width, height, rotation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult Function(int textureId)? onFirstFrameRendered,
    required TResult orElse(),
  }) {
    if (onTextureChange != null) {
      return onTextureChange(textureId, width, height, rotation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextureEvent_OnTextureChange value)
    onTextureChange,
    required TResult Function(TextureEvent_OnFirstFrameRendered value)
    onFirstFrameRendered,
  }) {
    return onTextureChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult? Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
  }) {
    return onTextureChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
    required TResult orElse(),
  }) {
    if (onTextureChange != null) {
      return onTextureChange(this);
    }
    return orElse();
  }
}

abstract class TextureEvent_OnTextureChange extends TextureEvent {
  const factory TextureEvent_OnTextureChange({
    required final int textureId,
    required final int width,
    required final int height,
    required final int rotation,
  }) = _$TextureEvent_OnTextureChangeImpl;
  const TextureEvent_OnTextureChange._() : super._();

  /// ID of the texture.
  @override
  int get textureId;

  /// Width of the last processed frame.
  int get width;

  /// Height of the last processed frame.
  int get height;

  /// Rotation of the last processed frame.
  int get rotation;

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextureEvent_OnTextureChangeImplCopyWith<
    _$TextureEvent_OnTextureChangeImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TextureEvent_OnFirstFrameRenderedImplCopyWith<$Res>
    implements $TextureEventCopyWith<$Res> {
  factory _$$TextureEvent_OnFirstFrameRenderedImplCopyWith(
    _$TextureEvent_OnFirstFrameRenderedImpl value,
    $Res Function(_$TextureEvent_OnFirstFrameRenderedImpl) then,
  ) = __$$TextureEvent_OnFirstFrameRenderedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int textureId});
}

/// @nodoc
class __$$TextureEvent_OnFirstFrameRenderedImplCopyWithImpl<$Res>
    extends
        _$TextureEventCopyWithImpl<
          $Res,
          _$TextureEvent_OnFirstFrameRenderedImpl
        >
    implements _$$TextureEvent_OnFirstFrameRenderedImplCopyWith<$Res> {
  __$$TextureEvent_OnFirstFrameRenderedImplCopyWithImpl(
    _$TextureEvent_OnFirstFrameRenderedImpl _value,
    $Res Function(_$TextureEvent_OnFirstFrameRenderedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? textureId = null}) {
    return _then(
      _$TextureEvent_OnFirstFrameRenderedImpl(
        textureId:
            null == textureId
                ? _value.textureId
                : textureId // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$TextureEvent_OnFirstFrameRenderedImpl
    extends TextureEvent_OnFirstFrameRendered {
  const _$TextureEvent_OnFirstFrameRenderedImpl({required this.textureId})
    : super._();

  /// ID of the texture.
  @override
  final int textureId;

  @override
  String toString() {
    return 'TextureEvent.onFirstFrameRendered(textureId: $textureId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextureEvent_OnFirstFrameRenderedImpl &&
            (identical(other.textureId, textureId) ||
                other.textureId == textureId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, textureId);

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextureEvent_OnFirstFrameRenderedImplCopyWith<
    _$TextureEvent_OnFirstFrameRenderedImpl
  >
  get copyWith => __$$TextureEvent_OnFirstFrameRenderedImplCopyWithImpl<
    _$TextureEvent_OnFirstFrameRenderedImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int textureId,
      int width,
      int height,
      int rotation,
    )
    onTextureChange,
    required TResult Function(int textureId) onFirstFrameRendered,
  }) {
    return onFirstFrameRendered(textureId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult? Function(int textureId)? onFirstFrameRendered,
  }) {
    return onFirstFrameRendered?.call(textureId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int textureId, int width, int height, int rotation)?
    onTextureChange,
    TResult Function(int textureId)? onFirstFrameRendered,
    required TResult orElse(),
  }) {
    if (onFirstFrameRendered != null) {
      return onFirstFrameRendered(textureId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextureEvent_OnTextureChange value)
    onTextureChange,
    required TResult Function(TextureEvent_OnFirstFrameRendered value)
    onFirstFrameRendered,
  }) {
    return onFirstFrameRendered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult? Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
  }) {
    return onFirstFrameRendered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextureEvent_OnTextureChange value)? onTextureChange,
    TResult Function(TextureEvent_OnFirstFrameRendered value)?
    onFirstFrameRendered,
    required TResult orElse(),
  }) {
    if (onFirstFrameRendered != null) {
      return onFirstFrameRendered(this);
    }
    return orElse();
  }
}

abstract class TextureEvent_OnFirstFrameRendered extends TextureEvent {
  const factory TextureEvent_OnFirstFrameRendered({
    required final int textureId,
  }) = _$TextureEvent_OnFirstFrameRenderedImpl;
  const TextureEvent_OnFirstFrameRendered._() : super._();

  /// ID of the texture.
  @override
  int get textureId;

  /// Create a copy of TextureEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextureEvent_OnFirstFrameRenderedImplCopyWith<
    _$TextureEvent_OnFirstFrameRenderedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
