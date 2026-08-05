// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryItem _$DictionaryItemFromJson(Map<String, dynamic> json) =>
    DictionaryItem(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
      category: json['category'] as String?,
      group: json['group'] as String?,
      parentId: json['parentId'] as String?,
      rank: (json['rank'] as num?)?.toInt(),
      mergedIntoId: json['mergedIntoId'] as String?,
    );
