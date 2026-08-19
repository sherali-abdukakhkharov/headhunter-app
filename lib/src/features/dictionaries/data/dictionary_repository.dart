import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_delta.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_repository.g.dart';

/// One response from `GET /dictionaries/{type}`.
///
/// [delta] is null when the server answered 304 — the cache is current and
/// there is nothing to merge.
class DictionaryFetch {
  const DictionaryFetch({this.delta, this.etag});

  final DictionaryDelta? delta;

  /// Replay as `If-None-Match` next time. Null only if the server sent none.
  final String? etag;

  bool get isUnchanged => delta == null;
}

/// Reads the dictionary endpoints (§3.3, BR-13).
///
/// Public endpoints: language and the pickers behind it are chosen **before**
/// registration (§3.2, §4.1), so these must work with no session.
///
/// The locale is not a parameter anywhere here — it rides on the `x-lang`
/// header the interceptor already sets, and the *response* says which locale
/// the server actually resolved. Passing it twice is two ways to disagree.
class DictionaryRepository {
  const DictionaryRepository(this._dio);

  final Dio _dio;

  /// `GET /dictionaries/{type}` — the whole set, or only what changed.
  ///
  /// Pass [since] from the previous response's `version` to get a delta, and
  /// [etag] from the previous response's header to get a 304. Omit both for a
  /// cold fetch.
  ///
  /// [DictionaryFetch.delta] is **null for a 304**, meaning what the caller has
  /// cached is already current. That is the steady-state answer, and it is why
  /// the tag is worth carrying: without it every launch re-downloads every
  /// dictionary in full.
  ///
  /// The tag comes back from the response rather than being reconstructed. Its
  /// format is the server's business, and a client that builds its own is one
  /// schema change away from revalidating nothing — silently, because a wrong
  /// tag simply never matches and everything still works, only slower.
  Future<DictionaryFetch> fetch(
    String type, {
    int? since,
    String? etag,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/dictionaries/$type',
        queryParameters: {'since': ?since},
        options: Options(
          headers: {'If-None-Match': ?etag},
          // 304 is a success here, not a failure. Without this the global
          // validateStatus turns it into a DioException and the cache-hit path
          // becomes an error path.
          validateStatus: (s) =>
              s != null && ((s >= 200 && s < 300) || s == 304),
        ),
      );

      final tag = response.headers.value('etag');

      if (response.statusCode == 304) {
        return DictionaryFetch(etag: tag ?? etag);
      }

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return DictionaryFetch(delta: DictionaryDelta.fromJson(data), etag: tag);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /dictionaries/items?ids=…` — resolves ids to labels **including
  /// inactive and merged ones**.
  ///
  /// This is what stops a historical record rendering a raw UUID. An
  /// application made last year may reference an occupation an administrator
  /// has since retired (§10.3); pickers must not offer it, and the record must
  /// still read as words.
  ///
  /// Chunked because the ids go in the query string, and a profile with many
  /// skills would otherwise build a URL long enough for a proxy to reject —
  /// a failure that appears only for the users with the most complete profiles.
  Future<List<DictionaryItem>> resolveIds(Iterable<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const [];

    final resolved = <DictionaryItem>[];

    for (var start = 0; start < unique.length; start += _idsPerRequest) {
      final end = (start + _idsPerRequest).clamp(0, unique.length);
      final chunk = unique.sublist(start, end);

      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/dictionaries/items',
          queryParameters: {'ids': chunk.join(',')},
        );

        final items = response.data?['items'];
        if (items is List) {
          resolved.addAll(
            items.map(
              (e) => DictionaryItem.fromJson(e as Map<String, dynamic>),
            ),
          );
        }
      } on DioException catch (e) {
        throw ApiException.fromDioException(e);
      }
    }

    return resolved;
  }

  /// A UUID is 36 characters plus a separator, so 50 keeps the query under
  /// ~1900 characters — comfortably inside the 2048 that proxies commonly cap.
  static const _idsPerRequest = 50;
}

@Riverpod(keepAlive: true)
DictionaryRepository dictionaryRepository(Ref ref) =>
    DictionaryRepository(ref.watch(dioProvider));
